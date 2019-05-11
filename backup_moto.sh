#!/bin/bash

#####
# Functions
exit_if_fail() {
    local exitcode=$?
    local prog='command'
    if [ -n "$1" ]; then
        prog=$1
    fi
    if [ ${exitcode} -ne 0 ]; then
        echo "${prog} failed; exiting"
        exit ${exitcode}
    fi
}

function join_by {
    local IFS="$1"; # change Internal Field Separator
    shift;
    echo "$*";
}

#####
# Vars
CURR_DATETIME=`date +%Y-%m-%d_%H%M`
CURR_DATE=`date +%Y-%m-%d`
CURR_YEAR=`date +%Y`

DATA_BACKUP_DIR="/home/tyler/backup/moto/${CURR_DATETIME}"
PIC_BACKUP_DIR="/media/tyler/tylerbackup/Pictures/${CURR_YEAR}/${CURR_DATE}"
CALL_REC_BACKUP_DIR="${DATA_BACKUP_DIR}/CubeCallRecorder"
ROCKETPLAYER_BACKUP_DIR="${DATA_BACKUP_DIR}/RocketPlayer"
SEXY_BACKUP_DIR="/media/tyler/tylerbackup/backup/appdata/local/toosexy/${CURR_DATE}"

MOTO_MAIN_STORAGE_DIR="/sdcard"
MOTO_EXTERNAL_STORAGE_DIR="/storage/8014-13FF"
MOTO_PIC_DIR="/sdcard/Pictures"
MOTO_DCIM_DIR="/storage/8014-13FF/DCIM"
MOTO_CAM_DIR="/storage/8014-13FF/DCIM/Camera"
MOTO_SEXY_DIR="${MOTO_EXTERNAL_STORAGE_DIR}/toosexy"
MOTO_MOVED_CAM_DIR=$(join_by / "${MOTO_DCIM_DIR}" "${CURR_DATE}")
MOTO_CALL_REC_DIR="/sdcard/CubeCallRecorder/All"
MOTO_AUDIO_REC_DIR="/sdcard/EasyVoiceRecorder"
MOTO_WECHAT_DIR="${MOTO_MAIN_STORAGE_DIR}/tencent/"
MOTO_SMSBACKUPANDRESTORE="/storage/8014-13FF/smsBackupAndRestore"
MOTO_SIGNAL_DIR=$(join_by / "${MOTO_MAIN_STORAGE_DIR}" "Signal/Backups")

#####
# setup
ADB_OUTPUT=`adb devices`
ADB_RUNNING=$?
if [ $ADB_RUNNING -ne 0 ]; then
    echo "ADB not running properly; exiting now"
    exit $ADB_RUNNING
fi

echo "Creating folder ${DATA_BACKUP_DIR}"
mkdir -p "${DATA_BACKUP_DIR}"
exit_if_fail "mkdir data"

# echo "Creating folder ${CALL_REC_BACKUP_DIR}"
# mkdir -p "${CALL_REC_BACKUP_DIR}"
# exit_if_fail "mkdir call rec"

echo "Creating folder ${PIC_BACKUP_DIR}"
mkdir -p "${PIC_BACKUP_DIR}"
exit_if_fail "mkdir pic"

echo "Creating folder ${SEXY_BACKUP_DIR}"
mkdir -p "${SEXY_BACKUP_DIR}"
exit_if_fail "mkdir sexy"

#####
# Pictures
# for picdir in $(adb shell "ls ${MOTO_PIC_DIR}"); do
#     picpath=`join_by / ${MOTO_PIC_DIR} ${picdir}`
#     adb pull "${picpath}" "${PIC_BACKUP_DIR}"
#     exit_if_fail "adb pull ${picpath}"
# done

# adb pull "${MOTO_CAM_DIR}" "${PIC_BACKUP_DIR}"
# exit_if_fail "adb pull camera"

# echo "Moving Camera dir ${MOTO_CAM_DIR} to ${MOTO_MOVED_CAM_DIR}"
# adb shell "mv ${MOTO_CAM_DIR} ${MOTO_MOVED_CAM_DIR}"

for file in $(adb shell "ls ${MOTO_SEXY_DIR}"); do
    filepath=$(join_by / ${MOTO_SEXY_DIR} ${file})
    adb pull "${filepath}" "${SEXY_BACKUP_DIR}"
    exit_if_fail "pull sexy ${file}"
done
# TODO: remove files from moto

#####
# Recordings
# adb pull "${MOTO_AUDIO_REC_DIR}" "${DATA_BACKUP_DIR}"
# exit_if_fail "pull audio rec"

# for amr in $(adb shell "ls ${MOTO_CALL_REC_DIR}"); do
#     amrpath=`join_by / ${MOTO_CALL_REC_DIR} ${amr}`
#     adb pull "${amrpath}" "${CALL_REC_BACKUP_DIR}"
#     exit_if_fail "pull amr ${amr}"
# done

#####
# Apps installed
adb shell cmd package list packages -i > "${DATA_BACKUP_DIR}/pkg_list.txt"
adb shell cmd package list packages -f > "${DATA_BACKUP_DIR}/pkg_list_assoc_files.txt"
adb shell cmd package list packages -s > "${DATA_BACKUP_DIR}/pkg_list_system.txt"
adb shell cmd package list packages -d > "${DATA_BACKUP_DIR}/pkg_list_disabled.txt"
adb shell cmd package list packages -u > "${DATA_BACKUP_DIR}/pkg_list_uninstalled.txt"

#####
# SMS Backup and Restore
EXTERNAL_DOWNLOAD=$(join_by / ${MOTO_EXTERNAL_STORAGE_DIR} "Download")
SMS_GZIP_DEST=$(join_by / ${EXTERNAL_DOWNLOAD} "smsbackup${CURR_DATETIME}.tar.gz")
SIZE_SMS=$(adb shell du -s ${MOTO_SMSBACKUPANDRESTORE} | awk '{printf "%d", $1}')
MOTO_EXT_SPACE_AVAIL=$(adb shell df ${EXTERNAL_DOWNLOAD} | tail -1 | awk '{print $4}')
if [ $((${MOTO_EXT_SPACE_AVAIL} - ${SIZE_SMS} > 100000)) ]; then # units in KB
    adb shell "tar -czvf  ${SMS_GZIP_DEST} ${MOTO_SMSBACKUPANDRESTORE}"
    exit_if_fail "gzip sms"
    adb pull "${SMS_GZIP_DEST}" "${DATA_BACKUP_DIR}"
    exit_if_fail "pull sms gzip"
    adb shell rm -rf "${SMS_GZIP_DEST}"
    exit_if_fail "rm sms gzip"
else
    echo "Not enough space to zip up sms; will transfer directly"
    adb pull "${MOTO_SMSBACKUPANDRESTORE}" "${DATA_BACKUP_DIR}"
    exit_if_fail "pull sms uncompressed"
fi


#####
# Folders on Main Storage
MOTO_DOCS_DIR=$(join_by / "${MOTO_MAIN_STORAGE_DIR}" "Documents")
adb pull "${MOTO_DOCS_DIR}" "${DATA_BACKUP_DIR}"
exit_if_fail "pull docs"

MOTO_TOP_LEVEL_DIRS=( "carbon" "Documents" "Downloads" "EasyVoiceRecorder" "Music" "Playlists" "Voicemails" "WhatsApp" )
for dir in "${MOTO_TOP_LEVEL_DIRS[@]}"; do
    # TODO: pull each folder in list
    echo $dir;
done

#####
# RocketPlayer
echo "Creating folder ${ROCKETPLAYER_BACKUP_DIR}"
mkdir -p "${ROCKETPLAYER_BACKUP_DIR}"
exit_if_fail "mkdir rocketplayer"
adb pull "${MOTO_MAIN_STORAGE_DIR}/RocketPlayer/livelists.xml" "${ROCKETPLAYER_BACKUP_DIR}"
exit_if_fail "pull rocketplayer livelists"

#####
# Signal
adb pull "${MOTO_SIGNAL_DIR}" "${DATA_BACKUP_DIR}"
exit_if_fail "pull Signal backup"

#####
# Tencent
# Unnecessarily complicated - desktop backup is "Backup.db"
