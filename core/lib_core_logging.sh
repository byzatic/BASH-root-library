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

function logging() {
  local LEVEL=${1}
  local FUNCTION_NAME=${2}
  local MESSAGE=${3}

  if [ -z "${__LOG_MODE__}" ] || [ "${__LOG_MODE__}" == "std" ]; then
    logging_std "${LEVEL}" "${FUNCTION_NAME}" "${MESSAGE}"
  elif [ "${__LOG_MODE__}" == "file" ]; then
    logging_file "${LEVEL}" "${FUNCTION_NAME}" "${MESSAGE}" "${__LOG_FILE__}"
  else
    >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such log mode ${__LOG_MODE__}; might be std / file"
    system_exit 1
  fi
}

function get_log_level() {
  if [ -z "${__LOG_LEVEL__}" ]; then
    freturn "ERROR"
  else
    freturn "${__LOG_LEVEL__}"
  fi
}

function init_logger() {
  local MODE=${1}
  local LEVEL=${2}
  local FILE=${3}
  __LOG_LEVEL__=${LEVEL}
  __LOG_FILE__=${FILE}
  __LOG_MODE__=${MODE}
  if [ "${__LOG_MODE__}" == "file" ]; then
    if ( ! __check_file_exists "${FILE}" ); then
      touch "${FILE}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [INFO] (logging): file created"
    fi
  fi
}

function logging_std() {
  # level (str) - DEBUG / INFO / WARNING / ERROR (default) / CRITICAL
  # 	DEBUG - Detailed information, typically of interest only when diagnosing problems.
  # 	INFO - Confirmation that things are working as expected.
  # 	WARNING - An indication that something unexpected happened, or indicative of some problem in the near future (e.g. ‘disk space low’). The software is still working as expected.
  # 	ERROR - Due to a more serious problem, the software has not been able to perform some function.
  # 	CRITICAL - A serious error, indicating that the program itself may be unable to continue running.
  local LEVEL=${1}
  local FUNCTION_NAME=${2}
  local MESSAGE=${3}
  LOG_LEVEL=$(set_e && get_log_level)
  if [ "${LOG_LEVEL}" == "DEBUG" ]; then
    if [ "${LEVEL}" == "DEBUG" ] || [ "${LEVEL}" == "INFO" ] || [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
    else
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "INFO" ]; then
    if [ "${LEVEL}" == "INFO" ] || [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
    elif [ "${LEVEL}" != "DEBUG" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "WARNING" ]; then
    if [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "ERROR" ]; then
    if [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ] && [ "${LEVEL}" != "WARNING" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "CRITICAL" ]; then
    if [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ] && [ "${LEVEL}" != "WARNING" ] && [ "${LEVEL}" != "ERROR" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      system_exit 1
    fi
  else
    >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging level __LOG_LEVEL__=${LOG_LEVEL}"
    system_exit 1
  fi
}

function logging_file() {
  # level (str) - DEBUG / INFO / WARNING / ERROR (default) / CRITICAL
  # 	DEBUG - Detailed information, typically of interest only when diagnosing problems.
  # 	INFO - Confirmation that things are working as expected.
  # 	WARNING - An indication that something unexpected happened, or indicative of some problem in the near future (e.g. ‘disk space low’). The software is still working as expected.
  # 	ERROR - Due to a more serious problem, the software has not been able to perform some function.
  # 	CRITICAL - A serious error, indicating that the program itself may be unable to continue running.
  local LEVEL=${1}
  local FUNCTION_NAME=${2}
  local MESSAGE=${3}
  local FILE=${4}
  local LOG_LEVEL
  LOG_LEVEL=$(set_e && get_log_level)
  if [ "${LOG_LEVEL}" == "DEBUG" ]; then
    if [ "${LEVEL}" == "DEBUG" ] || [ "${LEVEL}" == "INFO" ] || [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> "${FILE}" 2>&1
    else
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> "${FILE}" 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> "${FILE}" 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "INFO" ]; then
    if [ "${LEVEL}" == "INFO" ] || [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> "${FILE}" 2>&1
    elif [ "${LEVEL}" != "DEBUG" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> "${FILE}" 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> "${FILE}" 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "WARNING" ]; then
    if [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> "${FILE}" 2>&1
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> "${FILE}" 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> "${FILE}" 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "ERROR" ]; then
    if [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> "${FILE}" 2>&1
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ] && [ "${LEVEL}" != "WARNING" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> "${FILE}" 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> "${FILE}" 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "CRITICAL" ]; then
    if [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> "${FILE}" 2>&1
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ] && [ "${LEVEL}" != "WARNING" ] && [ "${LEVEL}" != "ERROR" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> "${FILE}" 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> "${FILE}" 2>&1
      system_exit 1
    fi
  else
    >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging level __LOG_LEVEL__=${LOG_LEVEL}"
    >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging level __LOG_LEVEL__=${LOG_LEVEL}" >> "${FILE}" 2>&1
    system_exit 1
  fi
}

function develop_file_logging() {
  # level (str) - DEBUG / INFO / WARNING / ERROR (default) / CRITICAL
  # 	DEBUG - Detailed information, typically of interest only when diagnosing problems.
  # 	INFO - Confirmation that things are working as expected.
  # 	WARNING - An indication that something unexpected happened, or indicative of some problem in the near future (e.g. ‘disk space low’). The software is still working as expected.
  # 	ERROR - Due to a more serious problem, the software has not been able to perform some function.
  # 	CRITICAL - A serious error, indicating that the program itself may be unable to continue running.
  local LEVEL=${1}
  local FUNCTION_NAME=${2}
  local MESSAGE=${3}
  LOG_LEVEL="DEBUG"
  if [ "${LOG_LEVEL}" == "DEBUG" ]; then
    if [ "${LEVEL}" == "DEBUG" ] || [ "${LEVEL}" == "INFO" ] || [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> develop_log.log 2>&1
    else
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> develop_log.log 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> develop_log.log 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "INFO" ]; then
    if [ "${LEVEL}" == "INFO" ] || [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> develop_log.log 2>&1
    elif [ "${LEVEL}" != "DEBUG" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> develop_log.log 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> develop_log.log 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "WARNING" ]; then
    if [ "${LEVEL}" == "WARNING" ] || [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> develop_log.log 2>&1
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> develop_log.log 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> develop_log.log 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "ERROR" ]; then
    if [ "${LEVEL}" == "ERROR" ] || [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> develop_log.log 2>&1
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ] && [ "${LEVEL}" != "WARNING" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> develop_log.log 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> develop_log.log 2>&1
      system_exit 1
    fi
  elif [ "${LOG_LEVEL}" == "CRITICAL" ]; then
    if [ "${LEVEL}" == "CRITICAL" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [${LEVEL}] (${FUNCTION_NAME}): ${MESSAGE}" >> develop_log.log 2>&1
    elif [ "${LEVEL}" != "DEBUG" ] && [ "${LEVEL}" != "INFO" ] && [ "${LEVEL}" != "WARNING" ] && [ "${LEVEL}" != "ERROR" ]; then
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL"
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging type ${LEVEL}" >> develop_log.log 2>&1
      >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): allowed types is DEBUG / INFO / WARNING / ERROR / CRITICAL" >> develop_log.log 2>&1
      system_exit 1
    fi
  else
    >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging level __LOG_LEVEL__=${LOG_LEVEL}"
    >&2 echo -e "$(set_e && date +%Y.%m.%d-%H:%M:%S) [CRITICAL] (logging): no such logging level __LOG_LEVEL__=${LOG_LEVEL}" >> develop_log.log 2>&1
    system_exit 1
  fi
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi