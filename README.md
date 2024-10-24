### QIM即时通讯(IM)客户端-简单版的类QQ微信

#### 1、基本介绍

##### 1. 用户认证管理

- 注册、登录、忘记密码等用户基本服务（包括谷歌登录）。

##### 2. 个人信息管理

- 用户名绑定与个人信息修改。

##### 3. 群聊管理

- 创建群聊、修改群信息、添加或删除群成员、配置群管理员。

##### 4. 主要入口

- 聊天界面
- 通讯录（好友、分组、群聊）
- “我”（个人信息）

##### 5. 聊天功能

###### a. 聊天类型

- 一对一单聊与群聊，支持发送以下内容：
  - 文字
  - 图片
  - 表情
  - 音频
  - 视频
  - 视频通话
  - 个人名片
  - 群名片
  - 邀请加群

###### b. 聊天操作

- 支持聊天内容的：
  - 转发
  - 复制
  - 删除
  - 引用

###### c. 聊天记录

- 支持删除聊天记录。

###### d. 消息提示

- 消息支持语音提示功能。

##### 6. 搜索服务

- 支持用户与群聊的搜索功能，包含新朋友与群通知等配套功能。

##### 7. 分享服务

- 支持分享消息内容、个人名片、群名片。

##### 8. 扫码功能

- 支持通过二维码扫描添加好友或加入群聊。

##### 9. 消息推送服务

- 支持通过谷歌消息推送

#### 2、电脑环境

```
blockdeMacBook-Pro:qim zp$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.3, on macOS 14.5 23F79 darwin-arm64, locale zh-Hans-CN)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 16.0)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.2)
[✓] VS Code (version 1.94.2)
[✓] Connected device (5 available)
[✓] Network resources
```

#### 3、配置文件：lib/config.dart ，如有测试要求，联系作者

```yml
class Configs {
  static const String apiPrefix = 'https://xxx';                                          // api 接口地址
  static const String socketUrl = 'wss://xxx';                                            // websocket 地址
  static const Map iceServers = {'urls': 'xxx', 'credential': 'xxx', 'username': 'xxx'};  // Coturn服务器配置
}
```

#### 4、后端服务仓库地址

```
https://github.com/huazhiyeluo/im-api
```

#### 5、支持联系方式：

```
370838500@qq.com
```

#### 6、展示地址：

##### a H5地址

[https://im.siyuwen.com](https://im.siyuwen.com)

##### b、app下载地址

[https://github.com/huazhiyeluo/flutter-im-client/releases/](https://github.com/huazhiyeluo/flutter-im-client/releases/)

#### 7、APP界面截图：

[https://github.com/huazhiyeluo/flutter-im-client/wiki](https://github.com/huazhiyeluo/flutter-im-client/wiki/)

#### 捐赠账号：

<img src="https://github.com/user-attachments/assets/9cf0485d-4c96-499f-915a-d3c437bb40b7" alt="1-支付宝" width="180" style="padding:5px;" />
<img src="https://github.com/user-attachments/assets/e7986b02-c09f-411b-ade0-f1940d92ad0e" alt="2-微信" width="180" style="padding:5px;" />
