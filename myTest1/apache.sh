#!/bin/bash
sudo apt update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2
sudo bash -c 'echo Congratulations! on your first Webserver Installation > /var/www/html/index.html'