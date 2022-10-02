#!/usr/bin/env bash

INSTALL_DIR=/opt/ocservapi

################# INSTALL PRE REQUIREMENTS #################
yum install python3 python3-pip python3-devel gcc g++ -y

pip3 install flask

pip3 install uwsgi
############################################################

################## Install OCSERV-API ######################

mkdir -p $INSTALL_DIR

cd .. && mv ocserv-api $INSTALL_DIR && cd $INSTALL_DIR || exit

chmod +x update.sh

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

