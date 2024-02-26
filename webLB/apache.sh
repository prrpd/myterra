#!/bin/bash
sudo apt update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2
myip=$(curl http://169.254.169.254/latest/meta-data/)
sudo bash -c 'echo Congratulations! on your first Webserver Installation > /var/www/html/index.html'
sudo bash -c 'echo $myip >> /var/www/html/index.html'
sudo bash -c 'echo V 1 >> /var/www/html/index.html'