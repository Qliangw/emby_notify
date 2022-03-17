#!/bin/sh

versionX="0.0.2"
updateX="2022-03-16"


BASE_ROOT=$(cd "$(dirname "$0")";pwd)
TOOLS_DIR=${BASE_ROOT}/tools
cd $BASE_ROOT
. ./user.conf

PIC_URL0="https://s2.loli.net/2022/03/17/dQCgS5mhX2lBFs9.jpg"
PIC_URL1="https://s2.loli.net/2022/03/17/amj947HFM3I5TPl.jpg"
PIC_URL2="https://s2.loli.net/2022/03/17/6L9XIStKPChUHlV.jpg"
TEMP_PIC=PIC_URL$SELECT_PIC
DEFAULT_PIC=$(eval echo '$'"$TEMP_PIC")
rm ./log.txt
echo $DEFAULT_PIC >> ./log.txt

MOV_NAME=$3
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
    echo "base_root:" $BASE_ROOT
    echo "TMDB_API_KEY:" $TMDB_API_KEY
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
    echo "电影入库脚本入口："
    MOV_NAME=$2
    MOV_MSG=$3
    MEDIA_TYPE="movie"
    get_img_url
    if [ $MOV_MSG = "%item.overview%" ]; then
    MOV_MSG="暂无简介"
    fi
    MOV_NAME="$(echo "$MOV_NAME" | sed 's/[ ][ ]*//g')"
    MSG="剧情：$MOV_MSG\n时间：$(date +'%H:%M:%S')"
    TITLE="电源入库：$MOV_NAME" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "AT" ]; then
    echo "电视剧入库脚本入口：" 
    TV_NAME=$2
    TV_MSG=$3
    MEDIA_TYPE="tv"
    get_img_url
    case $TV_NAME in
        *"$SEASON_NULL"* )
            TV_NAME="$(echo "$TV_NAME" | sed 's/\%season\.number\%/0/g')" ;;
    esac
    
    if [ $TV_MSG = "%item.overview%" ]; then
        TV_MSG="暂无简介"
    fi
    
    TV_NAME="$(echo "$TV_NAME" | sed 's/[ ][ ]*//g')"
    TV_MSG="$(echo "$TV_MSG" | sed 's/[ ][ ]*//g')"
    TITLE="剧集入库：$MOV_NAME" >> ./log.txt
    MSG="剧情：$TV_MSG\n时间：$(date +'%H:%M:%S')"
    parse_msg
    push_all
elif [ $1 = "PM" ]; then
    MEDIA_TYPE="movie"
    get_img_url
    MOV_NAME="$(echo "$MOV_NAME" | sed 's/[ ][ ]*//g')"
    MSG="用户：$2\n电影：$MOV_NAME\n时间：$(date +'%H:%M:%S')" >> ./log.txt
    TITLE="播放电影：$MOV_NAME" >> ./log.txt
    parse_msg
    push_all
elif [ $1 = "PT" ]; then
    MEDIA_TYPE="tv"
    get_img_url
    MOV_NAME="$(echo "$MOV_NAME" | sed 's/[ ][ ]*//g')"
    MSG="用户：$2\n剧集：$MOV_NAME\n时间：$(date +'%H:%M:%S')" >> ./log.txt
    TITLE="播放剧集：$MOV_NAME" >> ./log.txt
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
else
    echo "请输入正确参数，notify.sh -h查看帮助"
fi