#!/bin/sh
BASE_ROOT=$(cd "$(dirname "$0")";pwd)
cd $BASE_ROOT

SEASON_NULL="%season.number%"

TV_NAME=$1
TV_MSG=$2
case $TV_NAME in
    *"$SEASON_NULL"* )
        TV_NAME="$(echo "$TV_NAME" | sed 's/\%season\.number\%/0/g')" ;;
esac
if [ $TV_MSG = "%item.overview%" ]; then
    TV_MSG="暂无简介"
fi
TV_NAME="$(echo "$TV_NAME" | sed 's/[ ][ ]*//g')"
TV_MSG="$(echo "$TV_MSG" | sed 's/[ ][ ]*//g')"

MSG="电影：$TV_NAME\n剧情：$TV_MSG\n时间：$(date +'%H:%M:%S')"
PUSH_DIGEST=${MSG}
PUSH_CONTENT="$(echo "$PUSH_DIGEST" | sed 's/\\n/\<br\/\>/g')"
# echo ${PUSH_CONTENT} >> /config/config/script/tmp.log
./push.sh "新媒体入库" "${PUSH_DIGEST}" "${PUSH_CONTENT}"