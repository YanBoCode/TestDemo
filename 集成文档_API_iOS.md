# 文档介绍

## 开发术语

| 名称           | 说明                                                         |
| -------------- | ------------------------------------------------------------ |
| AppKey         | AppKey是 App 在客服系统的身份标识。是 SDK 连接客服系统所必需的标识 |
| Token          | 客服Token令牌，由App后台服务生成token，通过约定算法在应用服务端生成动态token，生成规则 |
| ReceiverId     | 接收者ID：在单聊、群聊、客服不同会话类型时传输不同的对象Id， 单聊：目标用户id,群聊：目标群组id,客服：目标商户id（平台自营业务时使用客服系统分配的虚拟商户id） |
| ConversationId | 会话Id                                                       |

## 业务术语

| 名称     | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| 会话     | 指二人或多人进行消息通讯的聊天场景，支持单聊、群聊、客服等会话类型。 |
| 单聊     | 指两个用户一对一进行聊天，两个用户间可以是好友也可以是陌生人 |
| 群组     | 群组指两个以上用户一起进行聊天                               |
| 客服     | 用户与您的 App 后台客服进行消息通讯，提供“机器人”和“人工”两种客服方式，默认机器人优先接待。 |
| 会话列表 | 指各种会话依照顺序先后排列的界面，其中会话列表中的每一个列表项称之为一条会话。 排列的先后顺序会依赖于最新会话、未读会话和时间等因素。 |
| 商户     | 用户咨询的对象都是以商户为目标对象，业务中有平台自营业务和第三方商户业务两类， 在客服系统中把平台看作一个虚拟商户并分配一个虚拟的商户Id，用户对自营业务发起咨询的时候， 目标商户传的商户id就是此虚拟商户Id，第三方商户就按系统中真是的商户Id设置即可 |
| 踢蹬     | 同一账号支持在两个平台登录，同类别设备账号登录会发生踢蹬， 移动端可有1种平台在线（Android、iPhone、iPad) : PC端可有1种平台在线（Windows、 Mac、WEB ） |

## 集成SDK

 环境要求

 支持环境说明

| 名称  | 版本  |
| ----- | ----- |
| Xcode | 11 +  |
| iOS   | 9.0 + |

### 添加SDK

- 把BaseSDK文件夹导入工程，内部包含：libBaseSDK.a、RM-SDK-LIB.a、函数头文件

## 初始化

在使用IM 的各项功能之前，必须先对SDK 进行初始化。在应用的生命周期内，仅需进行一次初始化。

SDK 的初始化方法必须在**主进程**中调用

#### 自定义参数初始化

>- 请注意SDK核心类为`BaseClient`.
>- 必须在应用生命周期内调用初始化方法,只需要调用一次.

在不同环境时可以可通过[自定义服务配置](#自定义服务配置)连接.可以使用下面重载方法进行初始化.

```objective-c
-(void)initWithAppKey:(NSString *)AppKey loginIp:(NSString *)loginIp loginPort:(int)loginPort fileTcpIp:(NSString *)fileTcpIp fileTcpPort:(int)fileTcpPort fileHttpIp:(NSString *)fileHttpIp fileHttpPort:(int)fileHttpPort;
```

代码示例

```objective-c
BaseError *error = [[BaseClient shareClient] initWithAppKey:@"AppKey" loginIp:@"loginIp" loginPort:loginPort fileTcpIp:@"fileTcpIp" fileTcpPort:fileTcpPort fileHttpIp:@"fileHttpIp" fileHttpPort:fileHttpPort];         if(error == nil) 
{
  //初始化成功
} else 
{
  //初始化失败
}
```

## 全局事件监听

	在SDK 初始化之后登录之前添加IM事件监听器，接收回调事件信息， 例如连接状态、踢蹬事件等。

- 通过设置监听器，您可以监听到 IM 连接状态的变化和用户踢蹬事件，从而进行不同业务处理，或在页面上给出提示。
- 建议在应用生命周期内设置。

设置连接状态监听器，支持设置多个监听器。

为了避免内存泄露，请在不需要监听时，将设置的监听器移除。

### 添加事件监听器

#### 示例代码

```objective-c
//添加代理
[[BaseClient shareClient] addDelegate:self];

/**
 @brief SDK连接服务器的状态变化时会接收到该回调
 @param connectionState 当前状态
 */
- (void)onConnectionStatusDidChange:(BaseConnectState)connectionState
{
  if (connectionState == BaseDisconnected) 
  {
    //未连接
  }else if (connectionState == BaseConnected)
  {
    //已连接
  }else if (connectionState == BaseConnecting || connectionState == BaseReceiving)
  {
    //连接中  或者 收取中
  }
}
// 当前用户被踢出
- (void)onKickedOffline
{
  
}

```

连接状态说明

`BaseConnectState`  中定义了连接过程中的可能的状态变化。以下的状态码需要 APP 进行处理。

| 状态码           | 值   | 说明     |
| ---------------- | ---- | -------- |
| BaseConnected    | 0    | 已连接   |
| BaseConnecting   | 1    | 正在连接 |
| BaseDisconnected | 2    | 未连接   |
| BaseReceiving    | 3    | 收取中   |

### 移除事件监听

```objective-c
[[BaseClient shareClient] removeDelegate:self];
```

## 登录登出

	初始化SDK 后，需要调用 SDK 登录接口验证帐号身份，获得帐号的功能使用权限。登录 SDK 成功后，才能正常使用消息、会话等功能。

### 登录

	首次登录客服服务时，不需要先注册帐号，直接登录即可。客服系统在登录过程中发现是未注册的帐号，会自动注册。

以下场景调用 `login` 接口：

- App 启动后首次使用 IM SDK 的功能。
- 登录时Token过期：`login` 接口的回调会返回 SDK_TOKEN_EXPIRE 错误码，此时请生成新的 Token重新登录。
- 在线时被踢下线：用户在线情况下被踢，SDK 会通过 KickedNotify回调通知给您，此时可以在 UI 提示用户，并调用 login 重新登录。

以下场景无需调用 `login` 接口：

- 用户的网络断开并重新连接后，不需要调用 `login` 函数，SDK 会自动上线。
- 当一个登录过程在进行时，不需要进行重复登录。

#### 接口原型

```objective-c
/// token登录
/// @param token 用户token
/// @param completion 回调,登录成功error为空,返回用户id
/// @param userName 用户昵称，没有传空
/// @param userHeadUrl 用户头像，没有传空
- (void)loginWithToken:(NSString *)token userName:(NSString *)userName userHeadUrl:(NSString *)userHeadUrl completion:(void (^)(NSString *userId, BaseError *error))completion;
```

#### 参数说明

| 参数        | 类型     | 说明              |
| ----------- | -------- | ----------------- |
| token       | NSString | 从服务端生成token |
| completion  | Block    | 登录回调          |
| userName    | NSString | 用户昵称          |
| userHeadUrl | NSString | 用户头像          |

#### 示例代码

```objective-c
[[BaseClient shareClient] loginWithToken:@"token" userName:@"userName" userHeadUrl:@"userHeadUrl" completion:^(NSString *userId, BaseError *error) {
  if (error == nil) {
    //连接成功 
  }else {
    //无法连接到 IM 服务器，请根据相应的错误码作出对应处理 error.errorCode
  }
}];
```

#### 多端登录与互踢策略

	在线策略默认仅允许同一用户账号在**单台移动端**设备上登录。后登录的移动端设备一旦连接成功，则自动踢出之前登录的设备。
	
	帐号被踢后SDK不再接收和处理消息,当前设备会接收帐号被踢通知.

### 登出

普通情况下，如果您的应用生命周期跟SDK 生命周期一致，退出应用前可以不登出，直接退出即可。

如下场景需要登出操作

- 切换帐号，在等新账号之前需要先进行logout操作，在执行 `login`登录。
- 退出到特定界面后不在使用IM功能，登出成功后，不会再收到其他人发送的新消息。

#### 示例代码

```objective-c
[[BaseClient shareClient] logoutCompletion:^(BaseError *error) 
 {
     if (error == nil) 
     {
       //退出成功
     }else
     {
       //退出失败
     }
  }];
```

# 启动聊天

## 启动客服聊天

打开客服聊天窗口，调用 `startCustomerConversationWithConversationOption`接口，默认会话类型为`ChatTypeSingleYW`

### 函数说明

```objective-c
/// 客服打开页面
/// - Parameters:
///   - conversationOption: ConversationOption对象
///   - completions: 回调
-(void)startCustomerConversationWithConversationOption:(ConversationOption *)conversationOption completion:(void(^)(HZ_MessageViewController *viewcontroller,BaseError *error))completions;
```

### 客服聊天示例代码

```objective-c
[[BaseUIClient getInstance] startCustomerConversationWithConversationOption:option completion:^(HZ_MessageViewController * _Nonnull viewcontroller, BaseError * _Nonnull error) {
       if(error != nil)
       {
           return;
        }
        //从会话列表打开列表，需要相关的点击事件，需要设置此代理，否则不需要设置代理
        viewcontroller.delegate = self;
        [self.navigationController pushViewController:viewcontroller animated:YES];
}];
```

参数说明:

| 参数               | 类型               | 说明                   |
| ------------------ | ------------------ | ---------------------- |
| conversationOption | ConversationOption | ConversationOption对象 |
| completion         | Block              | 回调                   |
|                    |                    |                        |

## 单聊启动聊天页面

### 函数说明

```objective-c
/// 单聊打开页面
/// - Parameters:
///   - openId: 对方用户openId
///   - chatName: 会话名字
///   - completions: 回调
-(void)startSingleConversationOpenId:(NSString *)openId chatName:(NSString *)chatName completion:(void(^)(HZ_MessageViewController *viewcontroller,BaseError *error))completions;
```

### 开启单聊会话示例代码

```objective-c
[[BaseUIClient getInstance] startSingleConversationOpenId:usermodel.telePhone chatName:usermodel.nickName completion:^(HZ_MessageViewController * _Nonnull viewcontroller, BaseError * _Nonnull error) {
  if(error != nil)
  {
     return;
   }
  //从会话列表打开列表，需要相关的点击事件，需要设置此代理，否则不需要设置代理
  viewcontroller.delegate = self;
  [self.navigationController pushViewController:viewcontroller animated:YES];
}];
```

## 启动服务、订单、活动、互动页面

启动服务、订单、活动、互动页面，需要先构造`BaseChat`对象，`BaseChat`对象需要传入一个参数，会话id。,然后调用调用`BaseUIClient#startPushConversationChatId`启动页面

### 函数说明

```objective-c
/// 启动服务、订单、活动、互动页面
/// - Parameters:
///   - chat: BaseChat对象
///   - completions: 回调
-(void)startPushConversationChatId:(BaseChat *)chat  completion:(void(^)(HZCardMsgVC *viewcontroller,BaseError *error))completions;
```

### 示例代码

```objective-c
//构造BaseChat对象
BaseChat *chat = [[BaseChat alloc] init];
chat.chatId = @"会话id";
chat.chatName = @"会话名字";
chat.notiMessageKey = @"通知消息";

//启动服务、订单、活动、互动页面
[[BaseUIClient getInstance] startPushConversationChatId:chat completion:^(HZCardMsgVC * _Nonnull viewcontroller, BaseError * _Nonnull error) {
  if(error != nil)
  {
    return;
  }
  //已读回调
  viewcontroller.unReadBlock = ^(int unreadCount) {
    dispatch_async(dispatch_get_main_queue(), ^{

      chat.unreadCount = unreadCount;
      chat.isRemindMe = NO;
      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
  };
  [self.navigationController pushViewController:viewcontroller animated:YES];
}]
```



## 群聊启动聊天页面

### 函数说明

```objective-c
/// 群聊聊打开页面
/// - Parameters:
///   - groupId: 群组id
///   - chatName: 会话名字
///   - completions: 回调
-(void)startGroupConversationGroupId:(NSString *)groupId chatName:(NSString *)chatName completion:(void(^)(HZ_MessageViewController *viewcontroller,BaseError *error))completions;
```

### 开启群聊会话示例代码

```objective-c
[[BaseUIClient getInstance] startGroupConversationGroupId:chat.chatId chatName:chat.chatName completion:^(HZ_MessageViewController * _Nonnull viewcontroller, BaseError * _Nonnull error) {
  viewcontroller.delegate = self;
  [self.navigationController pushViewController:viewcontroller animated:YES];
}];
```



## 聊天室启动聊天页面

### 函数说明

```objective-c
/// 聊天室打开页面
/// - Parameters:
///   - chatRoomId: 聊天室id
///   - chatName: 会话名字
///   - completions: 回调
-(void)startChatRoomConversationChatRoomId:(NSString *)chatRoomId chatName:(NSString *)chatName completion:(void(^)(CsbChatRoomViewController *viewcontroller,BaseError *error))completions;
```



## H5启动客服聊天

示例代码

```objective-c
WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
WKWebView *wkwebview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
// 提供方法给js调用
[webConfig.userContentController addScriptMessageHandler:self name:@"launchConversation"];

//代理回调
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
 NSLog(@"js调用的方法:%@",message.name);
 //message.bodhy 是个json数据
 NSLog(@"js传过来的数据:%@",message.body);
 NSData * data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
 NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data   options:NSJSONReadingMutableLeaves error:nil];
 NSString *chatId = [NSString stringWithFormat:@"%@",jsonDict[@"chatId"]];
 NSString *serverType = [NSString stringWithFormat:@"%@",jsonDict[@"serverType"]];
 NSString *chatTitle = [NSString stringWithFormat:@"%@",jsonDict[@"serverName"]];
 NSString *url = [NSString stringWithFormat:@"%@",jsonDict[@"url"]];
  //此时调用 APP聊天页面 看 客服聊天示例代码
}
```

#### Javascript调用

```javascript
 document.getElementById('button').onclick = function() {
        //  如果KF对象存在 则调用客服接口里的launchConversation方法
        if (window.webkit) {
            window.webkit.messageHandlers.launchConversation.postMessage(msg);
        }
    }
```

## 发送位置消息

当用户点击消息界面扩展区的发送位置时, 会触发 `onLocationMsgSendClickWithLocationBlock` 回调, App 可在回调方法内调起地图页面,选择完地址后, 使用 `locationBlock` 函数将结果返回给消息页面.

### 函数说明

```objective-c
#import "HZ_BaseViewController.h"

@protocol MessageVCDelegate <NSObject>

@optional

/**
 * 点击发送位置回调
*/
- (void)onLocationMsgSendClickWithLocationBlock:(void (^)(NSString *location))locationBlock;

@end

@interface HZ_MessageViewController : HZ_BaseViewController<MessageVCDelegate>

@property(nonatomic, weak)id<MessageVCDelegate>delegate;

@end
```



### 在回调方法内打开地图页面

```objective-c
-(void)onLocationMsgSendClickWithLocationBlock:(void (^)(NSString * _Nonnull))locationBlock
{
    XXX *vc = [[XXX alloc] init];
    vc.locationBlock = ^(HZChoosePositionResult * _Nonnull postionModel) {
        if(locationBlock)
        {
            HZChoosePositionResult *resultModel = [[HZChoosePositionResult alloc] init];
            resultModel.latitude = postionModel.latitude;
            resultModel.longitude = postionModel.longitude;
            resultModel.address = postionModel.address;
            locationBlock(resultModel);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
```



# 次声波卡片


次声波卡片可用作消息发送或者按需展示，用户传入卡片数据，UI-KIT会按对应的模版渲染出卡片视图。

默认内置订单卡片和商品卡片（以下）。

构造卡片请看`卡片API`

## 发送卡片消息

### 函数说明

```objective-c
/// 发送卡片消息
/// @param cardBean CsbCardBean
/// @param chatId 会话id
/// @param chatType 会话类型
/// @param completion 消息发送回调

-(void)sendCardMessage:(CsbCardBean *)cardBean chatId:(NSString *)chatId chatType:(int)chatType completion:(void(^)(NSString *msgId, BaseError *error))completion;
```



# 开启客服聊天

开启客服聊天可带入卡片数据，UIKIT会按相对应的布局渲染 ==> ConversationOption.CsbCardBean

## 函数说明

```objective-c
/// 客服打开页面
/// - Parameters:
///   - conversationOption: ConversationOption对象
///   - completions: 回调
-(void)startCustomerConversationWithConversationOption:(ConversationOption *)conversationOption completion:(void(^)(HZ_MessageViewController *viewcontroller,BaseError *error))completions;
```

## 参数说明

| 字段               | 类型               | 说明                 | 备注 |
| ------------------ | ------------------ | -------------------- | ---- |
| conversationOption | ConversationOption | 客服聊天需要的数据项 |      |

ConversationOption字段

| 字段           | 类型        | 说明       | 备注                                             |
| -------------- | ----------- | ---------- | ------------------------------------------------ |
| merchantId     | NSString    | 商户id     |                                                  |
| merchantName   | NSString    | 商户名称   |                                                  |
| merchantLogo   | NSString    | 商户logo   |                                                  |
| businessLineId | NSString    | 业务线ID   |                                                  |
| questionType   | int         | 类型       | 0:无主题,1:商品,2:订单                           |
| objectId       | NSString    | 关联对象Id |                                                  |
| cardBean       | CsbCardBean | 卡片数据   | 传入卡片数据，客服聊天界面会渲染相对应的卡片View |
|                |             |            |                                                  |

ConversationOption部分字段说明

> 业务线数据 (UI层不处理，用于与后台交互)
>
> - businessLineId
> - questionType
> 
>消息卡片数据（UI层负责显示卡片）
> 
>- cardBean 卡片



## 调用示例

```objective-c
ConversationOption *conversationOption = [[ConversationOption alloc] init];

//设置商户信息
conversationOption.merchantId = @"1000";
conversationOption.merchantName = @"客服xxx";
conversationOption.merchantLogo = @"http://www.xxx.com/img/logo";

//... 设置业务线数据
conversationOption.businessLineId = @"300";
conversationOption.questionType = 1;
conversationOption.objectId = @"123456";

//创建商品卡片
CsbCardBean *cardBean = [[CsbCardBean alloc] init];
//关联对象Id
cardBean.objectId = @"123456";
//设置模板编号
cardBean.templateId = PRODUCT_CARD_3;
//设置类型
cardBean.cardType = TYPE_PRODUCT;
//可以按需添加字定义的值,回调事件里面使用
NSMutableDictionary *paramDicM = [NSMutableDictionary dictionary];
[paramDicM setObject:@"https://img1.baidu.com/it/u=3292747868,1792835349&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500" forKey:@"logo"];
[paramDicM setObject:@"Debo德铂卡贝尔 (多用..." forKey:@"title"];
[paramDicM setObject:@"DEP-50" forKey:@"desc"];
[paramDicM setObject:@"¥89" forKey:@"price"];
cardBean.cardData = [paramDicM mutableCopy];
conversationOption.cardBean = cardBean;
//打开客服聊天
[[BaseUIClient getInstance] startCustomerConversationWithConversationOption:conversationOption completion:^(HZ_MessageViewController * _Nonnull viewcontroller, BaseError * _Nonnull error) {
       if(error != nil)
       {
           return;
        }
        //从会话列表打开列表，需要相关的点击事件，需要设置此代理，否则不需要设置代理
        viewcontroller.delegate = self;
        [self.navigationController pushViewController:viewcontroller animated:YES];
}];
```

# 卡片的点击事件

## 点击事件接口

客服卡片点击处理

```objective-c
#import "HZ_BaseViewController.h"

@protocol MessageVCDelegate <NSObject>

@optional
/**
 * 卡片点击事件
 * @param cardBean CsbCardBean
 */
-(void)onCardClick:(CsbCardBean *)cardBean;

/**
 * 卡片长按事件
 * @param cardBean CsbCardBean
*/
-(void)onCardLongClick:(CsbCardBean *)cardBean;
@end
```

# 旧版转人工跳转（部分场景使用）

## 设置旧版转人工跳转URL

### 还在使用南基客服的业务线,转人工是跳转到南基H5

```objective-c
[BaseUIClient getInstance].oldVersionCustomerServiceUrl = @"https://www.baidu.com";
```

## 参数说明

| 参数                         | 类型     | 说明              | 备注 |
| ---------------------------- | -------- | ----------------- | ---- |
| oldVersionCustomerServiceUrl | NSString | 旧版转人工跳转URL |      |

# 获取会话列表

客户端 SDK 会根据收发的消息在本地数据库中生成对应会话。您可以从数据库获取 SDK 生成的会话列表。

### 获取会话列表

通过以下接口获取 SDK 在数据库生成的会话列表。获取到的会话列表按照时间倒序排列，置顶会话会排在最前。

## 函数说明

```objective-c
/**
 @brief 获取会话列表
 */
- (void)getConversationsCompletion:(void(^)(NSArray *chatArray))completions;
```

## 调用示例

```objective-c
[[BaseUIClient getInstance] getConversationsCompletion:^(NSArray * _Nonnull chatArray) {
        
}]; 
```

## 参数说明

| 参数  | 类型    | 说明                                 |
| ----- | ------- | ------------------------------------ |
| array | NSArray | 会话类型的数组(实体类BaseChat的集合) |

# 插入本地消息

## 函数说明

```objective-c
//保存消息
-(BaseError *)insertMessage:(BaseMessage *)message;
```

## 调用示例

在发送消息前，需要构造 [BaseMessage]() 对象。`BaseMessage` 实例对象中包含要发送的普通消息内容，例如文本消息（[BaseTextMsgBody]()）。

```objective-c
//1.构造文本消息
BaseTextMsgBody *body = [[BaseTextMsgBody alloc] initWithText:@"测试消息"];
BaseMessage *message = [[BaseMessage alloc] initWithMessage:@"chatId" body:body];
//会话类型 默认ChatTypeSingleYW
message.chatType = ChatTypeSingleYW;
//消息方向，如发送方还是接收方
message.direction = MsgSend;
//保存消息
[[BaseClient shareClient].msgManager insertMessage:message];
```

## 参数说明

| 参数      | 类型        | 说明                    |
| --------- | ----------- | ----------------------- |
| message   | BaseMessage | 消息对象                |
| BaseError | BaseError   | error为nil 保存消息成功 |
|           |             |                         |

# 插入本地会话

## 函数说明

```objective-c

//保存会话
-(BaseError *)insertConversation:(BaseChat *)chat;
```

## 调用示例

```objective-c
[[BaseClient shareClient].chatManager insertConversation:chat];
```



| 参数      | 类型      | 说明                    |
| --------- | --------- | ----------------------- |
| chat      | BaseChat  | 会话对象                |
| BaseError | BaseError | error为nil 保存会话成功 |
|           |           |                         |

# 打开客服中心

## 我的客服native://mine#kefu打开客服中心

```objective-c
HZ_CustomerServiceVC *customerVC = [[HZ_CustomerServiceVC alloc] initWithOpenCustomerServiceCenter];
//设置订单列表点击事件代理
customerVC.delegate = self;
[self.navigationController pushViewController:customerVC animated:YES];
```



## 客服中心点击事件

点击事件回调

```objective-c
@protocol CustomerServiceDelegate <NSObject>

@optional

/**
 次事件回调是为了跳转到app的订单中心
 */
- (void)onOrderListClick;

/**
 点击留言反馈
 */
- (void)onFeedbackClick;
@end
```

# 校验消息是否可发送(发送前)

假设APP侧有类UIClass 函数判断消息是否可以发送

```objective-c
//CsbMsgSendResult 为UIClass类的返回结果
/// 是否可以发送消息
/// - Parameters:
///   - msgSendInfo: CsbMsgSendInfo 对象
- (CsbMsgSendResult *)checkCsbMsgSendPermit:(CsbMsgSendInfo *)msgSendInfo;
```

## 使用校验插件

### 1.创建插件类

```objective-c
//创建单聊校验插件
@implementation PrivateMsgSendPermitPlugin
- (CsbMsgSendResult *)checkCsbMsgSendPermit:(CsbMsgSendInfo *)msgSendInfo
{
    UIClass *uiC = [[UIClass alloc] init];
    CsbMsgSendResult *result = [uiC checkCsbMsgSendPermit:msgSendInfo];
    if(result.code == 0) {
        //如果可以直接发送
        return NULL;
    }
    //返回错误码和提示信息
    return result;
    
}
```

```objective-c
//创建群聊插件
@implementation GroupMsgSendPermitPlugin
- (CsbMsgSendResult *)checkCsbMsgSendPermit:(CsbMsgSendInfo *)msgSendInfo
{
    UIClass *uiC = [[UIClass alloc] init];
    CsbMsgSendResult *result = [uiC checkCsbMsgSendPermit:msgSendInfo];
    if(result.code == 0) {
        //如果可以直接发送
        return NULL;
    }
    //返回错误码和提示信息
    return result;
}

@end
```

### 2.注册校验插件

```objective-c
//单聊注册
PrivateMsgSendPermitPlugin *privatePlugin = [[PrivateMsgSendPermitPlugin alloc] init];
[[MsgSendPermitUtils shareClient].mapDic setObject:privatePlugin forKey:@"Private"];
//群聊注册
GroupMsgSendPermitPlugin *groupPlugin = [[GroupMsgSendPermitPlugin alloc] init];
[[MsgSendPermitUtils shareClient].mapDic setObject:groupPlugin forKey:@"Group"];
```

3.发送消息时,SDK会根据注册的类型,找到对应的处理插件并调用checkCsbMsgSendPermit函数,根据返回值来处理发送状态和提示信息.

如果未注册对应的类型,则默认返回可发送状态.

## 说明

### 1.抽象类说明

```objective-c
@interface CsbMsgSendPermitPlugin : NSObject

/// 是否可以发送消息
/// - Parameters:
///   - msgSendInfo: CsbMsgSendInfo 对象
- (CsbMsgSendResult *)checkCsbMsgSendPermit:(CsbMsgSendInfo *)msgSendInfo;

@end
```

### 2.消息过滤器入参说明

```objective-c
@interface CsbMsgSendInfo : NSObject

/**
 *  发送方openId
 */
@property(nonatomic, strong)NSString *senderId;

/**
 *  接收方id (单聊则为对方openId, 群聊则为群ID)
 */
@property(nonatomic, strong)NSString *targetId;

/**
 *  聊天类型，1：单聊；2：群聊
 */
@property(nonatomic, assign)int chatType;

```



### 3.返回值说明

```objective-c
@interface CsbMsgSendResult : NSObject

/**
 *  code：0表示成功；能正常发送；非0表示是吧，不能发送，出现红点
 */
@property(nonatomic, assign)int code;

/**
 *  showType：显示方式1：在消息下发；2：弹框；3：提示3秒自动消失
 */
@property(nonatomic, assign)int showType;

/**
 *  展示或者弹出内容
 */
@property(nonatomic, strong)NSString *msg;

@end
```



如果能正常发送,则checkCsbMsgSendPermit函数返回null

如果有错误信息,则checkCsbMsgSendPermit函数返回CsbMsgSendResult对象

code：0表示成功；能正常发送；非0表示是吧，不能发送，出现红点

msg：展示或者弹出内容

showType：显示方式1：在消息下发；2：弹框；3：提示3秒自动消失
