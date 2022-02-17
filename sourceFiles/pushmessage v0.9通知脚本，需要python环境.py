# 郑重声明：
# 本脚本仅供学习使用，作者不负任何责任
#
# 修改日志:
#
# 26Oct2021:
# 1. 增加对telegram自定义机器人的支持, 配置变量telegram, telegramtoken, telegramchatid, 这里使用的是text的消息格式
# 2. 修正参数个数错误
# 3. 整理了各处的print函数
# 4. 有序打印每个通道的结果
#
# 25Oct2021:
# 1. 增加对pushplus的支持, 配置变量pushplus, pushplustoken即可，默认走wechat渠道, markdown格式
# 2. bark如果需要指定消息所在分组，通过判断标题来分组 - 自行编写getbarkgroup函数内容即可
# 3. 增加对smtp发送邮件的支持, 配置变量smtp, smtpserver, smtpserverport, smtp_sender, smtp_authcode, smtp_recipient即可
# 4. 增加对钉钉(dingtalk)群聊自定义机器人的支持, 配置变量dingtalk, dingtalksecret, dingtalkurl, 这里使用的是markdown的消息格式
# 5. 增加对企业微信(qywechat)群聊自定义机器人的支持, 配置变量qywechatrobot, qywechatroboturl, 这里使用的是markdown的消息格式
# 6. 增加对企业微信(qywechat)应用消息的支持, 配置变量qywechatapp, qywechatappcorpid, qywechatappsecret, qywechatappagentid, qywechatapptouser即可, 支持markdown或text
# 7. 增加对飞书(feishu)群聊自定义机器人的支持, 配置变量feishu, feishusecret, feishuurl这里使用的是text的消息格式
#
# 24Oct2021: 
# 1. 增加对爱语飞飞的支持，配置变量iyuu, iyuutoken即可
# 2. 处理urlopen时的ssl错误
#
#
# 脚本功能
# 推送消息到serverChan/bark，消息内容从参数中获得，其中第一个参数为消息的标题，从第二个参数开始，每个参数都会作为正文的一行显示
#
#
# 环境要求:
# python 3.x
# 
# 安装步骤
# 安装python并把python配置到环境变量path里面
# 配置变量serverChan, SCKEY, bark, barkurl即可
#
# 使用方法:
# python pushmessage.py "subject" "body_line1" "body_line2" "body_line3" [etc etc]
#

# 导入所需模块
import sys
from urllib import request
from urllib import parse
import ssl
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header
import time
import hmac
import hashlib
import base64
import json

# 如果使用bark的话, 并且希望根据标题分组，请修改下面这个getbarkgroup函数
def getbarkgroup(item):
    if item == "这里是标题1":
       return "分组a"
    elif item == "这里是标题2":
       return "分组b"
    elif item == "这里是标题3":
       return "分组c"
    elif item == "这里是标题4":
       return "分组d"
    # 可自行增加elif判断来丰富分组
    else:
       # 匹配不到任何标题时候，这里填默认分组，留空的话就是bark自己的默认分组
       return ""

# 此函数用于格式化dingtalk消息内容 - 这里不需要修改
def getdingtalkmessage(subject, body):
    json_text = {
        "msgtype": "markdown",
        "markdown": {
        "title": subject,
        "text": "#### **" + subject + "** \n\n" + body
        },
        "at": {
            "isAtAll": True
        }
    }
    return json_text

# 此函数用于格式化qywechatrobot消息内容 - 这里不需要修改
def getqywechatrobotmessage(subject, body):
    json_text = {
        "msgtype": "markdown",
        "markdown": {
            "content": "#### **" + subject + "** \n\n" + body
        },
        "at": {
            "isAtAll": True
        }
    }
    return json_text
    
# 此函数用户获取企业微信的token
def getqywechatapptoken(corpid,secret):
    resp = request.urlopen("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=" + corpid + "&corpsecret=" + secret)
    json_resp = json.loads(resp.read().decode())
    token = json_resp["access_token"]
    return token
    
# 此函数用户格式化qywechatapp消息内容 - 这里不需要修改
def getqywechatappmessage(touser, agentid, subject, body, type):
    json_md = {
        "touser": touser,
        "msgtype": "markdown",
        "agentid": agentid,
        "markdown": {
            "content": "#### **" + subject + "** \n\n" + body
        },
        "enable_duplicate_check": 0,
        "duplicate_check_interval": 1800
    }
    json_text = {
       "touser" : touser,
       "msgtype" : "text",
       "agentid" : agentid,
       "text" : {
           "content" : subject + "\n\n" + body
       },
       "safe":0,
       "enable_id_trans": 0,
       "enable_duplicate_check": 0,
       "duplicate_check_interval": 1800
    }
    if type == "markdown":
        return json_md
    else:
        return json_text

# 此函数用户格式化feishu消息内容 - 这里不需要修改
def getfeishumessage(subject, body, timestamp, sign):
    json_text = {
        "timestamp": timestamp,
        "sign": sign,
        "msg_type": "text",
        "content": {
            "text": subject + "\n\n" + body
        }
    } 
    return json_text

# 参数配置 - 如果使用serverChan, 则serverChan参数配置True, 否则配置False
serverChan = False
# 如果使用serverChan, 把SCKEY填在这里, 代码会自动识别新版SCKEY和旧版SCKEY然后进行端口的适配，如果不使用serverChan，则这里无需理会
SCKEY = ""


# 参数配置 - 如果使用bark, 则bark参数配置True, 否则配置False
bark = False
# 如果使用bark，把bark链接以及key填在这里, 如果不使用bark, 则这里无需理会
barkurl = ""
# 如果需要指定消息所在分组，通过判断标题来分组 - 自行编写getbarkgroup函数内容即可


# 参数配置 - 如果使用iyuu, 则iyuu参数配置True, 否则配置False
iyuu = False
# 如果使用iyuu, 把token填在这里, 如果不使用iyuu，则这里无需理会
iyuutoken = ""


# 参数配置 - 如果使用pushplus, 则pushplus参数配置为True, 否则配置False
pushplus = False
# 如果使用pushplus, 把token填在这里, 如果不使用pushplus, 则这里无需理会
pushplustoken = ""
# 如果使用pushplus, 把推送渠道填在这里, 如果不使用pushplus, 则这里无需理会, 一般情况下，也不需要理会
pushpluschannel = "wechat"
# 如果使用pushplus, 把消息模板填在这里，如果不适用pushplus, 则这里无需理会, 本脚本默认模板是markdown, html暂不支持
pushplustemplate = "markdown"


# 参数配置 - 如果使用smtp发送邮件, 则smtp参数配置True, 否则配置False
smtp = False
# 如果使用smtp发送邮件, 把smtp服务器地址配置在这里，例如smtp.qq.com
smtpserver = ""
# 如果使用smtp发送邮件, 把smtp服务器端口配置在这里，例如常用的465
smtpserverport = 465
# 如果使用smtp发送邮件, 填写发送方的邮件地址, 例如xxx@qq.com
smtp_sender = ""
# 如果使用smtp发送邮件, 填写发送方的邮件地址的授权码, 注意的是授权码不一定等同于密码, 例如qq邮箱或者163邮箱的授权码要在邮箱管理设置那里按指引获取
smtp_authcode = ""
# 如果使用smtp发送邮件, 填写收件方的邮件地址, 例如xxx@163.com
smtp_recipient = ""

# 参数配置 - 如果使用dingtalk群聊自定义机器人, 则dingtalk参数配置为True, 否则配置False
dingtalk = False
# 如果使用dingtalk群聊自定义机器人, 把机器人的加密密钥填在这里, 否则这里无需理会
dingtalksecret = ""
# 如果使用dingtalk群聊自定义机器人, 把机器人的webhook地址填在这里, 否则这里无需理会
dingtalkurl = ""


# 参数配置 - 如果使用企业微信(qywechat)群聊机器人, 则qywechatrobot参数配置为True, 否则配置False
qywechatrobot = False
# 如果使用企业微信(qywechat)群聊机器人, 把机器人的webhook地址填在这里, 否则这里无需理会
qywechatroboturl = ""


# 参数配置 - 如果使用企业微信(qywechat)应用消息, 则qywechatapp参数配置为True, 否则配置False
qywechatapp = False
# 如果使用企业微信(qywechat)应用消息, 把你的企业ID填在这里, 否则无需理会
qywechatappcorpid = ""
# 如果使用企业微信(qywechat)应用消息, 把你的应用Secret填在这里, 否则无需理会
qywechatappsecret = ""
# 如果使用企业微信(qywechat)应用消息, 把你的应用AgentID填在这里, 否则无需理会 -- 注意这里是填数字，不是字符串
qywechatappagentid = 0
# 如果使用企业微信(qywechat)应用消息, 把消息的接收用户填在这里, 否则无需理会
qywechatapptouser = ""
# 如果使用企业微信(qywechat)应用消息, 把消息的类型填在这里, 否则无需理会, 这里支持markdown和text, 如果是text的话可以通过微信插件推动微信上
qywechatappmessagetype = ""


# 参数配置 - 如果使用feishu群聊自定义机器人, 则feishu参数配置为True, 否则配置False
feishu = False
# 如果使用feishu群聊自定义机器人, 把机器人的加密密钥填在这里, 否则这里无需理会
feishusecret = ""
# 如果使用feishu群聊自定义机器人, 把机器人的webhook地址填在这里, 否则这里无需理会
feishuurl = ""


# 参数配置 - 如果使用telegram机器人, 则telegram参数配置True, 否则配置False
telegram = False
# 如果使用telegram机器人, 把机器人token填在这里, 否则这里无需理会
telegramtoken = ""
# 如果使用telegram机器人, 把机器人所在的chat id填在这里, 否则这里无需理会 - 注意的是chat id这里填的是数字，不是字符串, 正数id是机器人和你的对话, 负数id则是群聊对话
telegramchatid = 0

############## 这里开始，啥都不要改 ##############

# 初始化serverChan相关参数
if serverChan:
    if SCKEY.startswith("SCU"):
        scurl = "https://sc.ftqq.com/" + SCKEY + ".send"
    else:
        scurl = "https://sctapi.ftqq.com/" + SCKEY + ".send"

# 初始化bark相关参数
if bark:
    if not barkurl.endswith("/"):
        barkurl = barkurl + "/"

# 初始化iyuu相关参数
if iyuu:
    iyuuurl = "https://iyuu.cn/" + iyuutoken + ".send"

# 初始化pushplus相关参数
if pushplus:
    pushplusurl = "http://www.pushplus.plus/send?token=" + pushplustoken + "&channel=" + pushpluschannel + "&template=" + pushplustemplate

# 初始化smtp相关参数
# -- smtp好像没啥好初始化的

# 初始化dingtalk相关参数
if dingtalk:
    # 获取时间戳
    dingtalktimestamp = str(round(time.time() * 1000))
    # 处理签名 - 这里会使用密钥和时间戳
    secret_enc = dingtalksecret.encode("utf-8")
    string_to_sign = "{}\n{}".format(dingtalktimestamp, dingtalksecret)
    string_to_sign_enc = string_to_sign.encode("utf-8")
    hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
    dingtalksign = parse.quote_plus(base64.b64encode(hmac_code))
    dingtalkurl = dingtalkurl + "&timestamp={}&sign={}".format(dingtalktimestamp, dingtalksign)
    dingtalkurlheader = {
        "Content-Type": "application/json",
        "Charset": "UTF-8"
    }

# 初始化qywechatrobot相关参数
if qywechatrobot:
    qywechatrobotheader = {
        "Content-Type": "application/json;charset=UTF-8"
    }

# 初始化qywechatapp相关参数
if qywechatapp:
    qywechatappheader = {
        "Content-Type": "application/json;charset=UTF-8"
    }
    # 获取token
    qywechatapptoken = getqywechatapptoken(qywechatappcorpid, qywechatappsecret)
    # 格式化url
    qywechatappurl = "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=" + qywechatapptoken

# 初始化feishu相关参数
if feishu:
    # 获取时间戳
    feishutimestamp = str(round(time.time()))
    # 处理签名 - 这里会使用密钥和时间戳
    secret_enc = feishusecret.encode("utf-8")
    string_to_sign = "{}\n{}".format(feishutimestamp, feishusecret)
    string_to_sign_enc = string_to_sign.encode("utf-8")
    #hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
    hmac_code = hmac.new(string_to_sign_enc, digestmod=hashlib.sha256).digest()
    feishusign = base64.b64encode(hmac_code).decode('utf-8')
    feishuheader = {
        "Content-Type": "application/json",
        "Charset": "UTF-8"
    }

# 初始化telegram相关参数
if telegram:
    telegramurl = "https://api.telegram.org/bot" + telegramtoken + "/sendMessage?chat_id=" + str(telegramchatid)

# 处理SSL参数
ssl._create_default_https_context = ssl._create_unverified_context

# 判断参数个数，至少需要两个 - 一个标题，正文至少一行
if(len(sys.argv)<=2):
    # 如果参数小于两个，则推送一条错误消息
    if serverChan:
        scurl = scurl + "?text=" + parse.quote("参数个数不对!") + "&desp=null"
    if bark:
        barkurl = barkurl + parse.quote("参数个数不对!") + "/null"
    if iyuu:
        iyuuurl = iyuuurl + "?text=" + parse.quote("参数个数不对!") + "&desp=null"
    if pushplus:
        pushplusurl = pushplusurl + "&title=" + parse.quote("参数个数不对!") + "&content=null"
    if smtp:
        smtpmailsubject = Header("参数个数不对!", 'utf-8').encode()
        smtpmailbody = MIMEText("null", 'plain', 'utf-8')
    if dingtalk:
            dingtalksubject = "参数个数不对!"
            dingtalkmessage = getdingtalkmessage(dingtalksubject, "null")
    if qywechatrobot:
            qywechatrobotsubject = "参数个数不对!"
            qywechatrobotmessage = getqywechatrobotmessage(qywechatrobotsubject, "null")
    if qywechatapp:
            qywechatappsubject = "参数个数不对!"
            qywechatappmessage = getqywechatappmessage(qywechatapptouser, qywechatappagentid, qywechatappsubject, "null", qywechatappmessagetype)
    if feishu:
            feishusubject = "参数个数不对!"
            feishumessage = getfeishumessage(feishusubject, "null", feishutimestamp, feishusign)
    if telegram:
        telegramurl = telegramurl + "&text=" + parse.quote("参数个数不对! \n\nnull")
else:
    # 初始化正文为空
    desp = ""
    # 第一个参数为标题，这里不特别处理，然后从第二个参数开始，一直处理到最后一个参数，每个参数为正文里的一行
    for i in range(2,len(sys.argv)):
        v = sys.argv[i]

        # 如果参数是一个http连接，这里会对其进行脱敏操作, 主要是此脚本要是用于推送tracker地址的话，passkey也会随之被推送，脱敏操作会只把主机拿出来
        if v.startswith("http://") or v.startswith("https://"):
            parsed_url = parse.urlparse(v)
            v = parsed_url.netloc
        desp = desp + v + "\n\n"
    if(len(desp)>0):
        if serverChan:
            # serverChan格式为https://sctapi.ftqq.com/<SCKEY>.send&text=<标题>&desp=<正文>
            scurl = scurl + "?text=" + parse.quote(sys.argv[1]) + "&desp=" + parse.quote(desp)
            #print(scurl)
        if bark:
            # bark格式为https://<yoururl>/<yourkey>/<标题>/<正文>
            barkurl = barkurl + parse.quote(sys.argv[1]) + "/" + parse.quote(desp)
            barkgroup = getbarkgroup(sys.argv[1])
            if (len(barkgroup)>0):
                # 分组的话在消息后面加上?group=<分组名称>
                barkurl = barkurl + "?group=" + parse.quote(barkgroup)
            #print(barkurl)
        if iyuu:
            # iyuu格式为https://iyuu.cn/<iyuutoken>.send&text=<标题>&desp=<正文>
            iyuuurl = iyuuurl + "?text=" + parse.quote(sys.argv[1]) + "&desp=" + parse.quote(desp)
            #print(iyuuurl)		
        if pushplus:
            # pushplus格式为http://www.pushplus.plus/send?token=<pushplustoken>&channel=<pushpluschannel>&template=<pushplustemplate>&title=<标题>&content=<正文>
            pushplusurl = pushplusurl + "&title=" + parse.quote(sys.argv[1]) + "&content=" + parse.quote(desp)
            #print(pushplusurl)
        if smtp:
            # smtp和其他推送方法不同, 这里是用smtplib组件来实现
            smtpmailsubject = Header(sys.argv[1], 'utf-8').encode()
            smtpmailbody = MIMEText(desp, 'plain', 'utf-8')
        if dingtalk:
            # dingtalk使用的是webhook方式调用 - 这里后面会使用post方法推送参数
            dingtalksubject = sys.argv[1]
            dingtalkmessage = getdingtalkmessage(dingtalksubject, desp)
        if qywechatrobot:
            # qywechatrobot使用的是webhook方式调用 - 这里后面会使用post方法推送参数
            qywechatrobotsubject = sys.argv[1]
            qywechatrobotmessage = getqywechatrobotmessage(qywechatrobotsubject, desp)
        if qywechatapp:
            # qywechatapp使用的是webhook方式调用 - 这里后面会使用post方法推送参数
            qywechatappsubject = sys.argv[1]
            qywechatappmessage = getqywechatappmessage(qywechatapptouser, qywechatappagentid, qywechatappsubject, desp, qywechatappmessagetype)
        if feishu:
            # feishu使用的是webhook方式调用 - 这里后面会使用post方法推送参数
            feishusubject = sys.argv[1]
            feishumessage = getfeishumessage(feishusubject, desp, feishutimestamp, feishusign)
        if telegram:
            # telegram格式为https://api.telegram.org/bot<token>/sendMessage?chat_id=<chat_id>&text=<正文>
            telegramurl = telegramurl + "&text=" + parse.quote(sys.argv[1] + "\n\n" + desp)
            #print(telegramurl)

# 发送消息
if serverChan:
    print("***serverChan***")
    resp = request.urlopen(scurl)
    print(resp.read().decode())
if bark:
    print("***bark***")
    resp = request.urlopen(barkurl)
    print(resp.read().decode())
if iyuu:
    print("***iyuu***")
    resp = request.urlopen(iyuuurl)
    print(resp.read().decode())
if pushplus:
    print("***pushplus***")
    resp = request.urlopen(pushplusurl)
    print(resp.read().decode())
if smtp:
    print("***smtp***")
    smtpcon = smtplib.SMTP_SSL(smtpserver, smtpserverport)
    smtpcon.login(smtp_sender, smtp_authcode)
    smtpmsg = MIMEMultipart()
    smtpmsg['Subject'] = smtpmailsubject
    smtpmsg['From'] = smtp_sender
    smtpmsg['To'] = smtp_recipient
    smtpmsg.attach(smtpmailbody)
    smtpcon.sendmail(smtp_sender, smtp_recipient, smtpmsg.as_string())
    smtpcon.quit()
    print("successful!")
if dingtalk:
    print("***dingtalk***")
    #print(dingtalksign)
    #print(dingtalkurl)
    send_data = json.dumps(dingtalkmessage)
    send_data = send_data.encode("utf-8")
    handler = request.Request(url=dingtalkurl, data=send_data, headers=dingtalkurlheader) 
    resp = request.urlopen(handler) 
    print(resp.read().decode())
if qywechatrobot:
    print("***qywechatrobot***")
    send_data = json.dumps(qywechatrobotmessage)
    send_data = send_data.encode("utf-8")
    handler = request.Request(url=qywechatroboturl, data=send_data, headers=qywechatrobotheader)
    resp = request.urlopen(handler) 
    print(resp.read().decode())
if qywechatapp:
    print("***qywechatapp***")
    send_data = json.dumps(qywechatappmessage)
    send_data = send_data.encode("utf-8")
    handler = request.Request(url=qywechatappurl, data=send_data, headers=qywechatappheader)
    resp = request.urlopen(handler) 
    print(resp.read().decode())
if feishu:
    print("***feishu***")
    #print(feishusign)
    #print(feishuurl)
    #print(feishumessage)
    send_data = json.dumps(feishumessage)
    send_data = send_data.encode("utf-8")
    handler = request.Request(url=feishuurl, data=send_data, headers=feishuheader) 
    resp = request.urlopen(handler) 
    print(resp.read().decode())
if telegram:
    print("***telegram***")
    resp = request.urlopen(telegramurl)
    print(resp.read().decode())
    
