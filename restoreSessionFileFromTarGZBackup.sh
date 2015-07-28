#!/bin/bash
source $(pwd)/configurationSettings

if [[ -z "$1" ]]; then
   echo "Usage: $0 [PATH_TO_BACKUP_FILE] [SESSION_FILE_NAME]"
   echo "[SESSION_FILE_NAME] EXAMPLE:    AABBCCDDEEFF.wpc"
   echo "[PATH_TO_BACKUP_FILE] EXAMPLE:  ./reaverBackup/reaverBackup_YYYY-MM-DD_HH-MM-SS.tar.gz"
   echo "REMEMBER! Reaver session directory is taken from ./configurationSettings file (REAVER_SESSION_DIR)."
   echo "So you have to have correct settings there, before running this script check your configurationSettings."
   exit
fi
BACKUP_F=$1
SESS_FILE=$2
SESS_DIR=$REAVER_SESSION_DIR # from configurationSettings file
# session without trailing slash
SESS_DIR_NO_T_SLASH=$(echo ${SESS_DIR:1}) # substring in bash is ${VAR:fromChar:charsNum}


tar -xOf ${BACKUP_F} ${SESS_DIR_NO_T_SLASH}/${SESS_FILE} > ${SESS_DIR}/${SESS_FILE}
echo "tar -xOf ${BACKUP_F} ${SESS_DIR_NO_T_SLASH}/${SESS_FILE} > ${SESS_DIR}/${SESS_FILE}"
echo "Restored session file's head: "
cat ${SESS_DIR}/${SESS_FILE} | head
