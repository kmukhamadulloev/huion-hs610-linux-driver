#! /bin/bash

# cd to current path
dirname=$(dirname "$0")
tmp="${dirname#?}"
if [ "${dirname%$tmp}" != "/" ]; then
    dirname="$PWD/$dirname"
fi

echo "$dirname"
cd "$dirname" || exit

# close driver if it is running
AppName=huiontablet
AppDir=huiontablet
pid=$(ps -e | grep "$AppName")
AppCoreName=huionCore
AppUIName=huiontablet

# Close running driver
sudo killall huionCore >/dev/null 2>&1
sudo killall huiontablet >/dev/null 2>&1

# Copy rule
sysRuleDir="/usr/lib/udev/rules.d"
sysRuleDir2="/lib/udev/rules.d"
appRuleDir=./huion/huiontablet/res/rule
ruleName="20-huion.rules"

if [ -f "$appRuleDir/$ruleName" ]; then
    cp "$appRuleDir/$ruleName" "$sysRuleDir/$ruleName"
    cp "$appRuleDir/$ruleName" "$sysRuleDir2/$ruleName"
else
    echo "Cannot find driver's rules in package"
    exit 1
fi

# install app
sysAppDir="/usr/lib"
appAppDir=./huion/"$AppName"
exeShell="huionCore.sh"

if [ -d "$appAppDir" ]; then
    cp -rf "$appAppDir" "$sysAppDir" || exit
else
    echo "Cannot find driver's files in package"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/$exeShell" ]; then
    chmod +x "$sysAppDir/$AppDir/$exeShell" || exit
else
    echo "Cannot find start script"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/$AppCoreName" ]; then
    chmod +x "$sysAppDir/$AppDir/$AppCoreName" || exit
else
    echo "Cannot find app Core"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/$AppUIName" ]; then
    chmod +x "$sysAppDir/$AppDir/$AppUIName" || exit
else
    echo "Cannot find app UI"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/HuionCore.pid" ]; then
    chmod 666 "$sysAppDir/$AppDir/HuionCore.pid" || exit
else
    echo "Cannot find HuionCore.pid"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/DriverUI.pid" ]; then
    chmod 666 "$sysAppDir/$AppDir/DriverUI.pid" || exit
else
    echo "Cannot find DriverUI.pid"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/log.conf" ]; then
    chmod 666 "$sysAppDir/$AppDir/log.conf" || exit
else
    echo "Cannot find log.conf"
    exit 1
fi

if [ -f "$sysAppDir/$AppDir/huion.log" ]; then
    chmod 666 "$sysAppDir/$AppDir/huion.log" || exit
else
    echo "Cannot find huion.log"
    exit 1
fi

# install shortcut
sysDesktopDir=/usr/share/applications
sysAppIconDir=/usr/share/icons
sysAutoStartDir=/etc/xdg/autostart

appDesktopDir=./huion/xdg/autostart/
appAppIconDir=./huion/icon/
appAutoStartDir=./huion/xdg/autostart/

appDesktopName=$AppName.desktop
appIconName=$AppName.png

if [ -f "$appDesktopDir/$appDesktopName" ]; then
    cp -a "$appDesktopDir/$appDesktopName" "$sysDesktopDir/$appDesktopName" || exit
else
    echo "Cannot find driver's shortcut in package"
    exit 1
fi

if [ -f "$appAppIconDir/$appIconName" ]; then
    cp "$appAppIconDir/$appIconName" "$sysAppIconDir/$appIconName" || exit
    chmod 644 "$sysAppIconDir/$appIconName" || exit
else
    echo "Cannot find driver's icon in package"
    exit 1
fi

if [ -f "$appAutoStartDir/$appDesktopName" ]; then
    cp -a "$appAutoStartDir/$appDesktopName" "$sysAutoStartDir/$appDesktopName" || exit
else
    echo "Cannot find set auto start"
    exit 1
fi

# Copy config files
strres=$(chmod -R +666 /usr/lib/huiontablet)
if [ "$strres" != "" ]; then
    echo "Cannot add permission to res"
    echo "$strres"
    exit 1
fi

strdevuinput=$(chmod 0666 /dev/uinput)
if [ "$strdevuinput" != "" ]; then
    echo "Cannot add permission 0666 to /dev/uinput"
    echo "$strdevuinput"
    exit 1
fi

CUSTOM_CONF_RES_PATH="./huion/huiontablet/custom.conf"
MINT_STR="Mint" #""  Type=x11
DEEPIN_STR="Deepin" #""  Type=x11
MANJARO_STR="Manjaro" #"/etc/gdm/custom.conf"
CENTOS_STR="CentOS" #"/etc/gdm/custom.conf"
UBUNTU_STR="Ubuntu" #"/etc/gdm3/custom.conf"
FEDORA_STR="Fedora" #"/etc/gdm/custom.conf"
CUSTOM_CONF_FILE="/etc/gdm/custom.conf"
check_os_release_result=$(ls -li /etc/os-release | grep '^NAME' /etc/os-release)

if [[ $check_os_release_result =~ $UBUNTU_STR ]]; then
    CUSTOM_CONF_FILE="/etc/gdm3/custom.conf"
    if [ ! -d "/etc/gdm3/" ]; then
        mkdir /etc/gdm3 || exit
    fi
else
    CUSTOM_CONF_FILE="/etc/gdm/custom.conf"
    if [ ! -d "/etc/gdm/" ]; then
        mkdir /etc/gdm || exit
    fi
fi

# changeWaylandToX11
if [ ! -f "$CUSTOM_CONF_FILE" ]; then
    # custom.conf文件不存在，复制一个到系统目录下
    cp -a "$CUSTOM_CONF_RES_PATH" "$CUSTOM_CONF_FILE" || exit
else
    WAYLAND_DISABLE_STR="#WaylandEnable=false"
    WAYLAND_ENABLE_STR="WaylandEnable=false"
    DEFAULTSESSION_IS_X11="DefaultSession=x11"
    DISABLE_DEFAULTSESSION_IS_X11="#DefaultSession=x11"
    SHARP_DAEMON_STR="#\\[daemon\\]"
    DAEMON_STR="\\[daemon\\]"
    if [[ $(grep -c "$SHARP_DAEMON_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
        sharp_daemon_line_num=$(cat -n "$CUSTOM_CONF_FILE" | grep "$SHARP_DAEMON_STR" | awk '{print $1}')
        sed -i "${sharp_daemon_line_num}d" "$CUSTOM_CONF_FILE"
        sed -i "${sharp_daemon_line_num}i ${DAEMON_STR}" "$CUSTOM_CONF_FILE"
    fi

    if [[ $(grep -c "$WAYLAND_DISABLE_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
        if [[ $(grep -c "$DEFAULTSESSION_IS_X11" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
            insert_wayland_enable_str="WaylandEnable=false"
            line_wayland_enable_num=$(cat -n "$CUSTOM_CONF_FILE" | grep WaylandEnable | awk '{print $1}')
            sed -i "${line_wayland_enable_num}d" "$CUSTOM_CONF_FILE"
            sed -i "${line_wayland_enable_num}i ${insert_wayland_enable_str}" "$CUSTOM_CONF_FILE"
        else
            insert_str="WaylandEnable=false\nDefaultSession=x11"
            if [[ $(grep -c "$DAEMON_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
                insert_str="WaylandEnable=false\nDefaultSession=x11"
            else
                insert_str="$DAEMON_STR\nWaylandEnable=false\nDefaultSession=x11"
            fi
            line_num=$(cat -n "$CUSTOM_CONF_FILE" | grep WaylandEnable | awk '{print $1}')
            sed -i "${line_num}d" "$CUSTOM_CONF_FILE"
            sed -i "${line_num}i ${insert_str}" "$CUSTOM_CONF_FILE"
        fi
    else
        if [[ $(grep -c "$WAYLAND_ENABLE_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
            if [[ $(grep -c "$DEFAULTSESSION_IS_X11" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
                line_wayland_enable_default_session_num=$(cat -n "$CUSTOM_CONF_FILE" | grep "$DEFAULTSESSION_IS_X11" | awk '{print $1}')
                sed -i "${line_wayland_enable_default_session_num}d" "$CUSTOM_CONF_FILE"
                sed -i "${line_wayland_enable_default_session_num}i ${DEFAULTSESSION_IS_X11}" "$CUSTOM_CONF_FILE"
            else
                line_wayland_enable_default_session_num=$(cat -n "$CUSTOM_CONF_FILE" | grep WaylandEnable | awk '{print $1}')
                line_wayland_enable_default_session_num=$(expr "$line_wayland_enable_default_session_num" + 1)
                sed -i "${line_wayland_enable_default_session_num}i ${DEFAULTSESSION_IS_X11}" "$CUSTOM_CONF_FILE"
            fi
        else
            if [[ $(grep -c "$DEFAULTSESSION_IS_X11" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
                line_wayland_enable_default_session_num=$(cat -n "$CUSTOM_CONF_FILE" | grep "$DEFAULTSESSION_IS_X11" | awk '{print $1}')
                sed -i "${line_wayland_enable_default_session_num}d" "$CUSTOM_CONF_FILE"
                sed -i "${line_wayland_enable_default_session_num}i ${DEFAULTSESSION_IS_X11}" "$CUSTOM_CONF_FILE"
                line_wayland_enable_default_session_num=$(expr "$line_wayland_enable_default_session_num" - 1)
                sed -i "${line_wayland_enable_default_session_num}i ${WAYLAND_ENABLE_STR}" "$CUSTOM_CONF_FILE"
            else
                if [[ $(grep -c "$DAEMON_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
                    insert_str="WaylandEnable=false\nDefaultSession=x11"
                    line_num=$(cat -n "$CUSTOM_CONF_FILE" | grep "$DAEMON_STR" | awk '{print $1}')
                    line_num=$(expr "$line_num" + 1)
                    sed -i "${line_num}i ${insert_str}" "$CUSTOM_CONF_FILE"
                else
                    insert_str="$DAEMON_STR\nWaylandEnable=false\nDefaultSession=x11"
                    sed -i "2i ${insert_str}" "$CUSTOM_CONF_FILE"
                fi
            fi
        fi
    fi
fi

if [[ $(grep -c "$DAEMON_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
    echo "$DAEMON_STR"
else
    if [[ $(grep -c "$WAYLAND_ENABLE_STR" "$CUSTOM_CONF_FILE") -ne '0' ]]; then
        line_num=$(cat -n "$CUSTOM_CONF_FILE" | grep "$WAYLAND_ENABLE_STR" | awk '{print $1}')
        sed -i "${line_num}i ${DAEMON_STR}" "$CUSTOM_CONF_FILE"
    fi
fi

echo "Installation Succeeded !"

ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo "$REPLY" | tr '[:upper:]' '[:lower:]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

echo "Please confirm if you want to restart your system now."
echo "The installation script will reboot your system so that the driver will work well !"

if [[ "no" == $(ask_yes_or_no "Are you sure you want to reboot your system right now?") ]]; then
    echo "Warning: After the driver is installed successfully, please restart your system before using the driver, otherwise, the driver will not work properly!"
else
    echo "Rebooting ..."
    reboot
fi
