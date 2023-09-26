#!/bin/bash

C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_NONE='\033[0m'

while getopts ":d:domain:u:username:p:password" opt; do
  case $opt in
    d|domain) domain="$OPTARG"
    ;;
    u|username) username="$OPTARG"
    ;;
    p|password) password="$OPTARG"
    ;;
    \?) echo -e "${C_RED}[ERROR]${C_NONE} An invalid argument was supplied : -$OPTARG." >&2
    ;;
  esac
done

if [ $# -eq 0 ]
then
    echo -e "${C_RED}[ERROR]${C_NONE} Please provide -d -u -p arguments.\n${C_GREEN}[HELP]${C_NONE} Example : ./setup.sh -d domain.com -u username -p password"
    exit 1
fi

if [ -z "$domain" ];
then
    echo -e "${C_RED}[ERROR]${C_NONE} Please provide '-d | --domain' argument.\n${C_GREEN}[HELP]${C_NONE} Example : ./setup.sh -d domain.com -u username -p password"
    exit 2
fi

if [ -z "$username" ];
then
    echo -e "${C_RED}[ERROR]${C_NONE} Please provide '-u | --username' argument.\n${C_GREEN}[HELP]${C_NONE} Example : ./setup.sh -d domain.com -u username -p password"
    exit 3
fi

if ! [[ "$username" =~ ^[[:alnum:]]+$ ]];
then
    echo -e "${C_RED}[ERROR]${C_NONE} -u | --username argument is not valid. Please only use alphanumeric characters..."
    exit 4
fi

if [ -z "$password" ];
then
    echo -e "${C_RED}[ERROR]${C_NONE} Please provide '-p | --password' argument.\n${C_GREEN}[HELP]${C_NONE} Example : ./setup.sh -d domain.com -u username -p password"
    exit 5
fi
        
cd $(dirname $0)

apt update -y >/dev/null
DEBIAN_FRONTEND=noninteractive apt upgrade -y >/dev/null

echo -e "[1/13] Installing Ubuntu UFW Firewall..."

apt install ufw -y

echo -e "[2/13] Setting up Ubuntu UFW Firewall..."

ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 25/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 587/tcp
ufw allow 465/tcp
ufw allow 143/tcp
ufw allow 993/tcp
ufw allow 110/tcp
ufw allow 995/tcp

yes | sudo ufw enable

echo -e "[3/13] Installing Apache2 web server..."

apt install apache2 -y

echo -e "[4/13] Setting up Apache2 web server..."

hostnamectl set-hostname mail.$domain

cp -f mail-default.conf /etc/apache2/sites-available/mail-default.conf
sed -i "s/example.com/$domain/g" /etc/apache2/sites-available/mail-default.conf

mkdir /var/www/mail.$domain
chown www-data:www-data /var/www/mail.$domain -R

a2ensite mail-default.conf
systemctl reload apache2
        
echo -e "[5/13] Installing Lets Encrypt SSL Certbot..."

apt install snapd -y

apt-get remove certbot -y
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

echo -e "[6/13] Setting up Lets Encrypt SSL Certbot..."

systemd-resolve --flush-caches
systemctl restart systemd-resolved

ipv4=$(wget -T 5 -t 5 -qO- https://ipv4.seeip.org)

while :
    do
        record=$(host -t a mail.$domain)

        if [[ $record == *"$ipv4"* ]]; then
            break;
        fi
    
        echo -e "Waiting 10 seconds for DNS records to be resolved by the network..."
    
        sleep 10s
done

certbot --apache --non-interactive --agree-tos --redirect --hsts --staple-ocsp -m $username@$domain -d mail.$domain

echo -e "[7/13] Installing Postfix MTA SMTP Server..."

apt install debconf -y
debconf-set-selections <<< "postfix postfix/mailname string $domain"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt install postfix -y
apt install postfix-policyd-spf-python -y

echo -e "[8/13] Setting up Postfix MTA SMTP Server..."

mkdir /usr/local/etc/postfix
cp -f master.cf /etc/postfix/master.cf
cp -f main.cf /etc/postfix/main.cf
sed -i "s/example.com/$domain/g" /etc/postfix/main.cf
cp -f header_checks /etc/postfix/header_checks
postmap /etc/postfix/header_checks

systemctl reload postfix

echo -e "[9/13] Installing Dovecot POP3 and IMAP Server..."

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt install dovecot-core dovecot-imapd dovecot-pop3d -o DPkg::Options::="--force-confnew" -y

echo -e "[10/13] Setting up Dovecot POP3 and IMAP Server..."

cp -f dovecot.conf /etc/dovecot/dovecot.conf
cp -f 10-mail.conf /etc/dovecot/conf.d/10-mail.conf
cp -f 10-auth.conf /etc/dovecot/conf.d/10-auth.conf
cp -f 10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf

sed -i "s/example.com/$domain/g" /etc/dovecot/conf.d/10-ssl.conf

cp -f 10-master.conf /etc/dovecot/conf.d/10-master.conf
cp -f 15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf

adduser dovecot mail
systemctl restart dovecot
systemctl restart postfix

(crontab -l ; echo "@daily certbot renew --quiet && systemctl reload postfix dovecot apache2") | sort - | uniq - | crontab -
cp -f restart.conf /etc/systemd/system/dovecot.service.d/restart.conf
systemctl daemon-reload

echo -e "[11/13] Installing OpenDKIM package..."

apt install opendkim opendkim-tools -o DPkg::Options::="--force-confnew" -y

echo -e "[12/13] Setting up OpenDKIM package..."

gpasswd -a postfix opendkim

cp -f opendkim.conf /etc/opendkim.conf

mkdir /etc/opendkim
chown -R opendkim:opendkim /etc/opendkim

mkdir /etc/opendkim/keys
chmod go-rw /etc/opendkim/keys

cp -f signing.table /etc/opendkim/signing.table
sed -i "s/example.com/$domain/g" /etc/opendkim/signing.table

cp -f key.table /etc/opendkim/key.table
sed -i "s/example.com/$domain/g" /etc/opendkim/key.table

cp -f trusted.hosts /etc/opendkim/trusted.hosts
sed -i "s/example.com/$domain/g" /etc/opendkim/trusted.hosts

mkdir /etc/opendkim/keys/$domain
opendkim-genkey -b 2048 -d $domain -D /etc/opendkim/keys/$domain -s default -v
chown opendkim:opendkim /etc/opendkim/keys/$domain/default.private

mkdir /var/spool/postfix/opendkim
chown opendkim:postfix /var/spool/postfix/opendkim

cp -f opendkim /etc/default/opendkim

systemctl restart opendkim
systemctl restart postfix

echo -e "[13/13] Adding $username user to access the mail server..."

useradd -m $username
echo "$username:$password" | chpasswd
echo "DenyUsers $username" >> /etc/ssh/sshd_config
service ssh restart

dkim=$(cat /etc/opendkim/keys/$domain/default.txt | tr -d '\\n' | sed 's/ //g' | sed -e 's/.*(//;s/);.*//' | tr -d '\" \\t')

echo
echo -e "DKIM : $dkim"
echo 
echo -e "${C_YELLOW}[SMTP]${C_NONE}"
echo 
echo "Host : mail.$domain"
echo "Port : 465"
echo "Protocol : STARTTLS (Min : TLS 1.2)"
echo 
echo -e "${C_YELLOW}[POP3]${C_NONE}"
echo 
echo "Host : mail.$domain"
echo "Port : 110"
echo "Protocol : STARTTLS (Min : TLS 1.2)"
echo 
echo -e "${C_YELLOW}[IMAP]${C_NONE}"
echo 
echo "Host : mail.$domain"
echo "Port : 993"
echo "Protocol : STARTTLS (Min : TLS 1.2)"
echo 
echo -e "${C_YELLOW}Credentials${C_NONE}"
echo "=================================="
echo
echo "Email    : $username@$domain"
echo "Username : $username"
echo "Password : $password"

exit
