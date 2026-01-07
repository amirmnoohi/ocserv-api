#!/usr/bin/env bash

INSTALL_DIR=/opt/ocservapi

################# INSTALL PRE REQUIREMENTS #################
apt update
apt install python3 python3-pip python3-dev build-essential -y

pip3 install flask

pip3 install uwsgi
############################################################

################## Install OCSERV-API ######################

mkdir -p $INSTALL_DIR

cd .. && mv ocserv-api/* $INSTALL_DIR && cd $INSTALL_DIR || exit

chmod +x update.sh

############################################################

############## Install OCSERV-API SERVICE ##################

mv ocserv-api.service /etc/systemd/system

systemctl daemon-reload
############################################################

################## OPEN FIREWALL PORT ######################

ufw allow 8080/tcp

############################################################

################### START OCSERV-API #######################

service ocserv-api start
systemctl enable ocserv-api
############################################################
