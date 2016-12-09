#!/bin/bash
function Welcome()
{
cd /root
clear
printf "                Service Time : " && date -R
echo "            ======================================================";
echo "            |                    serverSpeeder                   |";
echo "            |                                          Debian 7  |";
echo "            |                                           3.2.0-4  |";
echo "            |----------------------------------------------------|";
echo "            |                                       -- By .Vicer |";
echo "            ======================================================";
echo "";
}

function rootness()
{
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
}

function pause()
{
read -n 1 -p "Press Enter to Continue..." INP
if [ "$INP" != '' ] ; then
echo -ne '\b \n'
echo "";
fi
}

function Clear()
{
chattr -R -i /appex >/dev/null 2>&1
chattr -R -i /serverSpeeder >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
rm -rf /serverSpeeder >/dev/null 2>&1
sed -i '/deb cdrom/'d /etc/apt/sources.list
sed -i '/^$/'d /etc/apt/sources.list
}

function Check()
{
echo 'Preparatory work...'
Eth=$(ifconfig |grep -B1 "$(wget -qO- ipv4.icanhazip.com)" |awk '/eth/{ print $1 }')
[ -z "$Eth" ] && echo "I Can not find the server pubilc Ethernet! " && exit 1
MyKernel=$(uname -r| grep -E "3.2.0-4-amd64|3.2.0-4-686-pae")
[ -z "$MyKernel" ] && echo "The shell scripts only support Debian 7 (3.2.0-4) !" && exit 1
echo 'ok! ' && pause;
}

function ETHER()
{
ifconfig |grep -B1 "$IPv4" |awk '/eth/{ print $1 }'
}

function SelectKernel()
{
if [[ $MyKernel == "3.2.0-4-686-pae" ]]; then
wget --no-check-certificate -q -O "/root/appex/apxfiles/bin/acce-3.10.61.0-[Debian_7_3.2.0-4-686-pae]" "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/Debian/7/3.2.0-4-686-pae/x32/3.10.61.0/serverspeeder_2623"
elif [[ $MyKernel == "3.2.0-4-amd64" ]]; then
wget --no-check-certificate -q -O "/root/appex/apxfiles/bin/acce-3.10.61.0-[Debian_7_3.2.0-4-amd64]" "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/Debian/7/3.2.0-4-amd64/x64/3.10.61.0/serverspeeder_2626"
else

fi
}

function dl-Lic()
{
chattr -R -i /appex >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
mkdir -p /appex/etc
MAC=`ifconfig $Eth | awk '/HWaddr/{ print $5 }'`
wget --no-check-certificate -q -O /appex/etc/apx.lic "http://serverspeeder.azurewebsites.net/lic?mac=$MAC"
SIZE=`du -b /appex/etc/apx.lic |awk '{ print $1 }'`
if [[ $SIZE == '0' ]]; then
echo "Lic download error, try again! "
echo "Please wait..."
sleep 7;
dl-Lic;
else
echo "Lic download success! "
chattr +i /appex/etc/apx.lic
Install-serverspeeder;
fi
}

function ServerSpeeder()
{
if [[ `which unzip` == "" ]]; then
apt-get update
apt-get install -y unzip zip
fi
wget --no-check-certificate -q -O /root/appex.zip https://raw.githubusercontent.com/0oVicero0/serverSpeeser_Install/master/appex.zip
mkdir -p /root/appex
unzip -o -d /root/appex /root/appex.zip
SelectKernel;
APXEXE=`du -a /root/appex/apxfiles/bin |awk -F "/" '/acce/{ print $6 }'`
sed -i "s/^apxexe\=.*/apxexe\=\"\/appex\/bin\/$APXEXE\"/" /root/appex/apxfiles/etc/config
HOSTS=`cat /etc/hosts | grep 'dl.serverspeeder.com' | awk '{print $1}'`
if [[ "$HOSTS" != $serverip ]]; then
echo " " >> /etc/hosts
echo "$serverip	$serverip dl.serverspeeder.com" >> /etc/hosts
fi
HOSTS=`cat /etc/hosts | grep 'my.serverspeeder.com' | awk '{print $1}'`
if [[ "$HOSTS" != "127.0.0.1" ]]; then
echo "127.0.0.1 my.serverspeeder.com" >> /etc/hosts
fi
HOSTS=`cat /etc/hosts | grep 'www.serverspeeder.com' | awk '{print $1}'`
if [[ "$HOSTS" != "127.0.0.1" ]]; then
echo "127.0.0.1 www.serverspeeder.com" >> /etc/hosts
fi
dl-Lic;
}

function Install-ethtool()
{
ethtooldir=`which ethtool`
if [[ "$ethtooldir" != "" ]]; then
rm -rf /appex/bin/ethtool >/dev/null 2>&1
mkdir -p /appex/bin
cp -f $ethtooldir /appex/bin
chmod -R +X /appex >/dev/null 2>&1
else
apt-get install -y -qq ethtool >/dev/null 2>&1
Install-ethtool;
fi
}

function Install-serverspeeder()
{
Install-ethtool;
bash /root/appex/install.sh
}

Welcome;
rootness;
Clear;
ServerIP;
ServerSpeeder;
rm -rf /root/appex* >/dev/null 2>&1
clear
bash /appex/bin/serverSpeeder.sh status
