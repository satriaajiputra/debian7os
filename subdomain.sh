#!/bin/bash

echo -n "Pertama-tama masukan nama subdomain, misalkan project.idweb.id"
echo -n "Masukan subdomain 	:"
read sudomain

echo -n "..."
echo -n "Sedang membuat direktori"
mkdir /home/$subdomain/public_html
mkdir /home/$subdomain/logs

echo -n "Sedang mengatur configurasi NGINX"
echo -n "..."

wget -O /etc/nginx/conf.d/$subdomain.conf
sed -i 's/subdomaindisini/$subdomain/g' /etc/nginx/conf.d/$subdomain.conf

echo -n "Pembuatan konfigurasi dan folder telah selesai"
echo -n "Sistem akan melakukan restart pada NGINX dan PHP"
echo -n "restarting ..."

service nginx restart
service php-fpm restart
