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

escape_spaces() {
    # Use this when calling `adb shell` to escape spaces in file and folder names
    local arg="$1"
    echo "${arg}" | sed 's/\([^\\]\) /\1\\ /g'
}

pull_folder() {
    local src="$1"
    local tgt="$2"
    echo "Pulling ${src}"
    adb pull -a "${src}" "${tgt}"
    local exitcode=$?
    if [ ${exitcode} -ne 0 ]; then
        echo "Warning: could not pull '${src}' to '${tgt}'"
    fi
    return ${exitcode}
}

pull_and_delete() {
    local src="$1"
    local tgt="$2"
    pull_folder "${src}" "${tgt}"
    local exitcode=$?
    if [ ${exitcode} -eq 0 ]; then
        local escaped=$(escape_spaces "${src}")
        echo "Deleting '${escaped}'"
        adb shell rm -rf "${escaped}"
    else
        echo "Warning from pull_and_delete: will not remove '${src}'"
    fi
    return $?
}

pull_files_and_delete() {
    # Pull and delete files but do not delete src dir
    local src_dir="$1"
    local tgt_dir="$2"  # Don't need to escape strings for host/target
    local IFS=$(echo -en "\n\b")
    for file in $(adb shell ls $(escape_spaces "${src_dir}")); do
        filepath=$(join_by / "${src_dir}" "${file}")
        pull_and_delete "${filepath}" "${tgt_dir}"
    done
}

# handle spaces
# https://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
# list_files_spaces() {
#     local src_dir="$1"
#     SAVEIFS=$IFS
#     IFS=$(echo -en "\n\b")
#     for f in $(adb shell ls "${src_dir}")
#     do
#         echo "$f"
#     done
#     IFS=$SAVEIFS
# }

test_pull_files_and_delete() {
    local src_dir=$(escape_spaces "$1")
    local tgt_dir="$2"
    local IFS=$(echo -en "\n\b")
    for file in $(adb shell ls "${src_dir}"); do
        filepath=$(join_by / "${src_dir}" $(escape_spaces "${file}"))
        echo "test_pull_files_and_delete: Filepath: ${filepath}"
        adb shell readlink -f "${filepath}"
        echo "test_pull_files_and_delete: pull_and_delete ${filepath} ${tgt_dir}"
        readlink -f "${tgt_dir}"
    done
}

#####
# Vars
CURR_DATETIME=`date +%Y-%m-%d_%H%M`
CURR_DATE=`date +%Y-%m-%d`
CURR_YEAR=`date +%Y`

DATA_BACKUP_DIR="/home/tyler/backup/galaxy/${CURR_DATETIME}"
# PIC_BACKUP_DIR="/media/tyler/shared/Pictures/${CURR_YEAR}/${CURR_DATE}"
PIC_BACKUP_DIR="/media/tyler/allmedia/allpictures/morepictures/${CURR_YEAR}/${CURR_DATE}"
CALL_REC_BACKUP_DIR="${DATA_BACKUP_DIR}/CubeCallRecorder"
ROCKETPLAYER_BACKUP_DIR="${DATA_BACKUP_DIR}/RocketPlayer"
PRIVATE_BACKUP_DIR="/media/tyler/shared/tyler/backup/appdata/local/toosexy/${CURR_DATE}"

MOTO_MAIN_STORAGE_DIR="/storage/emulated/0"
MOTO_EXTERNAL_STORAGE_DIR="/storage/3F4D-351B"
MOTO_PIC_DIR="${MOTO_MAIN_STORAGE_DIR}/Pictures"
MOTO_MOVIE_DIR="${MOTO_MAIN_STORAGE_DIR}/Movies"
MOTO_DCIM_DIR="${MOTO_MAIN_STORAGE_DIR}/DCIM"
MOTO_CAM_DIR="${MOTO_EXTERNAL_STORAGE_DIR}/DCIM/Camera"
MOTO_PRIVATE_DIR="${MOTO_MAIN_STORAGE_DIR}/.toozexy"
MOTO_MOVED_CAM_DIR=$(join_by / "${MOTO_EXTERNAL_STORAGE_DIR}" "DCIM" "${CURR_DATE}")
MOTO_CALL_REC_DIR="${MOTO_MAIN_STORAGE_DIR}/Documents/CubeCallRecorder"
# MOTO_AUDIO_REC_DIR="${MOTO_MAIN_STORAGE_DIR}/EasyVoiceRecorder"
MOTO_AUDIO_REC_DIR="${MOTO_MAIN_STORAGE_DIR}/Easy Voice Recorder"
MOTO_WECHAT_DIR="${MOTO_MAIN_STORAGE_DIR}/tencent/" # TODO
MOTO_NOVABACKUP_DIR="${MOTO_MAIN_STORAGE_DIR}/backup/Nova"
MOTO_SMSBACKUPANDRESTORE="${MOTO_MAIN_STORAGE_DIR}/smsBackupAndRestore"
MOTO_SIGNAL_DIR=$(join_by / "${MOTO_MAIN_STORAGE_DIR}" "Signal")
MOTO_CARBON_DIR="${MOTO_MAIN_STORAGE_DIR}/carbon"
MOTO_AMDROID_DIR="${MOTO_MAIN_STORAGE_DIR}/AMdroid"
TASKS_DIR="${MOTO_MAIN_STORAGE_DIR}/tasks"
GENERAL_BACKUP_DIR="${MOTO_MAIN_STORAGE_DIR}/backup"

#####
# setup
ADB_OUTPUT=`adb devices`
ADB_RUNNING=$?
if [ $ADB_RUNNING -ne 0 ]; then
    echo "ADB not running properly; exiting now"
    exit $ADB_RUNNING
fi

### DEBUGGING
# test_src="${MOTO_MAIN_STORAGE_DIR}/Download/test adb spaces"
# test_target="./test targe"

# # pull_folder "${test_src}" "${test_target}"
# pull_files_and_delete "${test_src}" "${test_target}"

# IFS=$SAVEIFS
# exit $?


echo "Creating folder ${DATA_BACKUP_DIR}"
mkdir -p "${DATA_BACKUP_DIR}"
exit_if_fail "mkdir data"

echo "Creating folder ${PIC_BACKUP_DIR}"
mkdir -p "${PIC_BACKUP_DIR}"
exit_if_fail "mkdir pic"

# echo "Creating folder ${PRIVATE_BACKUP_DIR}"
# mkdir -p "${PRIVATE_BACKUP_DIR}"
# exit_if_fail "mkdir sexy"

#####
# Apps installed
DATA_BACKUP_APPLISTS="${DATA_BACKUP_DIR}/pkglists"
mkdir -p "${DATA_BACKUP_APPLISTS}"
adb shell cmd package list packages -i > "${DATA_BACKUP_APPLISTS}/pkg_list.txt"
adb shell cmd package list packages -f > "${DATA_BACKUP_APPLISTS}/pkg_list_assoc_files.txt"
adb shell cmd package list packages -s > "${DATA_BACKUP_APPLISTS}/pkg_list_system.txt"
adb shell cmd package list packages -d > "${DATA_BACKUP_APPLISTS}/pkg_list_disabled.txt"
adb shell cmd package list packages -u > "${DATA_BACKUP_APPLISTS}/pkg_list_uninstalled.txt"

#####
# Pictures
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for picdir in $(adb shell ls $(escape_spaces "${MOTO_PIC_DIR}")); do
    picpath=$(join_by / "${MOTO_PIC_DIR}" "${picdir}")
    pull_and_delete "${picpath}" "${PIC_BACKUP_DIR}"
    # exit_if_fail "adb pull ${picpath}"
done

# Movies
for picdir in $(adb shell ls $(escape_spaces "${MOTO_MOVIE_DIR}")); do
    picpath=$(join_by / "${MOTO_MOVIE_DIR}" "${picdir}")
    pull_and_delete "${picpath}" "${PIC_BACKUP_DIR}"
done

MOTO_DCIM_SUBDIRS=( "Artivive" "AR Emoji camera" "CamScanner" "Duolingo" "GIF" "Live message" "MV2" "PhotosEditor" "Restored" "Screen recordings" "Screenshots" "Snapchat" "Tiktok" "Video Editor" "Video trimmer" "Videocaptures" "Video captures" )
for dir in "${MOTO_DCIM_SUBDIRS[@]}"; do
    # TODO: pull each folder in list and move to moved cam dir
    TOP_LEVEL_PATH="${MOTO_DCIM_DIR}/${dir}"
    pull_and_delete "${TOP_LEVEL_PATH}" "${PIC_BACKUP_DIR}"
done

# Camera
pull_folder "${MOTO_CAM_DIR}" "${PIC_BACKUP_DIR}"

echo "Moving Camera dir ${MOTO_CAM_DIR} to ${MOTO_MOVED_CAM_DIR}"
adb shell mv "${MOTO_CAM_DIR}" "${MOTO_MOVED_CAM_DIR}"

# private files
# MOVED_PRIVATE_DIR=$(join_by / ${MOTO_PRIVATE_DIR} ${CURR_DATE})
# adb shell mkdir -p "${MOVED_PRIVATE_DIR}"
# for file in $(adb shell ls "${MOTO_PRIVATE_DIR}"); do
#     filepath=$(join_by / ${MOTO_PRIVATE_DIR} ${file})
#     if [ "${filepath}" == "${MOVED_PRIVATE_DIR}" ]; then
#         continue;
#     fi
#     pull_folder "${filepath}" "${PRIVATE_BACKUP_DIR}"
#     if [ $? -eq 0 ]; then
#         echo "Moving file ${filepath} to ${MOVED_PRIVATE_DIR}"
#         adb shell mv "${filepath}" "${MOVED_PRIVATE_DIR}"
#         exit_if_fail "mv private ${file}"
#     fi
# done
# TODO: remove files from moto

#####
# Recordings
pull_files_and_delete "${MOTO_AUDIO_REC_DIR}" "${DATA_BACKUP_DIR}"
pull_files_and_delete "${MOTO_CALL_REC_DIR}" "${DATA_BACKUP_DIR}"

#####
# SMS Backup and Restore
DOWNLOAD_DIR=$(join_by / ${MOTO_MAIN_STORAGE_DIR} "Download")
SMS_GZIP_DEST=$(join_by / "${DATA_BACKUP_DIR}" "smsbackup${CURR_DATETIME}.tar.gz")
SIZE_SMS=$(adb shell du -s "${MOTO_SMSBACKUPANDRESTORE}" | awk '{printf "%d", $1}')
MOTO_EXT_SPACE_AVAIL=$(adb shell df "${DOWNLOAD_DIR}" | tail -1 | awk '{print $4}')
if [ $((${MOTO_EXT_SPACE_AVAIL} - ${SIZE_SMS} > 100000)) ]; then # units in KB
    echo "***will compress sms/mms..."
    adb shell tar -czvf - "${MOTO_SMSBACKUPANDRESTORE}" > "${SMS_GZIP_DEST}"
    exit_if_fail "gzip sms"
    # TODO: remove sms backup xml after pull
    # pull_and_delete "${SMS_GZIP_DEST}" "${DATA_BACKUP_DIR}"
    # exit_if_fail "pull sms gzip"
    # adb shell rm -f "${SMS_GZIP_DEST}"
    # exit_if_fail "rm sms gzip"
else
    echo "Not enough space to zip up sms; will transfer directly"
    pull_and_delete "${MOTO_SMSBACKUPANDRESTORE}" "${DATA_BACKUP_DIR}"
    # exit_if_fail "pull sms uncompressed"
fi


#####
# Folders on Main Storage to keep after backup
MOTO_TOP_LEVEL_DIRS=( "AMdroid" "beam" "Documents" "Download" "games" "Playlists" "SmsContactsBackup" "Snapchat" "Voicemails" "WhatsApp" )
for dir in "${MOTO_TOP_LEVEL_DIRS[@]}"; do
    # TODO: pull each folder in list
    TOP_LEVEL_PATH="${MOTO_MAIN_STORAGE_DIR}/${dir}"
    pull_folder "${TOP_LEVEL_PATH}" "${DATA_BACKUP_DIR}"
done

#####
# RocketPlayer
echo "Creating folder ${ROCKETPLAYER_BACKUP_DIR}"
mkdir -p "${ROCKETPLAYER_BACKUP_DIR}"
exit_if_fail "mkdir rocketplayer"
pull_folder "${MOTO_MAIN_STORAGE_DIR}/RocketPlayer/livelists.xml" "${ROCKETPLAYER_BACKUP_DIR}"

#####
# Signal
pull_files_and_delete "${MOTO_SIGNAL_DIR}" "${DATA_BACKUP_DIR}"

#####
# Nova
# pull_files_and_delete "${MOTO_NOVABACKUP_DIR}" "${DATA_BACKUP_DIR}"

#####
# Carbon/Helium Backup
pull_files_and_delete "${MOTO_CARBON_DIR}" "${DATA_BACKUP_DIR}"

#####
# Tencent
# Unnecessarily complicated - desktop backup is "Backup.db"

####
# AMdroid
pull_files_and_delete "${MOTO_AMDROID_DIR}" "${DATA_BACKUP_DIR}"

####
# Tasks.org
pull_files_and_delete "${TASKS_DIR}" "${DATA_BACKUP_DIR}"

####
# General backup files: AntennaPod, Track & Graph, MediLog...
pull_files_and_delete "${GENERAL_BACKUP_DIR}" "${DATA_BACKUP_DIR}/"

IFS=$SAVEIFS
