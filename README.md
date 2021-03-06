# checkcert
Bash script to check for expired certificates (installed locally or used by a particular website)

## Installation
*checkcert* is installed d by cloning this repo and running the install script.
```
git clone git@github.com:Bank-Builder/checkcert.git
./install.sh
```
## Using checkcert

> $ checkcert --help

```
Usage: checkcert [OPTION]...
   Checks the locally installed certificates found in /etc/ssl/certs/
   and lets you know if they have expired or when they are going to.
   The same can be done to check any given external website by using the -w flag.
 
  OPTIONS:
    -x     --expired   list only expired certificates
    -w     --web       the url of the website to be checked instead of doing internal check
    -e,    --mail     the email to use to send output as notification if expired
    -s,    --silent    does not display results but exits with code 5 if expired
           --help      display this help and exit
           --version   display version and exit

   *One of these options must be selected

  EXAMPLE(s):
      checkcert -w cyber-mint.com -x
           will check the SSL/TLS certificate of 'cyber-mint.com' and respond only if the certificate is expired
```

> checkcert -w cyber-mint.com

The example above might yield something like:
```
checkcert version 0.1
======================
Checking website: cyber-mint.com
cyber-mint.com valid until: 2020-06-02
```

and using on your local host might yield something a bit more like:

> checkcert -x

```
checkcert version 0.1
======================
/etc/ssl/certs/5c44d531.0 expired on: 2020-03-25
/etc/ssl/certs/812e17de.0 expired on: 2019-07-9
/etc/ssl/certs/Certplus_Class_2_Primary_CA.pem expired on: 2019-07-6
/etc/ssl/certs/Deutsche_Telekom_Root_CA_2.pem expired on: 2019-07-9
/etc/ssl/certs/f060240e.0 expired on: 2019-07-6
/etc/ssl/certs/Staat_der_Nederlanden_Root_CA_-_G2.pem expired on: 2020-03-25
```

## Automating checkcert in crontab
First follow the steps needed to setup the ability to send an email notification with sendmail:
* [Setting up *msmtp* for sendmail functionality](./msmtp/README.md)
and then we can add an entry to crontab as follows:

> sudo crontab -e

and then add a line according to your requirements:
```
*     *     *     *     1     checkcert --expired -s -w example.com --mail user@gmail.com
```
which will run the checkcert once a week and send an email only if there is a result

## Bash exit codes
If you wanted to use *checkcert* in a bash file it may be helpful to know these exits codes.
```
0 - normal or succesful exit
5 - invalid certificate on website
6 - invalid URL for website
7 - missing email address for -e|--mail flag
8 - missing website URL for -w|--web flag
```

---
Copyright&copy; 2020, Andrew Turpin. The software is licensed under the MIT License.
