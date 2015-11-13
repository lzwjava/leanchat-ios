//
//  AVIMConversation+CustomAttributes.m
//  LeanChatLib
//
//  Created by lzw on 15/4/8.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import "AVIMConversation+Custom.h"
#import "CDChatManager.h"
#import "UIImage+Icon.h"
#import <objc/runtime.h>

@implementation AVIMConversation (Custom)

- (AVIMTypedMessage *)lastMessage {
    return objc_getAssociatedObject(self, @selector(lastMessage));
}

- (void)setLastMessage:(AVIMTypedMessage *)lastMessage {
    objc_setAssociatedObject(self, @selector(lastMessage), lastMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)unreadCount {
    return [objc_getAssociatedObject(self, @selector(unreadCount)) intValue];
}

- (void)setUnreadCount:(NSInteger)unreadCount {
    objc_setAssociatedObject(self, @selector(unreadCount), @(unreadCount), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)mentioned {
    return [objc_getAssociatedObject(self, @selector(mentioned)) boolValue];
}

- (void)setMentioned:(BOOL)mentioned {
    objc_setAssociatedObject(self, @selector(mentioned), @(mentioned), OBJC_ASSOCIATION_ASSIGN);
}

// Please check hasValidType before call it.
- (CDConvType)type {
    return [[self.attributes objectForKey:CONV_TYPE] intValue];
}

- (BOOL)hasValidType {
    if (self.attributes[CONV_TYPE]) {
        CDConvType type = self.type;
        return type == CDConvTypeSingle || type == CDConvTypeGroup || type == CDConvTypeSystem;
    } else {
        DLog(@"converstion %@'s attributes has no type value", self.conversationId);
    }
    return NO;
}

+ (NSString *)nameOfUserIds:(NSArray *)userIds {
    NSMutableArray *names = [NSMutableArray array];
    for (int i = 0; i < userIds.count; i++) {
        id <CDUserModel> user = [[CDChatManager manager].userDelegate getUserById:[userIds objectAtIndex:i]];
        [names addObject:user.username];
    }
    return [names componentsJoinedByString:@","];
}

/// 用在列表 Cell 显示
- (NSString *)displayName {
    if ([self hasValidType]) {
        switch (self.type) {
            case CDConvTypeSingle:
                if (self.members.count == 2) {
                    NSString *otherId = [self otherId];
                    id <CDUserModel> other = [[CDChatManager manager].userDelegate getUserById:otherId];
                    return other.username;
                } else {
                    return @"对话";
                }
            case CDConvTypeGroup:
                return self.name;
            case CDConvTypeSystem: {
                if (self.members.count !=1) {
                    [NSException raise:NSInternalInconsistencyException format:@"请把系统对话关联的用户设为群成员"];
                }
                id <CDUserModel> other = [[CDChatManager manager].userDelegate getUserById:self.members[0]];
                return other.username;
            }
        }
    } else {
        return @"对话";
    }
}

/// Pleae check self.members before calling it.
- (NSString *)otherId {
    NSArray *members = self.members;
    if (members.count == 0) {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid conv"];
    }
    if (members.count == 1) {
        return members[0];
    }
    NSString *otherId;
    if ([members[0] isEqualToString:[CDChatManager manager].selfId]) {
        otherId = members[1];
    }
    else {
        otherId = members[0];
    }
    return otherId;
}

- (NSString *)systemUserId {
    return self.members[0];
}

- (NSString *)title {
    if ([self hasValidType]) {
        switch (self.type) {
            case CDConvTypeSingle:
                return self.displayName;
            case CDConvTypeGroup:
                return [NSString stringWithFormat:@"%@(%ld)", self.displayName, (long)self.members.count];
            case CDConvTypeSystem:
                return self.displayName;
        }
    } else {
        return @"对话";
    }
}

- (UIImage *)icon {
    return [UIImage imageWithHashString:self.conversationId displayString:[[self.name substringWithRange:NSMakeRange(0, 1)] capitalizedString]];
}

@end
