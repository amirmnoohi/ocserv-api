yum install python3 python3-pip python3-devel gcc g++ -y

pip3 install flask

pip3 install uwsgi

mkdir -p /opt

cd /opt

git clone https://github.com/amirmnoohi/ocserv-api.git

cd ocserv-api

mv ocserv-api.service /etc/systemd/system

mv ocservapi.py /home

mv wsgi.py /home

systemctl daemon-reload

service ocserv-api start

firewall-cmd --permanent --add-port=8080/tcp

firewall-cmd --reload
