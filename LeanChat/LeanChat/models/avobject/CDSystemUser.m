//
//  CDSystemUser.m
//  LeanChat
//
//  Created by lzw on 15/11/13.
//  Copyright © 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import "CDSystemUser.h"

@implementation CDSystemUser

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SystemUser";
}

@dynamic convid;
@dynamic user;

@end
