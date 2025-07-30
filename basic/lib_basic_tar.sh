#!/bin/bash -e
#
#  MIT License
#
#  Copyright (c) 2023 s.vlasov.home@icloud.com
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#

#create inctremental backup
function __incremental_backup_tar() {
  #
  # :: $1 -- str -- meta file name abs path
  # :: $2 -- str -- backup source directory abs path
  # :: $3 -- str -- backup output directory abs path
  # :: $4 -- str -- current epoch
  # :: $5 -- str -- (OPTIONAL ARG) exclude file
  #
  logging "DEBUG" "__incremental_backup_tar" "start"

  local LISTED_INCREMENTAL BACKUP_SOURCE BACKUP_OUTPUT_DIR BACKUP_OUTPUT_FILE_NAME EXCLUDE_FILE
  local BACKUP_FILE_NAME

  LISTED_INCREMENTAL=$(set_e && check_input "__incremental_backup_tar" "LISTED_INCREMENTAL" ${1})
  BACKUP_SOURCE=$(set_e && check_input "__incremental_backup_tar" "BACKUP_SOURCE" ${2})
  BACKUP_OUTPUT_DIR=$(set_e && check_input "__incremental_backup_tar" "BACKUP_OUTPUT_DIR" ${3})
  BACKUP_OUTPUT_FILE_NAME=$(set_e && check_input "__incremental_backup_tar" "BACKUP_OUTPUT_FILE_NAME" ${4})
  #EXCLUDE_FILE=$(set_e && check_input "__incremental_backup_tar" "LISTED_INCREMENTAL" ${5})

  BACKUP_FILE_NAME="${BACKUP_OUTPUT_DIR}/${BACKUP_OUTPUT_FILE_NAME}.tar.gz"

  logging "DEBUG" "__incremental_backup_tar" "Started creating incremental backup with tar"
  if [ -z "${EXCLUDE_FILE}" ]
  then
    logging "DEBUG" "__incremental_backup_tar" "there is no excludes in call; run tar regularly"
    # shellcheck disable=SC2091
    tar -v -z --create --file ${BACKUP_FILE_NAME} --listed-incremental=${LISTED_INCREMENTAL} ${BACKUP_SOURCE} || $(set_e && >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [ERROR] (incremental_backup_tar): tar error" && exit 1)
    __failure_exit_check $? "CRITICAL" "__incremental_backup_tar" "tar failure"
    logging "DEBUG" "__incremental_backup_tar" "tar complete"
  else
    logging "DEBUG" "__incremental_backup_tar" "there is excludes in file ${EXCLUDE_FILE}; run tar extended"
    # shellcheck disable=SC2091
    tar --exclude-from=${EXCLUDE_FILE} -v -z --create --file ${BACKUP_FILE_NAME} --listed-incremental=${LISTED_INCREMENTAL} ${BACKUP_SOURCE}
    __failure_exit_check $? "CRITICAL" "__incremental_backup_tar" "tar failure"
    logging "DEBUG" "__incremental_backup_tar" "tar complete"
  fi
  logging "DEBUG" "__incremental_backup_tar" "finish"
}

#create inctremental backup
function __restore_tar() {
  #
  # :: $1 -- str -- backup source directory abs path
  # :: $2 -- str -- backup output directory abs path
  # :: $3 -- str -- strip components
  #
  logging "DEBUG" "__restore_tar" "tar restore starting"

  local BACKUP_SOURCE_FILE BACKUP_DESTINATION STRIP_COMPONENTS

  BACKUP_SOURCE_FILE=$(set_e && check_input "__restore_tar" "BACKUP_SOURCE_FILE" "${1}")
  BACKUP_DESTINATION=$(set_e && check_input "__restore_tar" "BACKUP_DESTINATION" "${2}")
  STRIP_COMPONENTS=$(set_e && check_input "__restore_tar" "STRIP_COMPONENTS" "${3}")

  #tar -xpvf ${BACKUP_SOURCE_FILE} --strip-components=${STRIP_COMPONENTS} -C ${BACKUP_DESTINATION}
  tar --extract \
  --verbose \
  --preserve-permissions \
  --strip-components=${STRIP_COMPONENTS} \
  --file ${BACKUP_SOURCE_FILE} \
  --directory ${BACKUP_DESTINATION}
  __failure_exit_check $? "CRITICAL" "__restore_tar" "tar failure"
  logging "DEBUG" "__restore_tar" "tar restore complete"
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi