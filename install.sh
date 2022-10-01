#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

INSTALL_DIR=/opt/ocservapi

################# INSTALL PRE REQUIREMENTS #################
yum install python3 python3-pip python3-devel gcc g++ -y

pip3 install flask

pip3 install uwsgi
############################################################

################## Install OCSERV-API ######################

mkdir -p $INSTALL_DIR

mv ocservapi.py $INSTALL_DIR

mv wsgi.py $INSTALL_DIR

############################################################

############## Install OCSERV-API SERVICE ##################

mv ocserv-api.service /etc/systemd/system

systemctl daemon-reload
############################################################

################## OPEN FIREWALL PORT ######################

firewall-cmd --permanent --add-port=8080/tcp

firewall-cmd --reload

############################################################

################### START OCSERV-API #######################

service ocserv-api start

############################################################

