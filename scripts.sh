#!/bin/bash

if [[ $USER != 'root' ]]; then
	echo "Sorry.. Need root access for launch this script."
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx-xxxxxxxxx/$MYIP/g";
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [ "$ether" = "" ]; then
        ether=eth0
fi

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

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
#apt-get -y autoremove;

# update
apt-get update;apt-get -y upgrade;

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
#apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i $ether
service vnstat restart

# install screenfetch
cd
wget 'http://anekascript.anekavps.us:81/Debian7/screenfetch-dev'
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false youree82
echo "randomuser:$PASS" | chpasswd
echo "randomuser" >> pass.txt
echo "$PASS" >> pass.txt
cp pass.txt /home/vps/public_html/
rm -f /root/pass.txt
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw "http://anekascript.anekavps.us:81/Debian7/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "http://anekascript.anekavps.us:81/Debian7/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port 80' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
#apt-get -y update
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart;

# install squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "http://anekascript.anekavps.us:81/Debian7/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

cd
wget -O /usr/bin/user-expire "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/userexpired.sh"
wget -O /usr/bin/user-limit "https://raw.githubusercontent.com/satriaajiputra/debian7os/master/userlimit.sh"


chmod +x /usr/bin/user-expire
chmod +x /usr/bin/user-limit

echo "00 1 * * * root /usr/bin/user-expire" > /etc/cron.d/user-expire
#echo "@reboot root /usr/bin/user-limit" > /etc/cron.d/user-limit
echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "* * * * * root service dropbear restart" > /etc/cron.d/dropbear
#echo "@reboot root /usr/bin/autokill" > /etc/cron.d/autokill
#sed -i '$ i\screen -AmdS check /root/autokill' /etc/rc.local

# finishing
service cron restart
service vnstat restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
cd
rm -f /root/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "=======================================================" | tee -a log-install.txt
echo "Service :" | tee -a log-install.txt
echo "---------" | tee -a log-install.txt
echo "OpenSSH  : 22, 143" | tee -a log-install.txt
echo "Dropbear : 443, 110, 109" | tee -a log-install.txt
echo "Squid3   : 80, 8000, 8080, 3128 (limit to IP $MYIP)" | tee -a log-install.txt
#echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)" | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Tools :" | tee -a log-install.txt
echo "-------" | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, rkhunter, nethogs: nethogs $ether" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Script :" | tee -a log-install.txt
echo "--------" | tee -a log-install.txt
echo "screenfetch" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Other feature :" | tee -a log-install.txt
echo "------------" | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)" | tee -a log-install.txt
echo "Fail2Ban : [on]" | tee -a log-install.txt
echo "IPv6     : [off]" | tee -a log-install.txt
#echo "Autolimit 2 bitvise per IP to all port (port 22, 143, 109, 110, 443, 1194, 7300 TCP/UDP)" | tee -a log-install.txt
echo "Auto Lock User Expire every 00:00 hours" | tee -a log-install.txt
echo "VPS AUTO REBOOT EVERY 12 HOURS" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Thanks to Original Creator Kang Arie & Mikodemos" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Log --> /root/log-install.txt" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Reboot your vps now using command : reboot !" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
cd ~/
rm -f /root/debian7.sh
rm -f /root/IP
