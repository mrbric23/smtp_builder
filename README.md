
# SMTP Builder V3

With this tool you can create a professional and complete mail server with SMTP, IMAP and POP3 protocol without any knowledge in just a few clicks. 

You're sender email address will be signed with all actual security system SPF, DKIM and DMARC and you will obtain a 10 / 10 score on mail-tester.com every time. 

You will be able to mass send emails without any limit.

An online version is available [here](https://smtp-builder.com) with auto DNS management. 

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

- [https://namecheap.com](https://www.kqzyfj.com/j4116vpyvpxCEDDMJFDEDCEIDELKIM) (-50%)

    Avoid spammy words in domain name.

    Choose common TLD to ensure deliverability.

### Step 2. Buy a VPS server :

 - [https://hostwinds.com](https://www.hostwinds.com/30127.html) (cheapest)
 - [https://contabo.com](https://www.kqzyfj.com/a1107kjspjr6877GD978768AEGDBE7) (strongest)

    Only works with Ubuntu 20.04 OS.
    
    Mail ports (25, 465, 587) must be opened.
    
    VPS provider must have an RDNS feature.
    
    Minimum Requirements : 1 vCPU, 1GB RAM.

### Step 3. Configure domain DNS

Remove all DNS Records on your domain name and add the following entries, please note that you need to replace IPv4 / IPv6 by the IP addresses of the VPS server you buyed in previous step :

| Type | Host  | Value |
| :---:   | :-: | :-: |
| A | mail | VPS IPv4 |
| AAAA | mail | VPS IPv6 |

### Step 4. Build your mail server

Connect with SSH on your VPS server and use following command to download the bash script and configuration files. 

```bash
git clone https://github.com/TungKaiYing/smtp_builder/tree/main/build
```

Inside the downloaded directory add execution rights on setup.sh file.

```bash
chmod +x setup.sh
```

Start to build your mail server with this simple command, please replace exemple.com with your actual domain name and username & password with the username and password you want to use to access your mail server.

```bash
./setup.sh -d exemple.com -u yourusername -p yourpassword
```

INFO : Username and password will be used to access the mail server so choose the ones you want.

INFO : Your final sender email address will be username@yourdomain.com.

### Step 5. Configure RDNS / PTR

Configure Reverse DNS (RDNS) or PTR records for both your VPS server's IPv4 and IPv6 addresses on VPS provider website. Ensure that these records point to: mail.example.com.

### Step 6 - Finalize DNS configuration

Elevate domain security and email reliability by adding essential DNS records. Direct emails accurately with an MX record, validate senders via SPF, DMARC, and DKIM records, and bolster overall credibility.

| Type | Host  | Value |
| :---:   | :-: | :-: |
| MX | @ | mail.exemple.com |
| TXT | @ | v=spf1 mx ~all |
| TXT | _dmarc | v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; |
| TXT | default._domainkey | v=DKIM1;h=sha256;k=rsa;p=MIIBIjANBgk... |

Info : The bash script will output the DKIM Key once build is finished. Please replace "v=DKIM1;h=sha256;k=rsa;p=MIIBIjANBgk..." by the actual output of the script.

## TIPS 

You can add more users after setup with this command : useradd -m username (eg. useradd -m contact)

Then define a password with this command : passwd username (eg. passwd contact)

You can warmup your smtp with that tool to have a long term inbox rate : https://www.mailwarm.com/
