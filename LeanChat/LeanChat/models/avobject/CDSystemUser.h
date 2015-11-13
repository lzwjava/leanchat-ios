//
//  CDSystemUser.h
//  LeanChat
//
//  Created by lzw on 15/11/13.
//  Copyright © 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import "CDCommon.h"

#define kCDSystemUserKeyUser @"user"
#define kCDSystemUserKeyConvid @"convid"

@interface CDSystemUser : AVObject<AVSubclassing>

@property (nonatomic, strong) AVUser *user;
@property (nonatomic, copy) NSString *convid;

@end
