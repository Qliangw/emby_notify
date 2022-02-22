# emby_notify
改一下现有的win版emby登录、添加、播放等通知，使其支持Linux环境。

能力和时间有限，仅仅实现了基本的几个功能，plex用户表示后续更不更新还不好说（逃

**适用范围**

1. docker安装的emby（支持Linuxserver、emby官方）
2. 群晖套件版(支持6.x，7.x未测试，理论可行)
3. 其他linux环境安装的emby（也没有测试）

## 使用方法

1. 打开emby服务端的设置->插件
2. 安装 [Emby Scripter-X ](https://github.com/AnthonyMusgrove/Emby-ScripterX "Emby Scripter-X ") ，重启emby服务器，若已安装请跳过步骤1、2
3. 下载该脚本库到本地，放入emby有权限读取到的位置
3. 配置push.sh脚本中企业微信的参数（目前仅支持这一个通知方式）[参考这里](http://note.youdao.com/s/HMiudGkb "参考这里")
3. 请参考[sourceFiles文件](https://github.com/Qliangw/emby_notify/tree/main/sourceFiles "sourceFiles文件")中的截图，把cmd命令更换为/bin/sh，运行的脚本更换为脚本路径及脚本名称即可，修改后的配置如图所示

![](https://raw.githubusercontent.com/Qliangw/emby_notify/main/pic/demo.png)

## 鸣谢

感谢某群友提供的win版脚本
