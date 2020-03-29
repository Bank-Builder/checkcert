# msmtp SMTP mail client for sendmail compatibility

Having tried *ssmtp* (which no longer works with gmail) and using the reference
from the [Archlinux mtsmtp](https://wiki.archlinux.org/index.php/Msmtp) the following is confirmed to work with smtp.gmail.com.

> *Note*: I create a new gmail account called smtp.printer@gmail.com and I did have to enable 2FA and then I needed to add a Application Password for mail to allow smtp access.

## Personal use with local user:
```
sudo apt install msmtp
nano .msmtprc
```

You can find an example config file at /usr/share/doc/msmtp/examples/msmtprc-system.example
but I just copied and modified the settings as below.

```
# Set default values for all following accounts.
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

# Gmail
account        gmail
host           smtp.gmail.com
port           587
from           smtp.printer@gmail.com
user           smtp.printer@gmail.com
password       *************

# Gmail
# account        anotherprovider
# host           smtp.anotherprovider.net

# Set a default account
account default : gmail
```
Then this did not work because of permissions, so:
```
chmod 600 .msmtprc 
# and take a log in the logfile if something is not working
cat .msmtp.log 

# I make a soft link to sendmail so legacy programs would work without change
sudo ln -s /usr/bin/msmtp /usr/bin/sendmail
```
And finally send a test message to confirm it is working correctly:
```
printf "Subject: test\n\nTesting msmtp from server not user account." | sendmail -v towhomever@gmail.com
```

## Setting mtsmtp up on a server

To get this to work, just install as above using apt then create the following file

```
touch /etc/msmtprc
nano /etc/msmtprc
```

Now paste the config below into the /etc/msmtprc file
```
# Example /etc/msmtprc that works with gmail
account        default
host           smtp.gmail.com

auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

port           587
user           smtp.printer@gmail.com
from           smtp.printer@gmail.com
password       *********

# Syslog logging with facility LOG_MAIL instead of the default LOG_USER.
syslog LOG_MAIL
```

> *Note*: That when using gmail, changing the *from* address has no effect, but msmtp does require the field in the /etc/msmtprc configuration file.

