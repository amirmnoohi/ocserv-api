#!/usr/bin/env bash

INSTALL_DIR=/opt/ocservapi
VENV_DIR=$INSTALL_DIR/venv

################# INSTALL PRE REQUIREMENTS #################
apt update
apt install python3 python3-pip python3-venv python3-dev build-essential -y

############################################################

################## Install OCSERV-API ######################

mkdir -p $INSTALL_DIR

cp -r . $INSTALL_DIR
cd $INSTALL_DIR || exit

chmod +x update.sh

############################################################

################# CREATE VIRTUAL ENVIRONMENT ###############

python3 -m venv $VENV_DIR
$VENV_DIR/bin/pip install --upgrade pip
$VENV_DIR/bin/pip install flask uwsgi

############################################################

############## Install OCSERV-API SERVICE ##################

cp ocserv-api.service /etc/systemd/system/ocserv-api.service

# Update service file to use venv uwsgi
sed -i "s|/usr/local/bin/uwsgi|$VENV_DIR/bin/uwsgi|g" /etc/systemd/system/ocserv-api.service

systemctl daemon-reload
############################################################

################## OPEN FIREWALL PORT ######################

ufw allow 8080/tcp

############################################################

################### START OCSERV-API #######################

service ocserv-api start
systemctl enable ocserv-api
############################################################
