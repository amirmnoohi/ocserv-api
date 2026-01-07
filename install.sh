#!/usr/bin/env bash

set -e

INSTALL_DIR=/opt/ocservapi
VENV_DIR=$INSTALL_DIR/venv

################# DETECT OS TYPE #################
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_ID_LIKE=$ID_LIKE
    elif [ -f /etc/redhat-release ]; then
        OS_ID="rhel"
    elif [ -f /etc/debian_version ]; then
        OS_ID="debian"
    else
        echo "Unsupported operating system"
        exit 1
    fi

    # Determine package manager
    if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_ID_LIKE" == *"debian"* ]]; then
        PKG_MANAGER="apt"
    elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "fedora" || "$OS_ID_LIKE" == *"rhel"* || "$OS_ID_LIKE" == *"fedora"* ]]; then
        PKG_MANAGER="yum"
    else
        echo "Unsupported operating system: $OS_ID"
        exit 1
    fi

    echo "Detected OS: $OS_ID (using $PKG_MANAGER)"
}
##################################################

################# INSTALL PRE REQUIREMENTS #################
install_dependencies() {
    if [ "$PKG_MANAGER" == "apt" ]; then
        apt update
        apt install python3 python3-pip python3-venv python3-dev build-essential -y
    else
        yum install python3 python3-pip python3-devel gcc gcc-c++ -y
    fi
}
############################################################

################## Install OCSERV-API ######################
install_app() {
    mkdir -p $INSTALL_DIR

    cp -r . $INSTALL_DIR
    cd $INSTALL_DIR || exit

    chmod +x update.sh
}
############################################################

################# CREATE VIRTUAL ENVIRONMENT ###############
setup_venv() {
    python3 -m venv $VENV_DIR
    $VENV_DIR/bin/pip install --upgrade pip
    $VENV_DIR/bin/pip install flask uwsgi
}
############################################################

############## Install OCSERV-API SERVICE ##################
install_service() {
    cp ocserv-api.service /etc/systemd/system/ocserv-api.service

    # Update service file to use venv uwsgi
    sed -i "s|/usr/local/bin/uwsgi|$VENV_DIR/bin/uwsgi|g" /etc/systemd/system/ocserv-api.service

    systemctl daemon-reload
}
############################################################

################## OPEN FIREWALL PORT ######################
configure_firewall() {
    if [ "$PKG_MANAGER" == "apt" ]; then
        if command -v ufw &> /dev/null; then
            ufw allow 8080/tcp
        fi
    else
        if command -v firewall-cmd &> /dev/null; then
            firewall-cmd --permanent --add-port=8080/tcp
            firewall-cmd --reload
        fi
    fi
}
############################################################

################### START OCSERV-API #######################
start_service() {
    systemctl enable ocserv-api
    service ocserv-api start
}
############################################################

################### MAIN #######################
main() {
    echo "=== OCSERV-API Installation ==="
    
    detect_os
    
    echo "Installing dependencies..."
    install_dependencies
    
    echo "Installing application..."
    install_app
    
    echo "Setting up Python virtual environment..."
    setup_venv
    
    echo "Installing systemd service..."
    install_service
    
    echo "Configuring firewall..."
    configure_firewall
    
    echo "Starting service..."
    start_service
    
    echo "=== Installation complete ==="
    echo "API is running at http://localhost:8080"
}

main
