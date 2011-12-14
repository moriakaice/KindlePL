#!/bin/sh
#
# $Id: install.sh 6845 2010-09-23 23:11:24Z NiLuJe $
#
# diff OTA patch script

_FUNCTIONS=/etc/rc.d/functions
[ -f ${_FUNCTIONS} ] && . ${_FUNCTIONS}


MSG_SLLVL_D="debug"
MSG_SLLVL_I="info"
MSG_SLLVL_W="warn"
MSG_SLLVL_E="err"
MSG_SLLVL_C="crit"
MSG_SLNUM_D=0
MSG_SLNUM_I=1
MSG_SLNUM_W=2
MSG_SLNUM_E=3
MSG_SLNUM_C=4
MSG_CUR_LVL=/var/local/system/syslog_level

logmsg()
{
    local _NVPAIRS
    local _FREETEXT
    local _MSG_SLLVL
    local _MSG_SLNUM

    _MSG_LEVEL=$1
    _MSG_COMP=$2

    { [ $# -ge 4 ] && _NVPAIRS=$3 && shift ; }

    _FREETEXT=$3

    eval _MSG_SLLVL=\${MSG_SLLVL_$_MSG_LEVEL}
    eval _MSG_SLNUM=\${MSG_SLNUM_$_MSG_LEVEL}

    local _CURLVL

    { [ -f $MSG_CUR_LVL ] && _CURLVL=`cat $MSG_CUR_LVL` ; } || _CURLVL=1

    if [ $_MSG_SLNUM -ge $_CURLVL ]; then
        /usr/bin/logger -p local4.$_MSG_SLLVL -t "ota_install" "$_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT"
    fi

    if [ "$_MSG_LEVEL" != "D" ]; then
      echo "ota_install: $_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT"
      [ -d /mnt/us/localization ] && echo "ota_install: $_MSG_LEVEL def:$_MSG_COMP:$_NVPAIRS:$_FREETEXT" >> /mnt/us/localization/install.log
    fi
}

# Hack specific config (name and when to start/stop)
ORIGFOLDER_LIB=/opt/amazon/ebook/lib

#Create localization dir at user store
[ -d /mnt/us/localization ] || mkdir /mnt/us/localization

logmsg "I" "update" "Copy ru.properties"
update_progressbar 10
cp -f pl.properties /opt/amazon/ebook/config/locales

logmsg "I" "update" "Translate JARs"
update_progressbar 30
/usr/java/bin/cvm -Xms16m -classpath bcel-5.2.jar:K3Translator.jar Translator td4 /opt/amazon/ebook/lib translation.jar en_GB pl_PL >> /mnt/us/localization/install.log 2>&1

update_progressbar 70

logmsg "I" "update" "Copy images to img"
tar -xvzf img.tar.gz >> /mnt/us/localization/install.log 2>&1
cp -rf img /opt/amazon/ebook >> /mnt/us/localization/install.log 2>&1

update_progressbar 90
logmsg "I" "update" "Copy images to lli"
tar -xvzf low_level_screens.tar.gz >> /mnt/us/localization/install.log 2>&1
cp -rf low_level_screens /opt/amazon >> /mnt/us/localization/install.log 2>&1

logmsg "I" "update" "done"
update_progressbar 100

return 0