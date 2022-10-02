#!/usr/bin/env bash

cd /opt/ocserv-api || exit

git pull

service ocserv-api restart
