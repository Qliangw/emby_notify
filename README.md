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

## [使用方法](https://qliangw.notion.site/emby_notify-898e4531fa314a9bbc15613778b116f6)


### 播放电影填写示例

   <img src="https://raw.githubusercontent.com/Qliangw/emby_notify/main/img/test1.jpg" style="zoom: 50%;" />
   
   





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
