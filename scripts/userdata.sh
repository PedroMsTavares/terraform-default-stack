#!/bin/sh

sudo apt install software-properties-common -y
sudo apt-add-repository ppa:webupd8team/java -y
sudo apt-get update -y
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y nginx git oracle-java8-installer maven git
sudo service nginx stop
mkdir /app

git clone https://github.com/spring-projects/spring-boot.git /app/spring-boot

cd /app/spring-boot/spring-boot-samples/spring-boot-sample-tomcat

mvn package


echo "
[Unit]
Description=Spring Boot HelloWorld
After=syslog.target
After=network.target[Service]
User=username
Type=simple

[Service]
ExecStart=/usr/bin/java -jar /app/spring-boot/spring-boot-samples/spring-boot-sample-tomcat/target/spring-boot-sample-tomcat-2.1.0.BUILD-SNAPSHOT.jar
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=helloworld

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/helloworld.service

service helloworld start

rm -f /etc/nginx/sites-enabled/default


echo "
server {
        listen 80;
        listen [::]:80;

        location / {
             proxy_pass http://localhost:8080/;
             proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
             proxy_set_header X-Forwarded-Proto \$scheme;
             proxy_set_header X-Forwarded-Port \$server_port;
        }
}
" > /etc/nginx/conf.d/helloworld.conf

sudo service nginx start
