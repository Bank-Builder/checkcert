#!/bin/bash
#-----------------------------------------------------------------------
# Copyright (c) 2019, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
#-----------------------------------------------------------------------

# Globals
_version="0.2"
_silent="0"
_today="$(date +%s)"
_certPath="/etc/ssl/certs/"
_x="0"
_e="0"
_sendEmail=""
_w="0"
_webSite=""



function displayHelp(){
    echo "Usage: checkcert [OPTION]...";
    echo "   Checks the locally installed certificates found in /etc/ssl/certs/";
    echo "   and lets you know if they have expired or when they are going to.";
    echo "   The same can be done to check any given external website by using the -w flag.";
    echo " ";
    echo "  OPTIONS:";
    
    echo "    -x     --expired   list only expired certificates";
    echo "    -w     --web       the url of the website to be checked instead of doing internal check";
    echo "    -e,    --mail     the email to use to send output as notification if expired";    
    echo "    -s,    --silent    does not display results but exits with code 5 if expired";
    echo "           --help      display this help and exit";
    echo "           --version   display version and exit";
    echo "";
    echo "   *One of these options must be selected";
    echo "";
    echo "  EXAMPLE(s):";
    echo "      checkcert -w cyber-mint.com -x";
    echo "           will check the SSL/TLS certificate of 'cyber-mint.com' and respond only if the certificate is expired";
    echo "";
}

function msg(){
    if [ "$_silent" != "1" ]; then echo -e "$*"; fi
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
    echo "Copyright (C) 2020, Andrew Turpin";
    echo "License MIT: https://opensource.org/licenses/MIT";
    echo "";
}

function displayResult() {
    if [ "$_silent" != "1" ]; then echo -e "$*"; fi
    email='"Subject: checkcert\n\n'$*'\n------\ncheckcert ver: '$_version' - https://github.com/Bank-Builder/checkcert\n"'
    
    if [ "$_sendEmail" != "" ]; then
            s="printf "$email" | sendmail $_sendEmail 2>/dev/null"
            eval "$s" > /dev/null 2>&1
    fi
}

function evalCertEnddate(){
# $1 = certificate name
# $2 = endate as yyyy-mm-dd
# returns a string based on -x|-v flags
    enddate=$(date -d "$2" +%s)
    if [ "$_today" -ge "$enddate" ]; then
        echo "$1 expired on: "$endate
        return 1
    fi    
    
    if [ "$_today" -lt "$enddate" ]; then
        diff=$(( $enddate - $_today ))
        left="$(($diff / 3600 / 24)) days $(($diff % (3600 / 24 ) )) hrs, $((($diff / 60) % 60)) mins and $(($diff % 60)) secs left." 
        echo "$1 valid until: "$(date -d @$enddate +"%Y-%m-%d")
        return 0
    fi  
}

function checkInternalCerts {
    body=""
    for cert in /etc/ssl/certs/* ; do
        endatestr=$(openssl x509 -noout -enddate -in $cert)
        endate=$(dateFromX509 "$endatestr")
        b=$(evalCertEnddate "$cert" "$endate")
        _result=$?
          
        #show in accordance with the -x flag (invalid cert sets $_result=1)
        if [ "$_x" == "1" ] && [ "$_result" == "1" ]; then
            body=$body$b"\n"
        elif [ "$_x" == "0" ];  then
            body=$body$b"\n"
        fi
    done
    displayResult $body
}



function checkWebCert(){
    msg "checkcert version $_version"
    msg "======================"
    msg "Checking website: $1"
    msg ""
    
    w=$(echo "Q"|openssl s_client -connect $_webSite:443 2>/dev/null |& openssl x509 -enddate -inform pem -noout 2>/dev/null)
    endate=$(dateFromX509 "$(echo $w|cut -d '=' -f2 )" )
    if [ "$endate" == "--" ]; then 
        msg "Error: invalid url"
        exit 6
    fi
    
    body=$(evalCertEnddate "$_webSite" "$endate" )
    _result="$?"

    #show in accordance with the -x flag (invalid cert sets $_result=1)
    if [ "$_x" == "1" ] && [ "$_result" == "1" ]; then
        displayResult "$body"
        exit 5
    elif [ "$_x" == "0" ]; then
        displayResult "$body"
    fi
}

# __Main__
while [[ "$#" > 0 ]]; do
    case $1 in
        --help) 
            displayHelp; exit 0;;
        --version) 
            displayVersion; exit 0;;
        -w|--website) 
            _w="1"
            _webSite="$2"
            shift;;
        -x|--expired) 
            _x="1"
            ;;
        -e|--mail) 
            _e="1"
            _sendEmail="$2"
            shift;;                                             
        -s|--silent) 
            _silent="1"
            ;;
         *) echo -e "Unknown parameter passed: $1\nTry 'checkcert --help' for help"; exit 1;;
    esac; 
    shift; 
done


if [ "$_e" == "1" ] && [ "$_sendEmail" == "" ]; then
    echo -e "Missing parameter [email address]\nTry 'checkcert --help' for help"
    exit 7
fi


if [ "$_w" == "1" ]; then
    if [ "$_webSite" != "" ]; then
        checkWebCert "$_webSite"
    else
        echo -e "Missing parameter [website]\nTry 'checkcert --help' for help"
        exit 8       
    fi    
else
    checkInternalCerts
fi

#FINISH

