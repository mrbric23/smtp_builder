An online version is available [here](https://smtp-builder.com) with auto DNS management and script execution.

# SMTP Builder V3

With this tool you can create a professional and complete mail server with SMTP, IMAP and POP3 protocol easily in just a few clicks. 

You're sender email address will be signed with all actual security system SPF, DKIM and DMARC and you will obtain a 10 / 10 score on mail-tester.com every time. 

You will be able to mass send emails without any limit.

## Features

- ✔ Unlimited emails sending
    
    Send emails without limit.

- ✔ Trusted email sender
    
    SPF, DKIM & DMARC DNS records.

- ✔ Full mail server
    
    SMTP, IMAP and POP3 protocols.

- ✔ SSL trusted certs
    
    Let's encrypt SSL certificate.

- ✔ Hide sensitive informations
    
    Hide personal info in headers.

- ✔ High sending score
    
    10/10 score on mail-tester.com

- ✔ Spoofing header allowed
    
    Change from email header.


## Usage/Examples

### Step 1. Buy a domain name :

- [https://namecheap.com](https://www.tkqlhce.com/gk115mu2-u1HJIIROKIJIHJNMPROJR) (-50%)

> **Note**
Choose common TLD to ensure deliverability.

> **Warning**
Avoid spammy words in domain name. 

### Step 2. Buy a VPS server :

 - [https://hostwinds.com](https://www.hostwinds.com/30127-6.html) (cheapest)
 - [https://contabo.com](https://www.kqzyfj.com/g5102xdmjdl0211A731210248A7581) (strongest)

> **Note**
Only works with Ubuntu 20.04 OS.

> **Note**
Minimum Requirements : 1 vCPU, 1GB RAM.

> **Warning**
Mail ports (25, 465, 587) must be opened.

> **Warning**
VPS provider must have an RDNS feature.

### Step 3. Configure domain DNS

Remove all DNS Records on your domain name and add the following entries, please note that you need to replace IPv4 / IPv6 by the IP addresses of the VPS server you buyed in previous step :

| Type | Host  | Value |
| :---:   | :-: | :-: |
| A | mail | VPS IPv4 |
| AAAA | mail | VPS IPv6 |

> **Note**
AAAA (IPv6) record optional but enhances deliverability.

> **Warning**
DNS resolution can take 48 hours (Usually 10 minutes).

### Step 4. Build your mail server

Connect with SSH on your VPS server and use following command to download the bash script and configuration files. 

```bash
git clone https://github.com/TungKaiYing/smtp_builder
```

Inside the downloaded directory 'smtp_builder/builder' give execution rights to setup.sh file.

```bash
chmod +x setup.sh
```

Start to build your mail server with this simple command, please replace exemple.com with your actual domain name and username & password with the username and password you want to use to access your mail server.

```bash
./setup.sh -d exemple.com -u yourusername -p yourpassword
```

> **Note**
Your final sender email address will be username@yourdomain.com.

### Step 5. Configure RDNS / PTR

Configure Reverse DNS (RDNS) or PTR records for both your VPS server's IPv4 and IPv6 addresses on VPS provider website. Ensure that these records point to: 

```text
mail.yourdomain.com
```

### Step 6 - Finalize DNS configuration

Elevate domain security and email reliability by adding essential DNS records. Direct emails accurately with an MX record, validate senders via SPF, DMARC, and DKIM records, and bolster overall credibility.

| Type | Host  | Value |
| :---:   | :-: | :-: |
| MX | @ | mail.exemple.com |
| TXT | @ | v=spf1 mx ~all |
| TXT | _dmarc | v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; |
| TXT | default._domainkey | v=DKIM1;h=sha256;k=rsa;p=MIIBIjANBgk... |

> **Note**
The bash script will output the DKIM Key once build is finished.

## Tips

You can add more users after setup with this command (eg. useradd -m contact) :

```bash
useradd -m username
```

Then define a password with this command (eg. passwd contact) :

```bash
passwd username
```

You can warmup your smtp with that tool to have a long term inbox rate : https://www.mailwarm.com/
