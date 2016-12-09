#!/bin/bash

function Welcome()
{
cd /root
clear
printf "                Service Time : " && date -R
echo "            ======================================================";
echo "            |                    serverSpeeder                   |";
echo "            |                                    Debian(Ubuntu)  |";
echo "            |----------------------------------------------------|";
echo "            |                                       -- By .Vicer |";
echo "            ======================================================";
echo "";
rootness;
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

function RscClear()
{
sed -i '/deb cdrom/'d /etc/apt/sources.list
sed -i '/^\s$/'d /etc/apt/sources.list
}

function Check()
{
echo 'Preparatory work...'
Eth=$(ifconfig |grep -B1 "$(wget -qO- ipv4.icanhazip.com)" |awk '/eth/{ print $1 }')
[ -z "$Eth" ] && echo "I Can not find the server pubilc Ethernet! " && exit 1
[ -z $(which apt-get) ] && echo "The shell scripts only support Debian(Ubuntu)!" && exit 1
MyKernel=$(curl -q --progress-bar 'https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/serverSpeeder.txt' |grep "$(uname -r)" |sort -k3 -t '_' |tail -n 1)
[ -z "$MyKernel" ] && echo "The shell scripts only support some kernel released for Debian(Ubuntu)!" && exit 1
pause;
}

function SelectKernel()
{
KNA=$(echo $MyKernel |awk -F '/' '{ print $1 }') && [ -z $KNA ] && Unstall && echo "Error,Not Found! " && exit 1
KNN=$(echo $MyKernel |awk -F '/' '{ print $2 }') && [ -z $KNN ] && Unstall && echo "Error,Not Found! " && exit 1
KNK=$(echo $MyKernel |awk -F '/' '{ print $3 }') && [ -z $KNK ] && Unstall && echo "Error,Not Found! " && exit 1
KNV=$(echo $MyKernel |awk -F '/' '{ print $5 }') && [ -z $KNV ] && Unstall && echo "Error,Not Found! " && exit 1
wget --no-check-certificate -q -O "/root/appex/apxfiles/bin/acce-$KNV-[$KNA_$KNN_$KNK]" "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/$MyKernel"
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
exit 0
}

function Unstall()
{
update-rc.d serverSpeeder disable >/dev/null 2>&1
rm -rf /etc/serverSpeeder.conf >/dev/null 2>&1
rm -rf /etc/rc2.d/S01serverSpeeder >/dev/null 2>&1
rm -rf /etc/rc3.d/S01serverSpeeder >/dev/null 2>&1
rm -rf /etc/rc5.d/S01serverSpeeder >/dev/null 2>&1
chattr -R -i /appex >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
rm -rf /root/appex* >/dev/null 2>&1
echo 'serverSpeeder have been removed! '
exit 0
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
RscClear && apt-get -qq update && [ $? != '0' ] && Unstall && echo 'Error! ' && exit 1
[ -z $(which unzip) ] && apt-get install -qq -y unzip
[ -z $(which ethtool) ] && apt-get install -qq -y ethtool 
[ -z $(which ethtool) ] && Unstall && echo "First, You should install ethtool manually! " && exit 1
[ -n $(which ethtool) ] && ethtooldir=$(which ethtool)
wget --no-check-certificate -q -O "/root/appex.zip" "https://raw.githubusercontent.com/0oVicero0/serverSpeeser_Install/master/appex.zip"
mkdir -p /root/appex
unzip -o -d /root/appex /root/appex.zip
SelectKernel;
APXEXE=$(ls -1 /root/appex/apxfiles/bin |grep 'acce-')
sed -i "s/^accif\=.*/accif\=\"$Eth\"/" /root/appex/apxfiles/etc/config
sed -i "s/^apxexe\=.*/apxexe\=\"\/appex\/bin\/$APXEXE\"/" /root/appex/apxfiles/etc/config
}

[ $# == '1' ] && [ "$1" == 'install' ] && Install;
[ $# == '1' ] && [ "$1" == 'unstall' ] && Welcome && pause && Unstall;
echo -ne "Usage:\n     bash $0 [install|unstall]\n"

