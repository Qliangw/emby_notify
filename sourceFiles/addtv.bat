@echo off
echo "%1" "%2"

set w=%1
set "w=%w: =%"
set v=%2
set "v=%v: =%"

python "D:\RJ\BARK\pushmessage.py" "EMBY�������������" "�缯��%w%" "���飺%v%" "ʱ�䣺%time%"