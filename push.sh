#!/bin/sh

CORPID=""
CORP_SECRET=""
AGENTID=""
MEDIA_ID=""
TOUSER=""

BASE_ROOT=$(cd "$(dirname "$0")";pwd)
TOOLS_DIR=${BASE_ROOT}/tools
cd ${BASE_ROOT}
RET=$("${TOOLS_DIR}"/curl -s https://qyapi.weixin.qq.com/cgi-bin/gettoken?"corpid="${CORPID}"&corpsecret="${CORP_SECRET}"")
KEY=$(echo ${RET} | "${TOOLS_DIR}"/jq -r .access_token)
if [ ! -n $MEDIA_ID  ]; then
cat>tmpFile<<EOF
{
    "touser" : "${TOUSER}",
    "msgtype" : "text",
    "agentid" : "${AGENTID}",
    "text" :
    {
        "content" : "$1"
    }
}
EOF
else
cat>tmpFile<<EOF
{
   "touser" : "${TOUSER}",
   "msgtype" : "mpnews",
   "agentid" : "${AGENTID}",
   "mpnews" : {
       "articles":[
           {
               "title": "$1", 
               "thumb_media_id": "${MEDIA_ID}",
               "author": "Emby通知",
               "content_source_url": "URL",
               "digest": "$2",
               "content": "$3"
            }
       ]
   },
   "safe":0,
   "enable_id_trans": 0,
   "enable_duplicate_check": 0,
   "duplicate_check_interval": 1800
}
EOF
fi

"${TOOLS_DIR}"/curl -d @tmpFile -XPOST https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="${KEY}"
echo ""
echo "删除临时文件"
rm ${BASE_ROOT}/tmpFile
