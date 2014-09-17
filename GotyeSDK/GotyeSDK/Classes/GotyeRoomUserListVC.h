//
//  GotyeRoomUserListVC.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeAPI.h"
#import "NRGridView.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@class GotyeRoom;

@interface GotyeRoomUserListVC : GotyeViewController <GotyeRoomDelegate, GotyeUserDelegate, GotyeDownloadDelegate, NRGridViewDataSource, NRGridViewDelegate, EGORefreshTableDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet NRGridView *_userGridView;
    IBOutlet UIImageView *_backgroundView;
    IBOutlet UIButton *_backBtn;
    
    IBOutlet UIView *_topView;
    IBOutlet UIImageView *_topBarBG;
    IBOutlet UIImageView *_roomIconView;
    IBOutlet UIImageView *_greenLine0;
    IBOutlet UIImageView *_greenLine1;
    IBOutlet UIImageView *_bgImageView;
}

- (id)initWithRoom:(GotyeRoom *)room;

@end
