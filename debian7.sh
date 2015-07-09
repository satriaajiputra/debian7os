#!/bin/sh
apt-get update -y
curl -s -o ip.txt http://satria.asia/ip.txt
IPSAYA=`wget -qO- ipv4.icanhazip.com`
CARI=`grep $IPSAYA ip.txt`
if [ "$CARI" = "" ]
then
echo "Maaf, hubungi admin VPS Workshop untuk menggunakan autoscript"
rm -rf ip.txt
exit
fi

rm -rf ip.txt
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/sources.list.debian7"
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
apt-get -y install -y bmon iftop htop nmap axel nano iptables curl traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar chkconfig rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
vnstat -u -i venet0
else
vnstat -u -i eth0
fi
service vnstat restart

# install screenfetch
cd
wget 'https://raw.githubusercontent.com/satriaajiputra/debian7os/master/screeftech-dev'
mv screeftech-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Satria AJi Putra | ArenaJayaTeknik.com | @Sat_22_99 | 57661D2D</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restartop

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300


# install mrtg
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/mrtg.conf" >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i '/Port 22/a Port  143' /etc/ssh/sshd_config
sed -i '/Port 22/a Port  80' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 110 -p 109/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# upgrade dropbear 2014
apt-get install zlib1g-dev
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2014.66.tar.bz2
bzip2 -cd dropbear-2014.66.tar.bz2  | tar xvf -
cd dropbear-2014.66
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd
else
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd
fi

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# install squid3
apt-get install squid3 -y
mv /etc/squid3/squid.conf squid.txt
curl http://satria.asia/script/squid.conf > /etc/squid3/squid.conf
sed -i "s|my-server-3|$IPSAYA|" /etc/squid3/squid.conf

# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.710_all.deb
dpkg -i --force-all webmin_1.710_all.deb;
apt-get -y -f install;
rm /root/webmin_1.710_all.deb
service webmin restart
service vnstat restart

# speedtest pak
wget -O speedtest-cli https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
chmod +x speedtest-cli
cd /usr/bin/
curl http://satria.asia/script/speedtest.conf > /usr/bin/speed
chmod +x speed

# download script
cd
if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
curl http://script.satria.asia/debian7ovz/user-add > /usr/bin/user-add
curl http://script.satria.asia/debian7ovz/trial > /usr/bin/trial
else
curl http://satria.asia/repo/user-add > /usr/bin/user-add
curl http://satria.asia/repo/trial > /usr/bin/trial
fi
curl http://satria.asia/repo/user-list > /usr/bin/user-list
curl http://satria.asia/repo/monitorport > /usr/bin/monitorport
curl http://satria.asia/repo/dropmon > /usr/bin/dropmon
curl http://satria.asia/repo/user-login > /usr/bin/user-login
curl http://satria.asia/repo/renew > /usr/bin/renew
curl http://satria.asia/repo/minggat > /usr/bin/minggat
curl http://satria.asia/repo/gusur > /usr/bin/gusur
curl http://satria.asia/repo/menu > /usr/bin/menu
wget -O /etc/issue.net "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/banner"
cd /usr/bin
chmod +x user-add
chmod +x user-list
chmod +x user-login
chmod +x renew
chmod +x trial
chmod +x monitorport
chmod +x dropmon
chmod +x minggat
chmod +x gusur
chmod +x menu
cd
chmod +x dropmon
echo "0 0 * * * root /usr/bin/gusur" >> /etc/crontab
service cron restart

# finishing
chown -R www-data:www-data /home/vps/public_html
service cron restart
service nginx start
service php-fpm start
service vnstat restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo ""  | tee -a log-install.txt
echo "AUTOSCRIPT INCLUDES" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$IPSAYA:81/VPN.zip)"  | tee -a log-install.txt
echo "OpenSSH  : 22, 143"  | tee -a log-install.txt
echo "Dropbear : 443, 110, 109"  | tee -a log-install.txt
echo "Squid3   : 8080, 80, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Tools"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel"  | tee -a log-install.txt
echo "bmon"  | tee -a log-install.txt
echo "htop"  | tee -a log-install.txt
echo "iftop"  | tee -a log-install.txt
echo "mtr"  | tee -a log-install.txt
echo "rkhunter"  | tee -a log-install.txt
echo "nethogs: nethogs eth0"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "screenfetch"  | tee -a log-install.txt
echo "screenfetch"  | tee -a log-install.txt
echo "script menu, berguna untuk menampilkan daftar script (menu)"  | tee -a log-install.txt
echo "Tambah User SSH / OpenVPN (user-add)"  | tee -a log-install.txt
echo "Tambah masa aktif SSH / OpenVPN (renew)"  | tee -a log-install.txt
echo "Monitoring user SSH (user-login)"  | tee -a log-install.txt
echo "sh dropmon [port] contoh: sh dropmon 443" | tee -a log-install.txt
echo "Menampilkan list akun (user-list)"  | tee -a log-install.txt
echo "Auto create trial akun (trial)"  | tee -a log-install.txt
echo "Delete expire akun (gusur)"  | tee -a log-install.txtecho ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : https://$IPSAYA:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$IPSAYA:81/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$IPSAYA:81/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "SILAHKAN REBOOT VPS ANDA"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==============================================="  | tee -a log-install.txt
cd
rm -f /root/debian7.sh
