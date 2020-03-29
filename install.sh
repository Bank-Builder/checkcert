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
    sudo chmod +x /usr/bin/checkcert
    sudo mkdir -p /var/lib/checkcert
    sudo cp -r ./* /var/lib/checkcert/.

    echo "Installation complete. See /var/lib/checkcert/README.md for instructions."
    echo "Run 'checkcert --help' for help"
    echo ""
}

function ckcert_uninstall {
    echo "Removing checkcert installation..."
    sudo rm /usr/bin/checkcert
    sudo rm -r /var/lib/checkcert
    echo ""    
}

# Main

if [ "$1" == "" ]; then
    ckcert_install
    exit 0;
else
    if [ "$1" == "--uninstall" ]; then
        ckcert_uninstall
        exit 0;
    fi        
fi
echo "Usage: ./install.sh [OPTION]..."
echo "  Installs or uninstalls checkcert from your system."
echo " "
echo "    OPTIONS:"
echo "      [none]        performs normal installation"
echo "      --uninstall   will completely uninstall the application"
echo ""
exit 1

