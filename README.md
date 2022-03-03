# emby_notify
改一下现有的win版emby登录、添加、播放等通知，使其支持Linux环境。

能力和时间有限，仅仅实现了基本的几个功能，plex用户表示后续更不更新还不好说（逃

**适用范围**

1. docker安装的emby（支持Linuxserver、emby官方）
2. 群晖套件版(支持6.x，7.x未测试，理论可行)
3. 其他linux环境安装的emby（也没有测试）

## 通知功能

- [x]  登录成功
- [x] 登录失败
- [x] 媒体入库
- [x] 播放媒体

**TODO**

- [] 添加其他通知工具的适配
- [] 通知附带海报图
- [] 剧集通知模式为[S01E01] 或者 [第一季 第一集]【可选】

## 使用方法

1. 打开emby服务端的设置->插件
2. 安装 [Emby Scripter-X ](https://github.com/AnthonyMusgrove/Emby-ScripterX "Emby Scripter-X ") ，重启emby服务器，若已安装请跳过步骤1、2
3. 下载该脚本库到本地，放入emby有权限读取到的位置
3. 复制一份user.conf.default重命名为user.conf配置脚本中企业微信的参数（目前仅支持这一个通知方式）[参考这里](http://note.youdao.com/s/HMiudGkb "参考这里")
3. **请仔细参考[sourceFiles文件](https://github.com/Qliangw/emby_notify/tree/main/sourceFiles "sourceFiles文件")中的截图**，把cmd命令更换为/bin/sh，运行的脚本更换为脚本路径及脚本名称即可

### 播放电影填写示例

1. 进入emby服务端打开scripter-x创建任务

   ![](https://raw.githubusercontent.com/Qliangw/emby_notify/main/pic/step1.png)



2. 编译任务

   ![](https://raw.githubusercontent.com/Qliangw/emby_notify/main/pic/step2.png)

3. 通知效果（图片来源某群友）

   ![](https://raw.githubusercontent.com/Qliangw/emby_notify/main/pic/step3.png)

### 参数
|功能|对应脚本|参数|
|---|---|---|
|播放电影 | [playmov.sh](https://github.com/Qliangw/emby_notify/blob/main/playmov.sh) | "%username%" "%item.name%（%item.productionyear%）"|
|播放电视剧| [playtv.sh](https://github.com/Qliangw/emby_notify/blob/main/playtv.sh) |"%username%" "%series.name%-S%season.number%E%episode.number%"|
|登录失败 | [loginfailed.sh](https://github.com/Qliangw/emby_notify/blob/main/loginfailed.sh) | %username% %device.remote.ipaddress% %password%|
|登录成功| [login.sh](https://github.com/Qliangw/emby_notify/blob/main/login.sh) |%username% %device.remote.ipaddress%|
|电影入库|[addmov.sh](https://github.com/Qliangw/emby_notify/blob/main/addmov.sh)|"%item.name%（%item.productionyear%）" "%item.overview%"|
|电视剧入库|[addtv.sh](https://github.com/Qliangw/emby_notify/blob/main/addtv.sh)|"%series.name%--S%season.number%E%episode.number%" "%item.overview%"|



## 鸣谢

感谢某群友提供的win版脚本。
