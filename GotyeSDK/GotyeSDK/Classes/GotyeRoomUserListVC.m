//
//  GotyeRoomUserListVC.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeRoomUserListVC.h"
#import "GotyeSDKUIControl.h"
#import "GotyeUser.h"
#import "GotyeSDKData.h"
#import "GotyeImageManager.h"
#import "GotyeSDKResource.h"
#import "GotyeUserInfoVC.h"
#import "GotyeUserGridCell.h"
#import "GotyeStatusMessage.h"
#import "UIImage+Mask.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"

#define kXInset         (IS_IPAD ? 75 : 20)
#define kYInset         (IS_IPAD ? 35 : 5)
#define kGridCellWidth  (IS_IPAD ? 131 : 72)
#define kGridCellHeight (IS_IPAD ? 160 : 92)
#define kUserAvatarSize (IS_IPAD ? 76 : 60)
#define kNameHeight     (IS_IPAD ? 44 : 22)

@interface GotyeUserGrid : UIView

@property(nonatomic, strong) UIButton *avatarBtn;
@property(nonatomic, strong) UILabel *nameLabel;

@end

@implementation GotyeUserGrid

@end

@interface GotyeRoomUserListVC ()
{
    NSUInteger _numberOfColumns;
    GotyeRoom *_room;
    NSMutableArray *_userArray;
    
    NSUInteger _curPage;
    BOOL _isLoading;
    
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    
    CGRect backBtnFramePortrait;
    CGRect titleFramePortrait;
    CGRect topbarFramePortrait;
    UIEdgeInsets backBtnInsetsPortrait;
    
    UIImage *topbarBGPortrait;
    UIImage *topbarBGLandscape;
    UIImage *backBtnBG;
}

@end

@implementation GotyeRoomUserListVC

- (id)initWithRoom:(GotyeRoom *)room
{
    if (self = [super init]) {
        _room = room;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    backBtnFramePortrait = _backBtn.frame;
    titleFramePortrait = _titleLabel.frame;
    topbarFramePortrait = _topView.frame;
    backBtnInsetsPortrait = _backBtn.imageEdgeInsets;
    
    topbarBGPortrait = _topBarBG.image;
    topbarBGLandscape = [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"titlebar_bg_landscape" ofType:@"png"]];
    backBtnBG = [_backBtn backgroundImageForState:UIControlStateNormal];
    
    [_backBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBack]] forState:UIControlStateNormal];
    _titleLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorMainTitle]];
    
    _numberOfColumns = (self.view.frame.size.width - kXInset * 2) / kGridCellWidth;
    
    [[GotyeSDKUIControl sharedInstance]showHudInView:_userGridView animated:NO text:@"加载中..."];
    
    _userGridView.delaysContentTouches = NO;
    _userGridView.delegate = self;
    _userGridView.dataSource = self;
    [_userGridView setCellSize:CGSizeMake(kGridCellWidth, kGridCellHeight)];
    _userGridView.backgroundColor = [UIColor clearColor];
    [_userGridView sendSubviewToBack:_backgroundView];
    
    [self createHeaderView];
    
    _titleLabel.text = _room.name;
    
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeUser];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeRoom];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
    
    [self refreshData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [GotyeAPI removeListener:self];
    
    [[GotyeSDKUIControl sharedInstance]hideHudInView:_userGridView animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeToLandscapeMode
{
    _topView.frame = CGRectMake(0, 0, kSidebarWidth, UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? self.view.bounds.size.height : self.view.bounds.size.width);
    _topBarBG.image = topbarBGLandscape;
    
    CGFloat mainViewX = _topView.frame.size.width + 10;
    _userGridView.frame = CGRectMake(mainViewX, 0, self.view.bounds.size.width - mainViewX - 10, self.view.bounds.size.height);
    
    _roomIconView.hidden = NO;
    _roomIconView.frame = CGRectMake((_topView.frame.size.width - _roomIconView.frame.size.width) / 2, 25, _roomIconView.frame.size.width, _roomIconView.frame.size.height);
    
    _titleLabel.frame = CGRectMake((_topView.frame.size.width - 85) / 2, _roomIconView.frame.origin.y + _roomIconView.frame.size.height + 10, 85, 40);
    _titleLabel.numberOfLines = 2;
    
    _backBtn.frame = CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 18, _topView.frame.size.width, 40);
    [_backBtn setBackgroundImage:nil forState:UIControlStateNormal];
    _backBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 33, 13, 75);
    
    _greenLine0.hidden = NO;
    _greenLine0.frame = CGRectMake(0, _backBtn.frame.origin.y, _greenLine0.frame.size.width, _greenLine0.frame.size.height);
    
    _greenLine1.hidden = NO;
    _greenLine1.frame = CGRectMake(0, _backBtn.frame.origin.y + _backBtn.frame.size.height, _greenLine1.frame.size.width, _greenLine1.frame.size.height);
    
    _bgImageView.frame = CGRectMake(_topView.frame.size.width - 4, 0, self.view.frame.size.width - _topView.frame.size.width + 4, self.view.bounds.size.height);
    
}

- (void)changeToPortraitMode
{
    _topView.frame = topbarFramePortrait;
    _topBarBG.image = topbarBGPortrait;
    
    CGFloat mainViewY = _topView.frame.size.height;
    _userGridView.frame = CGRectMake(10, mainViewY, self.view.bounds.size.width - 20, self.view.bounds.size.height - mainViewY);
    
    _backBtn.frame = backBtnFramePortrait;
    [_backBtn setBackgroundImage:backBtnBG forState:UIControlStateNormal];
    _backBtn.imageEdgeInsets = backBtnInsetsPortrait;
    _titleLabel.frame = titleFramePortrait;
    _titleLabel.numberOfLines = 1;

    _greenLine0.hidden = YES;
    _greenLine1.hidden = YES;
    _roomIconView.hidden = YES;
    
    _bgImageView.frame = CGRectMake(0, _userGridView.frame.origin.y - 4, self.view.frame.size.width, _userGridView.bounds.size.height + 4);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self setFooterView];
}

#pragma mark - private methods -

- (void)addUser:(NSArray *)array
{
    if (_userArray == nil) {
        _userArray = [[NSMutableArray alloc]init];
    }
    
    for (NSString *userID in array) {
        if ([_userArray containsObject:userID]) {
            continue;
        }
        
        [_userArray addObject:userID];
    }
}

- (void)refreshData
{
    _curPage = 0;
    [GotyeAPI reqUserListInRoom:_room atPage:_curPage];
}

- (void)getNextPage
{
    [GotyeAPI reqUserListInRoom:_room atPage:_curPage];
}

- (void)refreshView
{
    [_userGridView reloadData];
    CGRect frame = _backgroundView.frame;
    frame.size.height = MAX(_userGridView.frame.size.height, _userGridView.contentSize.height) - frame.origin.y * 2;
    _backgroundView.frame = frame;
}

//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//初始化刷新视图
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#pragma mark
#pragma methods for creating and removing the header view

- (void)createHeaderView
{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
	_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                          CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                     self.view.frame.size.width, self.view.bounds.size.height) arrowImage:[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"arrow" ofType:@"png"]] textColor:TEXT_COLOR];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
	[_userGridView addSubview:_refreshHeaderView];
    
//    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)setFooterView
{
	//    UIEdgeInsets test = self.aoView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(_userGridView.contentSize.height, _userGridView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              _userGridView.frame.size.width,
                                              self.view.bounds.size.height);
    } else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         _userGridView.frame.size.width, self.view.bounds.size.height) arrowImage:[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"arrow" ofType:@"png"]] textColor:TEXT_COLOR];
        _refreshFooterView.delegate = self;
        [_userGridView addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView)
	{
        _refreshFooterView.backgroundColor = self.view.backgroundColor;
//        [_refreshFooterView refreshLastUpdatedDate];
    }
}


- (void)removeFooterView
{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
}

//===============
//刷新delegate
#pragma mark -
#pragma mark data reloading methods that must be overide by the subclass

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
	
	//  should be calling your tableviews data source model to reload
	_isLoading = YES;
    
    if (aRefreshPos == EGORefreshHeader) {
        // pull down to refresh data
        [self refreshData];
    } else if(aRefreshPos == EGORefreshFooter) {
        // pull up to load more data
        [self getNextPage];
    }
	
	// overide, the actual loading data operation is done in the subclass
}

#pragma mark -
#pragma mark method that should be called when the refreshing is finished

- (void)finishLoadingData
{
	//  model should call this when its done loading
	_isLoading = NO;
    
	if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_userGridView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_userGridView];
    }
    
    [self setFooterView];
    // overide, the actula reloading tableView operation and reseting position operation is done in the subclass
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (_refreshHeaderView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (_refreshFooterView)
	{
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (_refreshHeaderView)
	{
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (_refreshFooterView)
	{
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	
	[self beginToReloadData:aRefreshPos];
	
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
	
	return _isLoading; // should return if data source model is reloading
	
}

#pragma mark - Actions -

- (IBAction)gobackBtnClicked:(id)sender
{
//    [GotyeAPI removeRoomListener:self];
//    [GotyeAPI removeUserListener:self];
//    [GotyeAPI removeDownloadListener:self];
//    
//    [[GotyeSDKUIControl sharedInstance]hideHudInView:_userGridView animated:NO];
    [[GotyeSDKUIControl sharedInstance]popViewControllerAnimated:YES];
}

- (void)userBtnClicked:(id)sender
{
    DLog(@"avatar click %d", ((UIButton *)sender).tag);
    
    GotyeUserInfoVC *userInfo = [[GotyeUserInfoVC alloc]initWithUserAccount:_userArray[((UIButton *)sender).tag]];
    [userInfo showInView:self.view];
}

#pragma mark - room delegate -

- (void)onGetRoomUserList:(NSArray *)userList atPage:(NSUInteger)page inRoom:(GotyeRoom *)room result:(GotyeStatusCode)status
{
    if (page != _curPage) {
        return;
    }
    
    [[GotyeSDKUIControl sharedInstance]hideHudInView:_userGridView animated:NO];
    
    //加载第0页失败时才显示错误提示
    if (status != GotyeStatusCodeOK && _curPage == 0 && status != GotyeStatusCodeTimeout) {
        [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:[GotyeStatusMessage statusMessage:status] delegate:nil];
        [self finishLoadingData];
        return;
    }
    
    if (userList.count <= 0) {
        [self finishLoadingData];
        return;
    }

    ++_curPage;
    [self addUser:userList];
    [self refreshView];
    
    [self finishLoadingData];
}

#pragma mark - grid view delegate -

- (NSString*)gridView:(NRGridView*)gridView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (CGFloat)gridView:(NRGridView*)gridView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSString*)gridView:(NRGridView*)gridView titleForFooterInSection:(NSInteger)section
{
    return @"";
}

- (CGFloat)gridView:(NRGridView*)gridView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)gridView:(NRGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return _userArray.count;
}

- (NRGridViewCell*)gridView:(NRGridView*)gridView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *gridIndentifier = @"userGridCell";
    GotyeUserGridCell *cell = (GotyeUserGridCell *)[gridView dequeueReusableCellWithIdentifier:gridIndentifier];
    if (cell == nil) {
        cell = [[GotyeUserGridCell alloc]initWithReuseIdentifier:gridIndentifier];
        cell.selectionBackgroundView = nil;
    }
    
    NSString *accountName = _userArray[indexPath.row];
    GotyeSDKUserInfo *userInfo = [[GotyeSDKData sharedInstance]getUserWithAccount:accountName];
    if (userInfo == nil) {
        userInfo = [[GotyeSDKUserInfo alloc]initWithUniqueID:accountName];
    }
    
    UIImage *avatar = userInfo.userAvatar;
    if (avatar == nil) {
        avatar = [[GotyeImageManager sharedImageManager]getImageWithPath:userInfo.headValue];
        if (avatar == nil) {
            avatar = [GotyeSDKResource getDefaultAvatar];
        }
    }
    
    cell.avatarBtn.frame = CGRectMake((kGridCellWidth - kUserAvatarSize) / 2, kYInset, kUserAvatarSize, kUserAvatarSize);
    cell.avatarBtn.tag = indexPath.row;
    [cell.avatarBtn setBackgroundImage:[avatar maskWithImage:[GotyeSDKResource getAvatarMask]] forState:UIControlStateNormal];
    [cell.avatarBtn addTarget:self action:@selector(userBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.nameLabel.frame = CGRectMake(5, cell.avatarBtn.frame.origin.y + cell.avatarBtn.frame.size.height, kGridCellWidth - 5 * 2, kNameHeight);
    [cell.nameLabel setText:userInfo.name];
    
    return cell;
}


#pragma mark - user delegate -

- (void)onGetUserInfo:(GotyeUser *)user result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    [self refreshView];
}

#pragma mark - user delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    [self refreshView];
}

@end
