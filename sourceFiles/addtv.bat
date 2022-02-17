@echo off
echo "%1" "%2"

set w=%1
set "w=%w: =%"
set v=%2
set "v=%v: =%"

python "D:\RJ\BARK\pushmessage.py" "EMBY：添加了新内容" "剧集：%w%" "剧情：%v%" "时间：%time%"