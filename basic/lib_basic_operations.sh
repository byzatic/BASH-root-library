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

function __test_glob() {
  local FILE_OR_DIR NAME DIR EXIT_CODE
  FILE_OR_DIR=$(set_e && check_input "__test_glob" "FILE_OR_DIR" "${1}")
  NAME=$(set_e &&  echo "${FILE_OR_DIR}" | cut -d' ' -f1 | rev | cut -d'/' -f1 | rev )
  DIR=$(set_e && dirname "${FILE_OR_DIR}")
  test -n "$(set_e &&  find ${DIR} -maxdepth 1 -name ${NAME} -print -quit )"
  EXIT_CODE=$?
  logging "DEBUG" "__test_glob" "EXIT_CODE= ${EXIT_CODE}"
  return ${EXIT_CODE}
}

#Defining copy files function
function __copy_file() {
  #
  # :: $1 -- str -- source file
  # :: $2 -- str -- dst file
  #
  local SOURCE_FILE
  local DST_FILE
  SOURCE_FILE=$(set_e && check_input "__copy_file" "SOURCE_FILE" "${1}")
  DST_FILE=$(set_e && check_input "__copy_file" "DST_FILE" "${2}")
  logging "DEBUG" "__copy_file" "start"
  if [ -f "${SOURCE_FILE}" ]; then
      # shellcheck disable=SC2091
      cp ${SOURCE_FILE} ${DST_FILE}
      __failure_exit_check $? "CRITICAL" "__copy_file" "cp failure"
      logging "DEBUG" "__copy_file" "copied ${SOURCE_FILE} to ${DST_FILE}"
  else
    logging "DEBUG" "__copy_file" "source file ${SOURCE_FILE} not exists"
    system_exit 1
  fi
}

#Defining copy files function
function __copy_file_nonblocking() {
  #
  # :: $1 -- str -- source file
  # :: $2 -- str -- dst file
  #
  local SOURCE_FILE
  local DST_FILE
  SOURCE_FILE=$(set_e && check_input "__copy_file_nonblocking" "SOURCE_FILE" "${1}")
  DST_FILE=$(set_e && check_input "__copy_file_nonblocking" "DST_FILE" "${2}")
  if [ -f "${SOURCE_FILE}" ]; then
      cp "${SOURCE_FILE}" "${DST_FILE}"
      __failure_exit_check $? "CRITICAL" "__copy_file_nonblocking" "cp failure"
      logging "DEBUG" "__copy_file_nonblocking" "copied ${SOURCE_FILE} to ${DST_FILE}"
  else
    logging "DEBUG" "__copy_file_nonblocking" "source file ${SOURCE_FILE} not exists"
  fi
}

#Defining make directory function
function __make_directory() {
  #
  # :: $1 -- str -- source directory
  #
  local DST_DIRECTORY
  DST_DIRECTORY=$(set_e && check_input "__make_directory" "DST_DIRECTORY" "${1}")
  if [ ! -d "${DST_DIRECTORY}" ]; then
      mkdir -p "${DST_DIRECTORY}"
      __failure_exit_check $? "CRITICAL" "__make_directory" "mkdir failure"
      logging "DEBUG" "__make_directory" "directory ${DST_DIRECTORY} created"
  else
    logging "DEBUG" "__make_directory" "directory ${DST_DIRECTORY} exists; nothing to create"
  fi
}

#Defining function for removing files and directories
function __remove_universal() {
  #
  # :: $1 -- str -- source file
  #
  local SOURCE
  SOURCE=$(set_e && check_input "__remove_universal" "SOURCE" "${1}")
  if [ -f "${SOURCE}" ]; then
      # shellcheck disable=SC2091
      rm -f ${SOURCE}
      __failure_exit_check $? "CRITICAL" "__remove_universal" "rm failure"
      logging "DEBUG" "__remove_universal" "removed file ${SOURCE}"
  elif [ -d "${SOURCE}" ]; then
      # shellcheck disable=SC2091
      rm -rf ${SOURCE}
      __failure_exit_check $? "CRITICAL" "__remove_universal" "rm failure"
      logging "DEBUG" "__remove_universal" "removed directory ${SOURCE}"
  elif ( __test_glob ${SOURCE} ); then
    # shellcheck disable=SC2091
    rm -rf ${SOURCE}
    __failure_exit_check $? "CRITICAL" "__remove_universal" "rm failure"
    logging "DEBUG" "__remove_universal" "removed ${SOURCE}"
  else
    logging "DEBUG" "__remove_universal" "source ${SOURCE} not exists"
  fi
  logging "DEBUG" "__remove_universal" "finish"
  echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [DEBUG] (__remove_universal): finish"
}

function __read_file() {
  #
  # :: $1 -- str -- source file
  #
  local FILE_PATH
  local FILE_DADA
  #
  FILE_PATH=$(set_e && check_input "__read_file" "FILE_PATH" ${1})
  #
  if ( __check_file_exists ${FILE_PATH} ); then
    FILE_DADA=$(set_e && cat ${FILE_PATH})
    # TODO: I'm not shure that $? will work outside $(set_e && )
    __failure_exit_check "$?" "CRITICAL" "__read_file" "cat failure"
    logging "DEBUG" "__read_file" "data has been read: ${FILE_DADA}"
    freturn ${FILE_DADA}
  else
    logging "CRITICAL" "__read_file" "file ${FILE_PATH} not exists" && \
    system_exit 1
  fi
}

function __write_file() {
  #
  # :: $1 -- str -- source file
  # :: $2 -- str -- data to write
  #
  local FILE_PATH
  local WRITE_DATA
  FILE_PATH=$(set_e && check_input "__write_file" "FILE_PATH" ${1})
  WRITE_DATA=$(set_e && check_input "__write_file" "WRITE_DATA" ${2})
  if ( __check_file_exists ${FILE_PATH} ); then
    echo ${WRITE_DATA} > ${FILE_PATH}
    __failure_exit_check "$?" "CRITICAL" "__write_file" "pipe failure"
    logging "DEBUG" "__write_file" "data written to file"
  else
    logging "CRITICAL" "__write_file" "file ${FILE_PATH} not exists"
    system_exit 1
  fi
}

function __create_file() {
  #
  # :: $1 -- str -- source file
  #
  local FILE_PATH
  FILE_PATH=$(set_e && check_input "__create_file" "FILE_PATH" ${1})
  if ( ! __check_file_exists ${FILE_PATH} ); then
    touch ${FILE_PATH}
    __failure_exit_check "$?" "CRITICAL" "__create_file" "touch failure"
    logging "DEBUG" "__create_file" "file created"
  else
    logging "DEBUG" "__create_file" "file ${FILE_PATH} exists"
  fi
}

function __check_file_exists() {
  #
  # :: $1 -- str -- source file
  #
  local FILE_PATH
  FILE_PATH=$(set_e && check_input "__check_file_exists" "FILE_PATH" ${1})
  if [ -f "${FILE_PATH}" ]; then
    logging "DEBUG" "__check_file_exists" "file exists"
    return 0
  else
    logging "DEBUG" "__check_file_exists" "file not exists"
    return 1
  fi
}

function __check_directory_exists() {
  #
  # :: $1 -- str -- source file
  #
  local FILE_PATH
  FILE_PATH=$(set_e && check_input "__check_directory_exists" "FILE_PATH" ${1})
  if [ -d "${FILE_PATH}" ]; then
    logging "DEBUG" "__check_directory_exists" "directory exists"
    return 0
  else
    logging "DEBUG" "__check_directory_exists" "directory not exists"
    return 1
  fi
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
