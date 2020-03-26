#!/bin/bash
#-----------------------------------------------------------------------
# Copyright (c) 2019, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
#-----------------------------------------------------------------------

# Globals
_version="0.1"
_silent="0"
_today="$(date +%s)"
_certPath="/etc/ssl/certs/"
_webSite=""
_expired="0"
_valid="0"

function displayHelp(){
    echo "Usage: checkcert [OPTION]...";
    echo "   Checks the locally installed certificates found in /etc/ssl/certs/";
    echo "   and lets you know if they have expired or when they are going to.";
    echo "   The same can be done to check any given external website.";
    echo " ";
    echo "  OPTIONS:";
    
    echo "    -x|-v, --expired*  list only expired certificates";
    echo "           --valid*    list only valid certificates";
    echo "    -w,    --website   the url of the website to be checked instead of doing internal check";
    echo "    -s,    --silent    does not display results but exit with code 5 if expired";
    echo "           --help      display this help and exit";
    echo "           --version   display version and exit";
    echo "";
    echo "   *One of these options must be selected";
    echo "";
    echo "  EXAMPLE(s):";
    echo "      checkcert -w cyber-mint.com";
    echo "           will check the SSL/TLS certificate of 'cyber-mint.com' and inform if the certifcate is still valid or not";
    echo "";
}

function msg(){
    if [ "$_silent" != "1" ]; then echo "$1"; fi
}

function dateFromX509(){
  d=$(echo $1 |cut -d "=" -f2)
  mmm=$(echo $d|cut -d " " -f1)
  dd=$(echo $d|cut -d " " -f2)
  yy=$(echo $d|cut -d " " -f4)
  
  case $mmm in
    Jan)
      mm="01";;
    Feb)
      mm="02";;
    Mar)
      mm="03";;
    Apr)
      mm="04";;
    May)
      mm="05";;
    Jun)
      mm="06";;
    Jul)
      mm="07";;
    Aug)
      mm="08";;
    Sep)
      mm="09";;
    Oct)
      mm="10";;
    Nov)
      mm="11";;
    Dec)
      mm="12";;
  esac;
  echo $yy"-"$mm"-"$dd
}

function displayVersion(){
    echo "checkcert (bank-builder utils) version $_version";
    echo "Copyright (C) 2019, Andrew Turpin";
    echo "License MIT: https://opensource.org/licenses/MIT";
    echo "";
}

function evalCertEnddate(){
# $1 = certificate name
# $2 = endate as yyyy-mm-dd
# returns a string based on -x|-v flags
    enddate=$(date -d "$2" +%s)
    
    if [ "$_today" -ge "$enddate" ]; then
        
        if [ "$_expired" == "1" ] || [ "$_webSite" != "" ]; then
            msg "$1 expired on: "$endate
            if [ "$_webSite" != "" ] && [ "$_silent" = "1" ];then
                exit 5;
            fi
        fi    
    fi
    if [ "$_today" -lt "$enddate" ]; then
        if [ "$_valid" == "1" ] || [ "$_webSite" != "" ]; then
            diff=$(( $enddate - $_today ))
            left="$(($diff / 3600 / 24)) days $(($diff % (3600 / 24 ) )) hrs, $((($diff / 60) % 60)) mins and $(($diff % 60)) secs left." 
            msg "$1 valid until: "$(date -d @$enddate +"%Y-%m-%d")
            if [ "$_webSite" != "" ] && [ "$_silent" = "1" ];then
                exit 0;
            fi
        fi    
    fi  
}

function checkInternalCerts {
for cert in /etc/ssl/certs/* ; do
  endatestr=$(openssl x509 -noout -enddate -in $cert)
  endate=$(dateFromX509 "$endatestr")
  evalCertEnddate "$cert" "$endate"
done
}

function checkWebCert(){
    if [ "$_silent" == "0" ]; then
      msg "Checking website: $1"
    fi
    w=$(echo "Q"|openssl s_client -connect cyber-mint.com:443 2>/dev/null |& openssl x509 -enddate -inform pem -noout)
    endate=$(dateFromX509 "$(echo $w|cut -d '=' -f2 )" )
    evalCertEnddate "$_webSite" "$endate"
}

# __Main__
while [[ "$#" > 0 ]]; do
    case $1 in
        --help) 
            displayHelp; exit 0;;
        --version) 
            displayVersion; exit 0;;
        -w|--website) 
            _webSite="$2";
            shift;;
        -x|--expired) 
            _expired="1"
            ;;
        -v|--valid) 
            _valid="1"
            ;;                                
        -s|--silent) 
            _silent="1"
            ;;
         *) echo "Unknown parameter passed: $1"; exit 1;;
    esac; 
    shift; 
done


if [ "$_silent" == "0" ]; then 
    msg "checkcert version $_version"
    msg "======================";
fi
       
if [ "$_expired" == "1" ] || [ "$_valid" == "1" ]; then 
    checkInternalCerts
else 
    if [ "$_webSite" != "" ]; then 
        checkWebCert "$_webSite";
    else
        echo "Try checkcert --help for help";
    fi;    
fi

#FINISH

