#!/bin/sh
# 2019-04-06 commands
adb pull /sdcard/Pictures/facebook /media/tyler/tylerbackup/Pictures/2019/2019-04-06
adb pull /sdcard/Pictures/* /media/tyler/tylerbackup/Pictures/2019/2019-04-06 # didn't work
adb pull /sdcard/Pictures/Messenger /media/tyler/tylerbackup/Pictures/2019/2019-04-06
adb pull /sdcard/Pictures/PhotosEditor /media/tyler/tylerbackup/Pictures/2019/2019-04-06
adb pull /storage/8014-13FF/DCIM/Camera /media/tyler/tylerbackup/Pictures/2019/2019-04-06
adb pull /sdcard/EasyVoiceRecorder /media/tyler/shared/tyler/backup/moto/2019-04-06/
adb shell "mv /storage/8014-13FF/DCIM/Camera /storage/8014-13FF/DCIM/2019-03-30_to_2019-04-05"
adb shell "rm -rf /sdcard/EasyVoiceRecorder"
adb shell "rm -rf /sdcard/Pictures/PhotosEditor"
adb shell "rm -rf /sdcard/Pictures/Messenger"
adb shell "rm -rf /sdcard/Pictures/facebook"
adb shell 'ls sdcard/CubeCallRecorder/All/*amr' | tr -d '\r' | xargs -n1 adb pull
# need to remove recordings - very difficult, maybe need a for loop?

adb pull /storage/emulated/0/RocketPlayer/livelists.xml RocketPlayer/
adb pull /storage/emulated/0/Playlists/ RocketPlayer/

adb pull /storage/8014-13FF/Music ./Music

adb shell cmd package list packages -i > pkg_list.txt
adb shell cmd package list packages -f > pkg_list_assoc_files.txt
adb shell cmd package list packages -s > pkg_list_system.txt
adb shell cmd package list packages -d > pkg_list_disabled.txt
adb shell cmd package list packages -u > pkg_list_uninstalled.txt

adb shell "rm -rf '/storage/8014-13FF/DCIM/2019-02-20 to 2019-03-16/'" # didn't actually execute this

# after backups
adb pull /sdcard/carbon .
adb pull /sdcard/Download/Dash-wallet-backup-2019-04-07
adb pull /sdcard/Documents .
adb pull /sdcard/data/com.teslacoilsw.launcher/backup/2019-04-07_09-07.novabackup .
adb pull /sdcard/ideaCallRecorder .

# links
https://android.stackexchange.com/a/23608
https://github.com/koush/support-wiki/wiki/Helium-Wiki

# get size of folder
adb shell du -s /storage/8014-13FF/smsBackupAndRestore | awk '{printf "%d", $1}'

# get space available
adb shell df -h $motosd | tail -1 | awk '{print $4}'
