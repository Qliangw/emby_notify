# emby_notify
改一下现有的win版emby登录、添加、播放等通知，使其支持Linux环境。

能力和时间有限，仅仅实现了基本的几个功能，plex用户表示后续更不更新还不好说（逃

**适用范围**

1. docker安装的emby（支持Linuxserver、emby官方）
2. 群晖套件版(支持6.x，7.x未测试，理论可行)
3. 其他linux环境安装的emby（也没有测试）

## 通知功能

- [x] 登录成功、失败
- [x] 新媒体入库
- [x] 播放开始、暂停
- [x] 支持[企业微信](https://work.weixin.qq.com/) 、[Pushplus](https://www.pushplus.plus/)、[Bark](https://github.com/Finb/Bark)(仅iOS)通知
- [x] 企业微信通知附带海报图

**TODO**

- [x] 添加其他通知工具的适配
- [x] 通知附带海报图
- [ ] 剧集通知模式为[S01E01] 或者 [第一季 第一集]【可选】
- [x] 整合脚本，使其配置通用简洁

## 使用方法

1. 打开emby服务端的设置->插件
2. 安装 [Emby Scripter-X ](https://github.com/AnthonyMusgrove/Emby-ScripterX "Emby Scripter-X ") ，重启emby服务器，若已安装请跳过步骤1、2
3. 下载该脚本库到本地，放入emby有权限读取到的位置
4. 复制一份user.conf.default重命名为user.conf配置脚本中企业微信的参数（目前仅支持这一个通知方式）[参考这里](http://note.youdao.com/s/HMiudGkb "参考这里")
5. **请仔细参考[sourceFiles文件](https://github.com/Qliangw/emby_notify/tree/main/sourceFiles "sourceFiles文件")中的截图**，把cmd命令更换为/bin/sh，~~运行的脚本更换为脚本路径及脚本名称即可~~



### 播放电影填写示例

1. 进入emby服务端打开scripter-x创建任务

![](https://raw.githubusercontent.com/Qliangw/emby_notify/main/img/step1.png)



2. 编译任务

   RUN这里填写 /path/to/notify.sh [功能参数]

   <img src="https://raw.githubusercontent.com/Qliangw/emby_notify/main/img/demo2.png" style="zoom:50%;" />

3. 通知效果

   <img src="https://raw.githubusercontent.com/Qliangw/emby_notify/main/img/test1.jpg" style="zoom: 50%;" />
   
   

### 参数
|功能|功能参数|scriptx的参数|
|---|---|:--|
|播放电影 | PM       | "%username%" "%item.name%（%item.productionyear%）" "%item.meta.tmdb%" "%item.overview%" %device.name% %playback.position.percentage% |
| 播放剧集 | PT       |"%username%" "%series.name%" "%series.meta.tmdb%" "%item.overview%" "%device.name%" "%playback.position.percentage%" "%season.number%" "%episode.number%"|
|登录失败 | LF       | %username% %device.remote.ipaddress% %password% %device.name% |
|登录成功| LS |%username% %device.remote.ipaddress% %device.name%|
|电影入库|AM|"%item.name%（%item.productionyear%）" "%item.overview%" "%item.meta.tmdb%"|
|剧集入库|AT|"%series.name%" "%item.overview%" "%series.meta.tmdb%" "%season.number%" "%episode.number%"|
|停止播放电影|SM|"%username%" "%item.name%（%item.productionyear%）" "%item.meta.tmdb%" %device.name%|
|停止播放剧集|ST|"%username%" "%series.name%" "%series.meta.tmdb%" "%device.name%" "%season.number%" "%episode.number%"|



## 默认推送图

| 序号 | 展示                                                         |
| ---- | ------------------------------------------------------------ |
| 0    | <img src="https://s2.loli.net/2022/03/17/dQCgS5mhX2lBFs9.jpg" style="zoom:33%;" /> |
| 1    | <img src="https://s2.loli.net/2022/03/17/amj947HFM3I5TPl.jpg" style="zoom:33%;" /> |
| 2    | <img src="https://s2.loli.net/2022/03/17/6L9XIStKPChUHlV.jpg" style="zoom:33%;" /> |
| 3   | <img src="https://s2.loli.net/2022/03/18/TBKDNwUdmPcZ8tX.png" style="zoom:33%;" /> |
| 4    | <img src="https://s2.loli.net/2022/03/18/3wsMPkABUFyNO12.png" style="zoom:33%;" /> |



## 鸣谢

- 感谢某群友提供的win版脚本。
- 感谢 [Hiccup](https://github.com/Hiccup90) 大佬提供的tmdb海报脚本
- 感谢群友老哥们提供的默认推送图
- **感谢鞭策我的堂众们（要不催就不更了**
