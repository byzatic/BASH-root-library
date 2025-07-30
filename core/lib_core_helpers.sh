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

function freturn() {
  echo -n "${1}"
}

function system_exit() {
  exit ${1}
}

function set_e() {
  set -e
}

function get_current_ts() {
  local CURRENT_TS
  CURRENT_TS=$(set_e && date +%s)
  freturn "${CURRENT_TS}"
}

function __failure_exit_check() {
  local EXIT_CODE=${1}
  local LEVEL=${2}
  LEVEL="CRITICAL"
  local FUNCTION_NAME=${3}
  local MESSAGE=${4}
  if [ "${EXIT_CODE}" != "0" ]; then
    logging "${LEVEL}" "${FUNCTION_NAME}" "${MESSAGE}"
    system_exit 1
  fi
}

function check_input() {
  local FUNCTION_NAME=${1}
  local ARG_NAME=${2}
  local ARG=${3}
  local DEFAULT=${4}

  if [ -z "${ARG}" ]; then
    if [ -z "${DEFAULT}" ]; then
      logging "CRITICAL" "${FUNCTION_NAME}" "No argument ${ARG_NAME} supplied"
      logging "CRITICAL" "${FUNCTION_NAME}" "No default supplied for argument ${ARG_NAME}"
      system_exit 1
    elif [ "${DEFAULT}" == "ARG-PASS" ]; then
      logging "DEBUG" "${FUNCTION_NAME}" "supplied ARG-PASS for ${ARG_NAME}; used empty value"
      freturn ""
    else
      freturn "${DEFAULT}"
      logging "DEBUG" "${FUNCTION_NAME}" "argument not supplied: ${ARG_NAME}= ${DEFAULT}; used default"
    fi
  else
    freturn "${ARG}"
    logging "DEBUG" "${FUNCTION_NAME}" "argument supplied: ${ARG_NAME}= ${ARG}"
  fi
}

function get_fts() {
  local DATE_INT FTS
  DATE_INT=$(set_e && check_input "get_fts" "DATE_INT" "${1}")
  FTS=$(date +%Y.%m.%d-%H:%M:%S -d "@${DATE_INT}")
  freturn "${FTS}"
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi