#!/bin/sh
BASE_ROOT=$(cd "$(dirname "$0")";pwd)
cd $BASE_ROOT
MOV_NAME=$1
MOV_MSG=$2
MOV_NAME="$(echo "$MOV_NAME" | sed 's/[ ][ ]*//g')"
MOV_MSG="$(echo "$MOV_MSG" | sed 's/[ ][ ]*//g')"
MSG="剧集：$1\n剧情：$2\n时间：$(date +'%H:%M:%S')"
PUSH_DIGEST=${MSG}
PUSH_CONTENT="$(echo "$PUSH_DIGEST" | sed 's/\\n/\<br\/\>/g')"
# echo ${PUSH_CONTENT} >> /config/config/script/tmp.log
./push.sh "新媒体入库" "${PUSH_DIGEST}" "${PUSH_CONTENT}"