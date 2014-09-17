//
//  GotyeRoomListVC.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeViewController.h"
#import "GotyeRecommendRoomCell.h"
#import "GotyeOrdinaryRoomCell.h"
#import "GotyeAPI.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface GotyeRoomListVC : GotyeViewController <UITableViewDataSource, UITableViewDelegate, GotyeLoginDelegate, GotyeRoomDelegate, GotyeDownloadDelegate, EGORefreshTableDelegate>
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITableView *_roomListView;
    IBOutlet GotyeRecommendRoomCell *_reuseRecommendRoomCell;
    IBOutlet GotyeOrdinaryRoomCell *_reuseOrdinaryRoomCell;
    IBOutlet UIButton *_backBtn;
    IBOutlet UIView *_topBar;
    IBOutlet UIImageView *_topBarBG;
    
    IBOutlet UIImageView *_roomIconView;
    IBOutlet UIImageView *_greenLineTop;
    IBOutlet UIImageView *_greenLineBottom;
    
    UINib *_recommendRoomCellNib;
    UINib *_ordinaryRoomCellNib;
    
    NSMutableArray *_roomArray;
    NSUInteger _curPage;
    BOOL _isLoading;
    
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
}

- (void)refreshData;

@end
