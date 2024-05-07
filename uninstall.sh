#! /bin/bash

AppName=huiontablet
AppDir=huiontablet

echo "close core"
sudo killall huionCore >/dev/null 2>&1
echo "close tablet"
sudo killall huiontablet >/dev/null 2>&1

pid=`ps -e|grep $AppName`

#uninstall app
sysAppDir=/usr/lib/$AppName
if [ -d "$sysAppDir" ]; then
	str=`rm -rf $sysAppDir`
	if [ "$str" !=  "" ]; then 
		echo "$str";
	fi
fi


#uninstall shortcut
sysDesktopDir=/usr/share/applications
sysAppIconDir=/usr/share/icons
sysAutoStartDir=/etc/xdg/autostart

appDesktopName=$AppName.desktop
appIconName=$AppName.png
if [ -f "$sysDesktopDir/$appDesktopName" ]; then
	str=`rm $sysDesktopDir/$appDesktopName`
	if [ "$str" !=  "" ]; then 
		echo "$str";
	fi
fi

if [ -f $sysAppIconDir/$appIconName ]; then
	str=`rm $sysAppIconDir/$appIconName`
	if [ "$str" !=  "" ]; then 
		echo "$str";
	fi
fi

if [ -f $sysAutoStartDir/$appDesktopName ]; then
	str=`rm $sysAutoStartDir/$appDesktopName`
	if [ "$str" !=  "" ]; then 
		echo "$str";
	fi
fi

echo "Uninstallation Succeeded ！"
echo "驱动卸载成功 !"

