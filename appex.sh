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
rootness;
Eth=$(ifconfig |grep -B1 "$(wget -qO- ipv4.icanhazip.com)" |awk '/eth/{ print $1 }')
[ -z "$Eth" ] && echo "I Can not find the server pubilc Ethernet! " && exit 1
MyKernel=$(uname -r| grep -E "3.2.0-4-amd64|3.2.0-4-686-pae")
[ -z "$MyKernel" ] && echo "The shell scripts only support Debian 7 (3.2.0-4) !" && exit 1
echo 'ok! ' && pause;
}

function Install()
{
Welcome;
Check;
ServerSpeeder;
dl-Lic;
bash /root/appex/install.sh
rm -rf /root/appex* >/dev/null 2>&1
clear
bash /appex/bin/serverSpeeder.sh status
}

function SelectKernel()
{
if [[ "$MyKernel" == '3.2.0-4-686-pae' ]]; then
wget --no-check-certificate -q -O "/root/appex/apxfiles/bin/acce-3.10.61.0-[Debian_7_3.2.0-4-686-pae]" "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/Debian/7/3.2.0-4-686-pae/x32/3.10.61.0/serverspeeder_2623"
elif [[ "$MyKernel" == '3.2.0-4-amd64' ]]; then
wget --no-check-certificate -q -O "/root/appex/apxfiles/bin/acce-3.10.61.0-[Debian_7_3.2.0-4-amd64]" "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/Debian/7/3.2.0-4-amd64/x64/3.10.61.0/serverspeeder_2626"
fi
}

function dl-Lic()
{
chattr -R -i /appex >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
mkdir -p /appex/etc
mkdir -p /appex/bin
MAC=$(ifconfig "$Eth" |awk '/HWaddr/{ print $5 }')
wget --no-check-certificate -q -O "/appex/etc/apx.lic" "http://serverspeeder.azurewebsites.net/lic?mac=$MAC"
SIZE=$(du -b /appex/etc/apx.lic |awk '{ print $1 }')
if [[ $SIZE == '0' ]]; then
echo "Lic download error, try again! "
echo "Please wait..."
sleep 7;
dl-Lic;
else
echo "Lic download success! "
chattr +i /appex/etc/apx.lic
rm -rf /appex/bin/ethtool >/dev/null 2>&1
cp -f $ethtooldir /appex/bin
fi
}

function ServerSpeeder()
{
apt-get -qq update && [ $? != '0' ] && echo 'Error! ' && exit 1
[ -z $(which unzip) ] && apt-get install -qq -y unzip
[ -z $(which ethtool) ] && apt-get install -qq -y ethtool && ethtooldir=$(which ethtool)
[ -z $(which ethtool) ] && echo "First, You will install ethtool manually! && exit 1
wget --no-check-certificate -q -O "/root/appex.zip" "https://raw.githubusercontent.com/0oVicero0/serverSpeeser_Install/master/appex.zip"
mkdir -p /root/appex
unzip -o -d /root/appex /root/appex.zip
SelectKernel;
APXEXE=$(ls -1 /root/appex/apxfiles/bin |grep 'acce-')
sed -i "s/^accif\=.*/accif\=\"$Eth\"/" /root/appex/apxfiles/etc/config
sed -i "s/^apxexe\=.*/apxexe\=\"\/appex\/bin\/$APXEXE\"/" /root/appex/apxfiles/etc/config
}

Install;
