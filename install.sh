#!/bin/bash
#-----------------------------------------------------------------------
# Copyright (c) 2019, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
#-----------------------------------------------------------------------

# Installs checkcert.sh to /usr/bin and sets up crontab to check and notify
# a sysadmin if there are certificates about to expire or which have expired.
# This installs the rest of the solution to /var/lib/checkcert and 
# the config to /etc/checkcert.conf

function ckcert_install {
    echo "Install dependencies ..."
    sudo apt install msmtp
    sudo cp ./checkcert.sh /usr/bin/checkcert
    sudo chmod +x /usr/bin/checkcert.sh
    sudo mkdir -p /var/lib/checkcert
    sudo cp ./* /var/lib/checkcert/.
    #sudo cp ./checkcert.conf /etc/checkcert.conf
    echo "Installation complete ... edit /etc/checkcert.conf to suit your needs"
    ls /var/lib/checkcert/*
    echo ""
}

function ckcert_remove {
    echo "Removing checkcert installation..."
}

# Main

ckcert_install


