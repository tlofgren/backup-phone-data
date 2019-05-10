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

MOTO_PIC_DIR="/sdcard/Pictures"
MOTO_DCIM_DIR="/storage/8014-13FF/DCIM"
MOTO_CAM_DIR="/storage/8014-13FF/DCIM/Camera"
MOTO_MOVED_CAM_DIR=$(join_by / ${MOTO_DCIM_DIR} ${CURR_DATE})
MOTO_CALL_REC_DIR="/sdcard/CubeCallRecorder/All"
MOTO_AUDIO_REC_DIR="/sdcard/EasyVoiceRecorder"

#####
# setup
ADB_OUTPUT=`adb devices`
ADB_RUNNING=$?
if [ $ADB_RUNNING -ne 0 ]; then
    echo "ADB not running properly; exiting now"
    exit $ADB_RUNNING
fi

# echo "Creating folder ${DATA_BACKUP_DIR}"
# mkdir -p ${DATA_BACKUP_DIR}
# exit_if_fail "mkdir"

# echo "Creating folder ${CALL_REC_BACKUP_DIR}"
# mkdir -p ${CALL_REC_BACKUP_DIR}
# exit_if_fail "mkdir"

echo "Creating folder ${PIC_BACKUP_DIR}"
mkdir -p ${PIC_BACKUP_DIR}
exit_if_fail "mkdir"

#####
# Pictures
# for picdir in $(adb shell "ls ${MOTO_PIC_DIR}"); do
#     picpath=`join_by / ${MOTO_PIC_DIR} ${picdir}`
#     adb pull ${picpath} ${PIC_BACKUP_DIR}
#     exit_if_fail "adb pull ${picpath}"
# done

# adb pull ${MOTO_CAM_DIR} ${PIC_BACKUP_DIR}
# exit_if_fail "adb pull camera"

echo "Moving Camera dir ${MOTO_CAM_DIR} to ${MOTO_MOVED_CAM_DIR}"
adb shell "mv ${MOTO_CAM_DIR} ${MOTO_MOVED_CAM_DIR}"

#####
# Recordings
# adb pull ${MOTO_AUDIO_REC_DIR} ${DATA_BACKUP_DIR}
# exit_if_fail "pull audio rec"

# for amr in $(adb shell "ls ${MOTO_CALL_REC_DIR}"); do
#     amrpath=`join_by / ${MOTO_CALL_REC_DIR} ${amr}`
#     adb pull ${amrpath} ${CALL_REC_BACKUP_DIR}
#     exit_if_fail "pull amr ${amr}"
# done


