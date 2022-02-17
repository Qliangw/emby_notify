@echo off
echo "%1" "%2"
set v=%2
set "v=%v: =%"

python "D:\RJ\BARK\pushmessage.py" "EMBY：用户开始播放" "用户：%1" "剧集：%v%" "时间：%time%"