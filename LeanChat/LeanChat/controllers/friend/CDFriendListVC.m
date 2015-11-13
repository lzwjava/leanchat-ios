//
//  CDContactListController.m
//  LeanChat
//
//  Created by Qihe Bian on 7/27/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "CDFriendListVC.h"
#import "CDCommon.h"
#import "CDAddFriendVC.h"
#import "CDBaseNavC.h"
#import "CDNewFriendVC.h"
#import "CDImageLabelTableCell.h"
#import "CDGroupedConvListVC.h"
#import <JSBadgeView/JSBadgeView.h>
#import "CDUtils.h"
#import "CDUserManager.h"
#import "CDIMService.h"
#import "CDSystemUser.h"

static NSString *kCellImageKey = @"image";
static NSString *kCellBadgeKey = @"badge";
static NSString *kCellTextKey = @"text";
static NSString *kCellSelectorKey = @"selector";

@interface CDFriendListVC () <UIAlertViewDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *headerSectionDatas;
@property (nonatomic, strong) NSArray *systemUsers;

@end

@implementation CDFriendListVC

#pragma mark - Life Cycle
- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"联系人";
        self.tabBarItem.image = [UIImage imageNamed:@"tabbar_contacts_active"];
//        [self setNewAddRequestBadge];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contact_IconAdd"] style:UIBarButtonItemStylePlain target:self action:@selector(goAddFriend:)];
    [self setupTableView];
    [self refresh];
}

- (void)setupTableView {
    [CDImageLabelTableCell registerCellToTalbeView:self.tableView];
    [self.tableView addSubview:self.refreshControl];
}

- (UIRefreshControl *)refreshControl {
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)goNewFriend:(id)sender {
    CDNewFriendVC *controller = [[CDNewFriendVC alloc] init];
    controller.friendListVC = self;
    [[self navigationController] pushViewController:controller animated:YES];
    self.tabBarItem.badgeValue = nil;
}

- (void)goGroup:(id)sender {
    CDGroupedConvListVC *controller = [[CDGroupedConvListVC alloc] init];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)goAddFriend:(id)sender {
    CDAddFriendVC *controller = [[CDAddFriendVC alloc] init];
    [[self navigationController] pushViewController:controller animated:YES];
}

#pragma mark - load data

- (void)refresh {
    [self refresh:nil];
}

- (void)refreshWithFriends:(NSArray *)friends systemUsers:(NSArray *)systemUsers badgeNumber:(NSInteger)number{
    if (number > 0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", number];;
    } else {
        self.tabBarItem.badgeValue = nil;
    }
    
    self.headerSectionDatas = [NSMutableArray array];
    [self.headerSectionDatas addObject:@{ kCellImageKey:[UIImage imageNamed:@"new_friends_icon"], kCellTextKey:@"新的朋友",kCellBadgeKey:@(number), kCellSelectorKey:NSStringFromSelector(@selector(goNewFriend:))}];
    [self.headerSectionDatas addObject:@{ kCellImageKey:[UIImage imageNamed:@"group_icon"], kCellTextKey:@"群组" , kCellSelectorKey:NSStringFromSelector(@selector(goGroup:))}];
    
    self.systemUsers = systemUsers;
    self.dataSource = [friends mutableCopy];
    [self.tableView reloadData];
}

- (void)findFriendsAndBadgeNumberWithBlock:(void (^)(NSArray *friends, NSArray *systemUsers, NSInteger badgeNumber, NSError *error))block {
    [[CDUserManager manager] findFriendsWithBlock : ^(NSArray *objects, NSError *error) {
        // why kAVErrorInternalServer ?
        if (error && error.code != kAVErrorCacheMiss && error.code == kAVErrorInternalServer) {
            // for the first start
            block(nil, nil, 0, error) ;
        } else {
            if (objects == nil) {
                objects = [NSMutableArray array];
            }
            [self countNewAddRequestBadge:^(NSInteger number, NSError *error) {
                [[CDUserManager manager] fetchSystemUsersWithBlock:^(NSArray *systemUsers, NSError *error) {
                    block (objects,systemUsers, number, nil);
                }];
            }];
        };
    }];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self showProgress];
    [self findFriendsAndBadgeNumberWithBlock:^(NSArray *friends, NSArray *systemUsers, NSInteger badgeNumber, NSError *error) {
        [self hideProgress];
        [CDUtils stopRefreshControl:refreshControl];
        if ([self filterError:error]) {
            [self refreshWithFriends:friends systemUsers:systemUsers badgeNumber:badgeNumber];
        }
    }];
}

- (void)countNewAddRequestBadge:(AVIntegerResultBlock)block {
    [[CDUserManager manager] countUnreadAddRequestsWithBlock : ^(NSInteger number, NSError *error) {
        if (error) {
            block(0, nil);
        } else {
            block(number, nil);
        }
    }];
}

#pragma mark - Table view data delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.headerSectionDatas.count;
        case 1:
            return self.systemUsers.count;
        case 2:
            return self.dataSource.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [@[@0, @14, @0][section] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDImageLabelTableCell *cell = [CDImageLabelTableCell createOrDequeueCellByTableView:tableView];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    static NSInteger kBadgeViewTag = 103;
    JSBadgeView *badgeView = (JSBadgeView *)[cell viewWithTag:kBadgeViewTag];
    if (badgeView) {
        [badgeView removeFromSuperview];
    }
    switch (indexPath.section) {
        case 0: {
            NSDictionary *cellDatas = self.headerSectionDatas[indexPath.row];
            [cell.myImageView setImage:cellDatas[kCellImageKey]];
            cell.myLabel.text = cellDatas[kCellTextKey];
            NSInteger badgeNumber = [cellDatas[kCellBadgeKey] intValue];
            if (badgeNumber > 0) {
                badgeView = [[JSBadgeView alloc] initWithParentView:cell.myImageView alignment:JSBadgeViewAlignmentTopRight];
                badgeView.tag = kBadgeViewTag;
                badgeView.badgeText = [NSString stringWithFormat:@"%ld", badgeNumber];
            }
            break;
        }
        case 1: {
            CDSystemUser *systemUser = self.systemUsers[indexPath.row];
            [[CDUserManager manager] displayAvatarOfUser:systemUser.user avatarView:cell.myImageView];
            cell.myLabel.text = systemUser.user.username;
            break;
        }
        case 2: {
            AVUser *user = [self.dataSource objectAtIndex:indexPath.row];
            [[CDUserManager manager] displayAvatarOfUser:user avatarView:cell.myImageView];
            cell.myLabel.text = user.username;
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            SEL selector = NSSelectorFromString(self.headerSectionDatas[indexPath.row][kCellSelectorKey]);
            [self performSelector:selector withObject:nil afterDelay:0];
            break;
        }
        case 1: {
            [self goSystemConversatoinAtIndex:indexPath.row];
            break;
        }
        case 2: {
            AVUser *user = [self.dataSource objectAtIndex:indexPath.row];
            [[CDIMService service] goWithUserId:user.objectId fromVC:self];
            break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 2;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"解除好友关系吗" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = indexPath.row;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        AVUser *user = [self.dataSource objectAtIndex:alertView.tag];
        [self showProgress];
        [[CDUserManager manager] removeFriend : user callback : ^(BOOL succeeded, NSError *error) {
            [self hideProgress];
            if ([self filterError:error]) {
                [self refresh];
            }
        }];
    }
}

#pragma mark - System Conversation

- (void)goSystemConversatoinAtIndex:(NSInteger)index {
    CDSystemUser *systemUser = self.systemUsers[index];
    [[CDChatManager manager] fecthConvWithConvid:systemUser.convid callback:^(AVIMConversation *conversation, NSError *error) {
        [[CDIMService service] goWithConv:conversation fromNav:self.navigationController];
    }];
}

@end
