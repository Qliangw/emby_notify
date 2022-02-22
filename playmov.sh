#!/bin/sh
BASE_ROOT=$(cd "$(dirname "$0")";pwd)
cd $BASE_ROOT
MSG="用户：$1\n电影：$2\n时间：$(date +'%H:%M:%S')"
PUSH_DIGEST=${MSG}
PUSH_CONTENT="$(echo "$PUSH_DIGEST" | sed 's/\\n/\<br\/\>/g')"
# echo ${PUSH_CONTENT} >> /config/config/script/tmp.log
./push.sh "开始播放" "${PUSH_DIGEST}" "${PUSH_CONTENT}"