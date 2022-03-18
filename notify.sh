#!/bin/sh
versionX="0.0.3"
updateX="2022-03-18"
BASE_ROOT=$(cd "$(dirname "$0")";pwd)
TOOLS_DIR=${BASE_ROOT}/tools
cd $BASE_ROOT
. ./user.conf
# 苏神yyds
PIC_URL0="https://s2.loli.net/2022/03/17/dQCgS5mhX2lBFs9.jpg"
PIC_URL1="https://s2.loli.net/2022/03/17/amj947HFM3I5TPl.jpg"
# 仔老师提供
PIC_URL2="https://s2.loli.net/2022/03/17/6L9XIStKPChUHlV.jpg"
# 滑妹提供
PIC_URL3="https://s2.loli.net/2022/03/18/TBKDNwUdmPcZ8tX.png"
PIC_URL4="https://s2.loli.net/2022/03/18/3wsMPkABUFyNO12.png"
TEMP_PIC=PIC_URL$SELECT_PIC
DEFAULT_PIC=$(eval echo '$'"$TEMP_PIC")
if [ ! -f "./log.txt" ]; then
    echo ""
else
    rm ./log.txt
fi

echo $DEFAULT_PIC >> ./log.txt

TMDB_ID=$4

#推送渠道
function push_channel()
{
    echo ""
    TOKEN=$TMDB_API_KEY
    echo $TOKEN
    PIC_URL=""
}

# 根据推送渠道处理数据
function parse_msg()
{
    PUSH_DIGEST=${MSG}
    PUSH_CONTENT="$(echo "$PUSH_DIGEST" | sed 's/\\n/\<br\/\>/g')"
}


function push_all()
{
    # parse_msg
    ./push.sh "$TITLE" "${PUSH_DIGEST}" "${PUSH_CONTENT}" "$IMG_PUSH" >> ./log.txt
}

# 版本信息
function version()
{
    echo -e "--Version:${versionX}" "\\n--update time:${updateX}"
    exit 0
}

# 帮助文档
function display_help()
{
    echo "Usage: $0 [option...] {AM|AT|PM|PT|LS|LF}" >&2
    echo "   AM, --add-movie         添加movie"
    echo "   AT, --add-tv            添加TV"
    echo "   PM, --play-movie        播放movie"
    echo "   PT, --play-tv           播放tv"
    echo "   SM, --play-movie        停止播放movie"
    echo "   ST, --play-tv           停止播放tv"
    echo "   LS, --login-success     登录成功"
    echo "   LF, --login-failed      登录失败"
    echo "   -v, --version           版本信息"
    echo "   -h, --help              帮助信息"
    echo
    # echo some stuff here for the -a or --add-options 
    exit 0
}

function test()
{
    echo "base_root:" $BASE_ROOT >> ./log.txt
    echo "测试通知" >> ./log.txt

    TITLE="测试通知"
    MSG="内容：无\n时间：$(date +'%H:%M:%S')"
    echo $MSG >> ./log.txt
    IMG_PUSH=$DEFAULT_PIC
    parse_msg
    push_all
}

function get_new_str()
{
    len_old_str=${#old_str}
    echo "字符串长度：" "${len_old_str}" >> ./log.txt
    if [ $len_old_str -gt 120 ]; then
        echo "字符串大约120"
        new_str="${old_str:0:120}...."
    else
        new_str=$old_str
    fi
    echo ""
}


function get_img_url()
{
    echo "电影播放脚本入口：" >> ./log.txt
    echo "TMDB_ID：" "$TMDB_ID" >> ./log.txt
    RES_TMDB=$("${TOOLS_DIR}"/curl -s 'https://api.themoviedb.org/3/'${MEDIA_TYPE}'/'${TMDB_ID}'/images?api_key='${TMDB_API_KEY}'')
    IMG_PATH=$(echo ${RES_TMDB} | "${TOOLS_DIR}"/jq --raw-output '.backdrops | .[0] | .file_path')
    echo "图片路径：" $IMG_PATH >> ./log.txt
    RES_FIND_JPG=$(echo $IMG_PATH | grep "jpg")
    echo "是否找到：" $RES_FIND_JPG >> ./log.txt
    IMG_PUSH=""
    if [ "$RES_FIND_JPG" = ""  ]; then
        # echo "取得图片：" $PIC_URL
        IMG_PUSH=$DEFAULT_PIC
        echo "为空" >> ./log.txt
    else
        # PIC_URL=$DEFAULT_PIC
        IMG_PUSH="https://image.tmdb.org/t/p/w500${IMG_PATH}"
        echo "图片：" $IMG_PUSH >> ./log.txt
        echo "非空" >> ./log.txt
    fi
}


# 参数执行
if [ ! "$1" ]; then
    echo "空参"
elif [ "$1" = "-v" ]; then
   version
elif [ $1 = "AM" ]; then
    # 2-剧名|3-剧情|4-tmdb
    echo "电影入库脚本入口："
    MEDIA_NAME=$2
    MEDIA_MSG=$3
    TMDB_ID=$4
    MEDIA_TYPE="movie"

    get_img_url

    if [ $MEDIA_MSG = "%item.overview%" ]; then
        MEDIA_MSG="暂无简介"
    fi
    old_str=$MEDIA_MSG
    get_new_str
    MEDIA_MSG=$new_str

    MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"

    MSG="剧情：$MEDIA_MSG\n时间：$(date +'%H:%M:%S')"
    TITLE="电影入库：$MEDIA_NAME" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "AT" ]; then
    # 2-剧名|3-剧情|4-tmdb|5-季x|6-集x
    echo "电视剧入库脚本入口："
    MEDIA_NAME=$2
    MEDIA_MSG=$3
    TMDB_ID=$4
    SEASON_NUM=$5
    EPISODE_NUM=$6
    SE_NUM="S${SEASON_NUM}E${EPISODE_NUM}"
    MEDIA_TYPE="tv"
    get_img_url
    case $MEDIA_NAME in
        *"$SEASON_NULL"* )
            MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/\%season\.number\%/0/g')" ;;
    esac

    if [ $MEDIA_MSG = "%item.overview%" ]; then
        MEDIA_MSG="暂无简介"
    fi

    old_str=$MEDIA_MSG
    get_new_str
    MEDIA_MSG=$new_str

    MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"
    MEDIA_MSG="$(echo "$MEDIA_MSG" | sed 's/[ ][ ]*//g')"
    TITLE="剧集入库：$MEDIA_NAME-${SE_NUM}"
    MSG="剧情：$MEDIA_MSG\n时间：$(date +'%H:%M:%S')"
    parse_msg
    push_all
elif [ $1 = "PM" ]; then
    # 0-脚本
    # 1-脚本参数
    # 2-用户名|3-剧名|4-tmdb|5-剧情|6-设备|7-占比
    MEDIA_TYPE="movie"
    MEDIA_NAME=$3
    MEDIA_MSG=$5
    DEV_NAME=$6
    PERCENT=$7

    get_img_url

    if [ $MEDIA_MSG = "%item.overview%" ]; then
        MEDIA_MSG="暂无简介"
    fi
    MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"
    echo "$MEDIA_MSG" >> ./log.txt
    old_str=$MEDIA_MSG
    get_new_str
    MEDIA_MSG=$new_str
    MSG="用户：$2\n设备：$DEV_NAME\n进度：$PERCENT%\n剧情：$MEDIA_MSG\n时间：$(date +'%H:%M:%S')"

    TITLE="播放电影：$MEDIA_NAME"
    echo "$TITLE" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "PT" ]; then
    # 0-脚本
    # 1-脚本参数
    # 2-用户名|3-剧名|4-tmdb|5-剧情|6-设备|7-占比|8-季x|9-集x|
    MEDIA_NAME=$3
    TMDB_ID=$4
    MEDIA_MSG=$5
    DEV_NAME=$6
    PERCENT=$7
    SEASON_NUM=$8
    EPISODE_NUM=$9
    SE_NUM="S${SEASON_NUM}E${EPISODE_NUM}"
    MEDIA_TYPE="tv"
    get_img_url
    if [ $MEDIA_MSG = "%item.overview%" ]; then
    MEDIA_MSG="暂无简介"
    fi
    MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"
    echo "$MEDIA_MSG" >> ./log.txt
    old_str=$MEDIA_MSG
    get_new_str
    MEDIA_MSG=$new_str
    MSG="用户：$2\n设备：$DEV_NAME\n进度：$PERCENT%\n剧情：$MEDIA_MSG\n时间：$(date +'%H:%M:%S')"
    # MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"
    # MSG="用户：$2\n剧集：$MEDIA_NAME\n时间：$(date +'%H:%M:%S')"
    TITLE="播放剧集：${MEDIA_NAME}-${SE_NUM}"
    echo "$TITLE" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "SM" ]; then
    # 0-脚本
    # 1-脚本参数
    # 2-用户名|3-剧名|4-tmdb|5-设备
    echo "电影停止" >> ./log.txt
    MEDIA_TYPE="movie"
    MEDIA_NAME=$3
    DEV_NAME=$5
    get_img_url
    MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"
    MSG="用户：$2\n设备：$DEV_NAME\n时间：$(date +'%H:%M:%S')"
    TITLE="停止播放电影：$MEDIA_NAME"
    echo "$TITLE" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "ST" ]; then
    # 0-脚本
    # 1-脚本参数
    # 2-用户名|3-剧名|4-tmdb|5-设备|6-季x|7-集x|
    echo "剧集停止" >> ./log.txt
    MEDIA_NAME=$3
    DEV_NAME=$5
    SEASON_NUM=$6
    EPISODE_NUM=$7
    SE_NUM="S${SEASON_NUM}E${EPISODE_NUM}"
    MEDIA_TYPE="tv"
    get_img_url
    MEDIA_NAME="$(echo "$MEDIA_NAME" | sed 's/[ ][ ]*//g')"
    MSG="用户：$2\n设备：$DEV_NAME\n时间：$(date +'%H:%M:%S')"
    TITLE="停止播放剧集：${MEDIA_NAME}-${SE_NUM}"
    echo "$TITLE" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "LS" ]; then
    MSG="用户：$2\n地址：$3\n时间：$(date +'%H:%M:%S')\n设备：$4"
    TITLE="登录成功"
    IMG_PUSH=$DEFAULT_PIC
    parse_msg
    push_all
elif [ $1 = "LF" ]; then
    MSG="用户：$2\n地址：$3\n密码：$4\n时间：$(date +'%H:%M:%S')\n设备：$5"
    TITLE="登录失败"
    IMG_PUSH=$DEFAULT_PIC
    parse_msg
    push_all
elif [ $1 = "-h" ]; then
    display_help
elif [ $1 = "test" ]; then
    test
    # se_test
else
    echo "请输入正确参数，notify.sh -h查看帮助"
fi
