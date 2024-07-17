#!/bin/bash

# 打印带边框的消息
# Usage: get_decorated_info <info> <fill_char>
get_decorated_info() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <info>"
        exit 1
    fi
    message="$1"
    fill_char=$2
    fill_char=${fill_char:-"="}
    # 获取终端的宽度
    term_width=$(stty size | awk '{print $2}')
    # 计算消息的长度
    message_length=${#message}
    # 计算左右边距的长度
    padding_length=$(((term_width - message_length - 2) / 4))
    line=$(printf '%*s' "$padding_length" '' | tr ' ' "$fill_char")

    echo "${line} ${message} ${line}"
}

# 打印日志
# Usage: func_logging <content>
function func_logging() {
    if [ $# -lt 1 ]; then
        content='Warning-Content-Missing'
    else
        content_array=("$@")
        content=${content_array[*]}
    fi

    file_name=$(basename "$0")
    echo "file_name: $file_name | line: $LINENO | user: $(whoami) | host: $(hostname) | time: $(date +'%Y-%m-%d %H:%M:%S') -  ${content}"
}

# 绑定java到JAVA_RUN
bind_java_run() {
    JAVA_HOME="${JAVA_HOME:-"/usr/local/java"}"
    if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME"/bin/java ]; then
        JAVA_RUN="${JAVA_HOME}/bin/java"
    fi

    if [ -z "$JAVA_RUN" ]; then
        JAVA_RUN=$(which java 2>/dev/null)
    fi

    if [ -z "$JAVA_RUN" ]; then
        echo "can't find java, and JAVA_HOME is not set" >&2
        exit 1
    fi
}

# 绑定python到PYTHON_RUN
bind_python_run() {
    # 通过Python_Home环境变量查找Python
    PYTHON_HOME="${PYTHON_HOME:-"/usr/local/python"}"
    if [ -n "$PYTHON_HOME" ] && [ -f "$PYTHON_HOME"/bin/python ]; then
        PYTHON_RUN="${PYTHON_HOME}/bin/python"
    fi

    # 如果还没有找到Python, 则通过which查找python指令并bind到PYTHON_RUN
    if [ -z "$PYTHON_RUN" ]; then
        PYTHON_RUN=$(which python 2>/dev/null)
    fi

    # 如果还没有找到Python,使用conda查找python指令并bind到PYTHON_RUN
    if [ -z "$PYTHON_RUN" ] && [ -n "$CONDA_PYTHON_EXE" ]; then
        PYTHON_RUN="$CONDA_PYTHON_EXE"
    fi

    if [ -z "$PYTHON_RUN" ]; then
        echo "can't find python, and PYTHON_HOME is not set" >&2
        exit 1
    fi
}

# 绑定hive到HIVE_RUN
bind_hive_run() {
    if [ -n "$HIVE_HOME" ] && [ -f "$HIVE_HOME"/bin/hive ]; then
        HIVE_RUN="${HIVE_HOME}/bin/hive"
    fi

    if [ -z "$HIVE_RUN" ] && [ "$(command -v hive)" ]; then
        HIVE_RUN="hive"
    fi

    if [ -z "$HIVE_RUN" ]; then
        echo "HIVE_HOME is not set" >&2
        exit 1
    fi
}

# 删除末尾特定字符
remove_trailing_chars() {
    # remove_trailing_chars <str> <remove_char>
    _string="$1"
    char_to_remove="$2"
    while [[ "${_string:(-1)}" == "$char_to_remove" ]]; do
        _string="${_string%"${_string:(-1)}"}"
    done
    echo "$_string"
}

# 删除开头特定字符
remove_start_char() {
    # remove_start_char <str> <remove_char>
    _string="$1"
    char_to_remove="$2"
    while [[ "$_string" == "$char_to_remove"* ]]; do
        _string="${_string#"$char_to_remove"}"
    done
    echo "${_string}"
}

# 打印所有系统变量
get_all_system_vars() {
    # get_all_system_vars
    for var_name in $(export | cut -d= -f1); do
        echo "$var_name"
    done
}
