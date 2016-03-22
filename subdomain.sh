#!/bin/bash

echo -e "Pertama-tama masukan nama subdomain, misalkan project.idweb.id"
read -p "Masukan subdomain: " subdomain

echo -e "..."
echo -e "Sedang membuat direktori"
cd /home
mkdir $subdomain
mkdir $subdomain/public_html
mkdir $subdomain/logs

echo -e "Sedang mengatur configurasi NGINX"
echo -e "..."

wget -O /etc/nginx/conf.d/$subdomain.conf "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/confnginx.conf"
sed -i 's/subdomaindisini/$subdomain/g' /etc/nginx/conf.d/$subdomain.conf

echo -e "Pembuatan konfigurasi dan folder telah selesai"
echo -e "Sistem akan melakukan restart pada NGINX dan PHP"
echo -e "restarting ..."

service nginx restart
service php-fpm restart
