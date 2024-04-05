![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/LeanChatLib.svg?style=flat)](http://cocoapods.org/?q=LeanChatLib)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/LeanChatLib.svg?style=flat)](http://cocoapods.org/?q=LeanChatLib)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)

![leanchat](https://cloud.githubusercontent.com/assets/5022872/8431636/4eff0aca-1f6d-11e5-8728-f8f450dac380.gif)

## App Store  
LeanChat is available on the App Store. You can visit https://itunes.apple.com/gb/app/leanchat/id943324553 or search for LeanChat on the App Store.

## Introduction
This example project comprehensively demonstrates the application of LeanCloud's real-time communication feature. However, it contains a lot of UI code and other functionalities, making it not suitable for quick learning. If you are new to LeanMessage, we recommend the [LeanMessage-Demo](https://github.com/leancloud/LeanMessage-Demo) project. Once you are familiar, you can go to [LeanCloud-Demos](https://github.com/leancloud/leancloud-demos) to select your favorite IM skin for integration. During integration, if you encounter difficult problems, you can refer back to the LeanChat project.

## LeanChat Project Structure

* [leanchat-android](https://github.com/leancloud/leanchat-android): Android client
* [leanchat-ios](https://github.com/leancloud/leanchat-ios): iOS client
* [leanchat-webapp](https://github.com/leancloud/leanchat-webapp): Web client
* [leanchat-cloud-code](https://github.com/leancloud/leanchat-cloudcode): Server-side

## Valuable Feedback

If you have any questions, feel free to raise an [issue](https://github.com/leancloud/leanchat-ios/issues), stating what you don't understand, and we'll provide assistance as soon as possible.

## Download
Please directly click on `Download Zip` on Github as shown in the image below to download the latest version only. If you use `git clone`, it might be very slow because it includes a large commit history. In a test, the difference was 1.5M:40M.

![qq20150618-2 2x](https://cloud.githubusercontent.com/assets/5022872/8223520/4c25415a-15ab-11e5-912d-b5dab916ce86.png)

## Running
```bash
  // LeanChat (Complex Example)
  cd LeanChat
  pod install --verbose  // If you have AVOSCloud dependency library locally, you can add the --no-repo-update option to speed up the process
  open LeanChat.workspace
  
  // LeanChatExample (Simple Example)
  cd LeanChatExample
  pod install --verbose --no-repo-update
  open LeanChatExample.xcworkspace

  // LeanChatSwift (Swift Example)
  cd LeanChatSwift
  pod install --verbose --no-repo-update
  open LeanChatSwift.xcworkspace
  
  // LeanChatLib (Library encapsulating LeanCloud communication components and UI)
  cd LeanChatLib
  pod install --verbose --no-repo-update
  open LeanChatLib.xcworkspace
```

If you encounter issues like `definition of 'AVUser' must be imported from module 'LeanChatLib.CDChatListVC' before it is required`, you can hold Option in the Product menu and click on [Clean Build Folder](http://stackoverflow.com/questions/8087065/xcode-4-clean-vs-clean-build-folder) to clear all Build files, then recompile. This issue seems to be a bug when Cocoapods is performing complex compilation. You can see this [Gif](https://cloud.githubusercontent.com/assets/5022872/9230256/cf822fe4-4153-11e5-876d-ed819babad89.gif) for more details.

Please note that because the default uses production certificates, there are no push notifications for offline messages during development. However, push notifications are available in the online version, which can be downloaded from the [App Store](https://itunes.apple.com/gb/app/leanchat/id943324553). For more details, you can also refer to this [issue](https://github.com/leancloud/leanchat-ios/issues/40).

Here you can see three projects, as described below.

## Subproject Introduction
* LeanChatLib: The core logic and UI library for chatting. With it, you can quickly integrate chat functionality, supporting text, audio, image, and emoji messages, as well as message notifications. There is also a corresponding [Android version](https://github.com/leancloud/leanchat-android).
* LeanChatExample: The simplest usage example of LeanChatLib. It shows how to use a minimal amount of code to call LeanChatLib to join a chat, regardless of whether you use LeanCloud's user system or your own user system.
* LeanChat-ios: The entire LeanChat application. It includes features such as friend management, group management, location-based messaging, nearby users, personal pages, login, and registration, all based on LeanCloud's storage and communication capabilities. It is a more complex application of LeanChatLib.

## LeanChatLib Introduction

It encapsulates the recent conversation page and chat page. Both LeanChat and LeanChatExample projects depend on it. You can install it as follows,

```
    pod 'LeanChatLib'
```

Most of the time, you will integrate LeanChatLib by dragging the source code into your project. In this case, you need to install `AVOSCloud.framework` and `AVOSCloudIM.framework` first. If you didn't use `pod install 'AVOSCloud'`, `pod install 'AVOSCloudIM'` to install, you can configure the required Frameworks according to the LeanCloud [Quick Start Guide](https://leancloud.cn/docs/start.html). Also, install two other dependent libraries `JSBadgeView` and `DateTools`. When running `pod install` for this Demo, a Pods directory will be generated, from which you can find these two Pods. Alternatively, you can search online. You can also configure it through the [.podspec file](https://github.com/leancloud/leanchat-ios/blob/master/LeanChatLib.podspec#L9), which describes which source files need to be integrated and which system frameworks need to be introduced, etc. Or, please refer to this [ticket](https://ticket.leancloud.cn/tickets/7666).

## How to Add IM in Three Steps
1. Create an application in LeanCloud.
2. Add the LeanChatLib pod dependency, or drag the LeanChatLib code files into your project for easier UI customization and feature adjustment.
3. Add the following code in

 appropriate places,

Upon application launch, initialize and configure IM User,
```objc
    [AVOSCloud setApplicationId:@"YourAppId" clientKey:@"YourAppKey"];
    [CDChatManager manager].userDelegate = [[CDUserFactory alloc] init];
```

Configure a UserFactory, which conforms to the CDUserDelegate protocol.

```objc
#import "CDUserFactory.h"

#import <LeanChatLib/LeanChatLib.h>

@interface CDUserFactory ()<CDUserDelegate>

@end


@implementation CDUserFactory

#pragma mark - CDUserDelegate
-(void)cacheUserByIds:(NSSet *)userIds block:(AVIMArrayResultBlock)block{
    block(nil,nil); // don't forget it
}

-(id<CDUserModel>)getUserById:(NSString *)userId{
    CDUser* user=[[CDUser alloc] init];
    user.userId=userId;
    user.username=userId;
    user.avatarUrl=@"http://ac-x3o016bx.clouddn.com/86O7RAPx2BtTW5zgZTPGNwH9RZD5vNDtPm1YbIcu";
    return user;
}

@end

```

Here, CDUser is the User object within the application, and you can implement the CDUserModel protocol in your User object.

CDUserModel,
```objc
@protocol CDUserModel <NSObject>

@required

-(NSString*)userId;

-(NSString*)avatarUrl;

-(NSString*)username;

@end
```

Call when logging in,
```objc
        [[CDChatManager manager] openWithClientId:selfId callback: ^(BOOL succeeded, NSError *error) {
            if (error) {
                DLog(@"%@", error);
            }
            else {
               //go Main Controller
            }
        }];
```

To chat with someone,
```objc
        [[CDChatManager manager] fetchConvWithOtherId : otherId callback : ^(AVIMConversation *conversation, NSError *error) {
            if (error) {
                DLog(@"%@", error);
            }
            else {
                LCEChatRoomVC *chatRoomVC = [[LCEChatRoomVC alloc] initWithConv:conversation];
                [weakSelf.navigationController pushViewController:chatRoomVC animated:YES];
            }
        }];
```

To group chat,
```objc
        NSMutableArray *memberIds = [NSMutableArray array];
        [memberIds addObject:groupId1];
        [memberIds addObject:groupId2];
        [memberIds addObject:[CDChatManager manager].selfId];
        [[CDChatManager manager] fetchConvWithMembers:memberIds callback: ^(AVIMConversation *conversation, NSError *error) {
            if (error) {
                DLog(@"%@", error);
            }
            else {
                LCEChatRoomVC *chatRoomVC = [[LCEChatRoomVC alloc] initWithConv:conversation];
                [weakSelf.navigationController pushViewController:chatRoomVC animated:YES];
            }
        }];
```

When logging out,
```objc
    [[CDChatManager manager] closeWithCallback: ^(BOOL succeeded, NSError *error) {
        
    }];
```

Then, you can chat as shown in the screenshot above. Note that we currently do not recommend using the pod method to import LeanChatLib directly because some interfaces and functionalities need to be customized by you. Therefore, we recommend copying the LeanChatLib code into the project for easier customization.

## LeanChatLib ChangeLog	

0.2.6

Upgrade SDK to 3.1.4 to adapt to iOS 9

0.2.5

Use cachePolicy in AVIMConversationQuery to save traffic and better support offline
Fixed a bug where calling fetchConvWithConvid when the conversation does not exist may cause a crash

0.2.4	

Added Tuzki emoji

0.2.3

Added parameter checking for the fetchConvWithMembers: interface, fixed a potential crash in the conversation list when it is a single chat but only has one member

0.2.2

Upgrade AVOSCloud library to 3.1.2.8

0.2.1

ChatListDelegate adds configureCell: and prepareConversaion: interfaces for more complex conversation customization.

For image messages, use AVFile for caching images, so that your own sent photos do not need to be re-downloaded.

0.2.0

Add comments, support message resend, display failed messages, add sound effects, and vibration

0.1.3

Fixed a bug where the app might crash when loading historical messages quickly by pulling down

0.1.2

Using SDK's chat cache, removed FMDB dependency. You can see historical messages on the server and historical chat records even after reinstallation. Removed the CDNotify class.

0.1.1

Refactoring

0.1.0

Initial release


## Deployment Notes for LeanChat

If you want to deploy the complete LeanChat, since the application has a friend adding feature, please go to Settings->Application Options and check the Mutual Follow option so that when one party agrees, they can add each other as friends.

![qq20150407-5](https://cloud.githubusercontent.com/assets/5022872/7016645/53f91bb8-dd1b-11e4-8ce0-72312c655094.png)

## Development Guide

[Realtime Messaging Service Development Guide](https://leancloud.cn/docs/realtime_v2.html)

[More Information](https://github.com/leancloud/leanchat-android)

## Acknowledgments

Thanks to the great [MessageDisplayKit](https://github.com/xhzengAIB/MessageDisplayKit) open-source library by Xian-Hua Han.