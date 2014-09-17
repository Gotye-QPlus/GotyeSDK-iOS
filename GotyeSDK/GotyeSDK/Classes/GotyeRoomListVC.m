//
//  GotyeRoomListVC.m
//  GotyeSDK
//
//  Created by ouyang on 14-1-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import "GotyeRoomListVC.h"
#import "GotyeSDKResource.h"
#import "GotyeSDKUIControl.h"
#import "GotyeChatVC.h"
#import "GotyeAPI.h"
#import "GotyeImageManager.h"
#import "GotyeStatusMessage.h"
#import "UIImage+Mask.h"
#import "UIColor+HTML.h"
#import "GotyeSDkSkin.h"

#define CheckIfCurrentViewControllerAtTop \
if (self.navigationController.topViewController != self) { \
return; \
}

@interface GotyeRoomListVC ()
{
    GotyeRoom *_clickedRoom;
    
    CGRect backBtnFramePortrait;
    CGRect titleFramePortrait;
    CGRect topbarFramePortrait;
    
    UIImage *topbarBGPortrait;
    UIImage *topbarBGLandscape;
    UIImage *backBtnBG;
    UIEdgeInsets backBtnInsetsPortrait;
}
@end

@implementation GotyeRoomListVC

static NSString * const recommendCellIdentifier = @"GotyeRecommedRoomCell";
static NSString * const ordinaryCellIdentifier = @"GotyeOrdinaryRoomCell";

- (void)dealloc
{
    [GotyeAPI removeListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    backBtnFramePortrait = _backBtn.frame;
    titleFramePortrait = _titleLabel.frame;
    topbarFramePortrait = _topBar.frame;
    
    topbarBGPortrait = _topBarBG.image;
    topbarBGLandscape = [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"titlebar_bg_landscape" ofType:@"png"]];
    backBtnBG = [_backBtn backgroundImageForState:UIControlStateNormal];
    backBtnInsetsPortrait = _backBtn.imageEdgeInsets;
    
    // Do any additional setup after loading the view.
    [[GotyeSDKUIControl sharedInstance]showHudInView:self.view animated:NO text:@"加载中..."];
    
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeLogin];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeRoom];
    [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
    
    [self refreshData];
    [self createHeaderView];
    
    [_backBtn setTitleColor:[UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorBack]] forState:UIControlStateNormal];
    _titleLabel.textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorMainTitle]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [GotyeAPI addListener:self type:GotyeAPIListenerTypeLogin];
//    [GotyeAPI addListener:self type:GotyeAPIListenerTypeRoom];
//    [GotyeAPI addListener:self type:GotyeAPIListenerTypeDownload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [GotyeAPI removeListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeToLandscapeMode
{
    _topBar.frame = CGRectMake(0, 0, kSidebarWidth, UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? self.view.bounds.size.height : self.view.bounds.size.width);
    _topBarBG.image = topbarBGLandscape;
    
    CGFloat mainViewX = _topBar.frame.size.width;
    _roomListView.frame = CGRectMake(mainViewX, 0, self.view.bounds.size.width - mainViewX, self.view.bounds.size.height);
    
    _roomIconView.hidden = NO;
    _roomIconView.frame = CGRectMake((_topBar.frame.size.width - _roomIconView.frame.size.width) / 2, 25, _roomIconView.frame.size.width, _roomIconView.frame.size.height);
    
    _titleLabel.frame = CGRectMake(0, _roomIconView.frame.origin.y + _roomIconView.frame.size.height + 10, _topBar.frame.size.width, 25);
    
    _backBtn.frame = CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 35, _topBar.frame.size.width, 40);
    [_backBtn setBackgroundImage:nil forState:UIControlStateNormal];
    _backBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 33, 13, 75);
    
    _greenLineTop.hidden = NO;
    _greenLineTop.frame = CGRectMake(0, _backBtn.frame.origin.y, _greenLineTop.frame.size.width, _greenLineTop.frame.size.height);
    
    _greenLineBottom.hidden = NO;
    _greenLineBottom.frame = CGRectMake(0, _backBtn.frame.origin.y + _backBtn.frame.size.height, _greenLineBottom.frame.size.width, _greenLineBottom.frame.size.height);
    
    [_roomListView reloadData];
}

- (void)changeToPortraitMode
{
    _topBar.frame = topbarFramePortrait;
    _topBarBG.image = topbarBGPortrait;
    
    CGFloat mainViewY = _topBar.frame.size.height;
    _roomListView.frame = CGRectMake(0, mainViewY, self.view.bounds.size.width, self.view.bounds.size.height - mainViewY);
    _roomListView.contentInset = UIEdgeInsetsZero;

    _backBtn.frame = backBtnFramePortrait;
    [_backBtn setBackgroundImage:backBtnBG forState:UIControlStateNormal];
    _backBtn.imageEdgeInsets = backBtnInsetsPortrait;
    _titleLabel.frame = titleFramePortrait;
    
    _greenLineTop.hidden = YES;
    _greenLineBottom.hidden = YES;
    _roomIconView.hidden = YES;
    
    [_roomListView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - private methods -

- (void)refreshData
{
    _curPage = 0;
    [GotyeAPI reqRoomListAtPage:_curPage];
}

- (void)getNextPage
{
    [GotyeAPI reqRoomListAtPage:_curPage];
}

- (void)enterRoom:(GotyeRoom *)room
{
    if (![[GotyeSDKUIControl sharedInstance]checkLoginState]) {
        return;
    }
    
    [[GotyeSDKUIControl sharedInstance]showHudInView:self.view animated:NO text:@"进入中..."];
    [GotyeAPI enterRoom:room];
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
    _refreshHeaderView.backgroundColor = _roomListView.backgroundColor;
	[_roomListView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)setFooterView
{
	//    UIEdgeInsets test = self.aoView.contentInset;
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(_roomListView.contentSize.height, _roomListView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              _roomListView.frame.size.width,
                                              self.view.bounds.size.height);
    } else {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height,
                                         _roomListView.frame.size.width, self.view.bounds.size.height) arrowImage:[UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"arrow" ofType:@"png"]] textColor:TEXT_COLOR];
        _refreshFooterView.delegate = self;
        [_roomListView addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView)
	{
        _refreshFooterView.backgroundColor = _roomListView.backgroundColor;
        [_refreshFooterView refreshLastUpdatedDate];
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
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_roomListView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_roomListView];
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

// if we don't realize this method, it won't display the refresh timestamp
//- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
//{
//	
//	return [NSDate date]; // should return date data source was last changed
//	
//}

#pragma mark - Actions -

- (IBAction)closeBtnClicked:(id)sender
{
    [[GotyeSDKUIControl sharedInstance]closeSDK:YES];
}

- (UINib *)recommendRoomCellNib
{
    if (!_recommendRoomCellNib) {
        NSString *nibName = (IS_IPAD ? @"GotyeRecommendRoomCell~ipad" : @"GotyeRecommendRoomCell");
        _recommendRoomCellNib = [UINib nibWithNibName:nibName bundle:[GotyeSDKResource resourceBundle]];
    }
    
    return _recommendRoomCellNib;
}

- (UINib *)ordinaryRoomCellNib
{
    if (!_ordinaryRoomCellNib) {
        NSString *nibName = (IS_IPAD ? @"GotyeOrdinaryRoomCell~ipad" : @"GotyeOrdinaryRoomCell");
        _ordinaryRoomCellNib = [UINib nibWithNibName:nibName bundle:[GotyeSDKResource resourceBundle]];
    }
    
    return _ordinaryRoomCellNib;
}

- (void)configureCell:(id)roomCell atIndex:(NSUInteger)index
{
    GotyeRoom *room = _roomArray[index];

    UIImage *roomImage = [[GotyeImageManager sharedImageManager]getImageWithPath:room.roomImg];
    if (roomImage == nil) {
        roomImage = [GotyeSDKResource getDefaultRoomImage];
    }
    
    UIImageView *roundedView = [roomCell roomImageView];
    UIImage *maskImage;
    if ([roomCell isMemberOfClass:[GotyeRecommendRoomCell class]]) {
        UIImage *hotImage;
        if (room.curNumber >= room.ceilingNumber) {
            hotImage = [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"recommend_cell_ic_full" ofType:@"png"]];
        } else {
            hotImage = [UIImage imageWithContentsOfFile:[GotyeSDKResource pathForResource:@"recommend_cell_ic_hot" ofType:@"png"]];
        }
        
        [roomCell roomHeatView].image = hotImage;
        maskImage = [[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:@"recommend_cell_mask_room_image" ofType:@"png"]];
        //有下一个且下一个房间不是置顶，则显示分割线
        [roomCell divider].hidden = (index + 1 < _roomArray.count && [_roomArray[index + 1]isTop]);
        [roomCell roomNameLabel].textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorTopCellName]];
    } else {
        maskImage = [GotyeSDKResource getAvatarMask];
        [roomCell roomNameLabel].textColor = [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorNormalCellName]];
    }
    
    roundedView.image = [roomImage maskWithImage:maskImage];
    [roomCell roomNameLabel].text = room.name;
    [roomCell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - table view data source -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _roomArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GotyeRoom *room = _roomArray[row];
    UITableViewCell *cell;
    id roomCell;
    if (room.isTop) {
        cell = [tableView dequeueReusableCellWithIdentifier:recommendCellIdentifier];
        if (cell == nil) {
            [[self recommendRoomCellNib]instantiateWithOwner:self options:nil];
            cell = _reuseRecommendRoomCell;
            _reuseRecommendRoomCell = nil;
        }
        roomCell = (GotyeRecommendRoomCell *)cell;
        UIView *rootView = [roomCell rootView];
        CGFloat rootViewX;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            rootViewX = 20;
        } else {
            rootViewX = 0;
        }
        rootView.frame = CGRectMake(rootViewX, 0, cell.frame.size.width  - rootViewX * 2, rootView.frame.size.height);
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:ordinaryCellIdentifier];
        if (cell == nil) {
            [[self ordinaryRoomCellNib]instantiateWithOwner:self options:nil];
            cell = _reuseOrdinaryRoomCell;
            _reuseOrdinaryRoomCell = nil;
        }
        roomCell = (GotyeOrdinaryRoomCell *)cell;
        
        UIView *enterBtn = [roomCell enterButton];
        CGFloat enterBtnYOffset;
        
        UIView *roomImgView = [roomCell roomImageView];
        CGFloat roomImgViewX;
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            enterBtnYOffset = 40;
            roomImgViewX = 30;
        } else {
            enterBtnYOffset = 20;
            roomImgViewX = 15;
        }
        enterBtn.frame = CGRectMake(cell.frame.size.width - enterBtnYOffset - enterBtn.frame.size.width, enterBtn.frame.origin.y, enterBtn.frame.size.width, enterBtn.frame.size.height);
        roomImgView.frame = CGRectMake(roomImgViewX, roomImgView.frame.origin.y, roomImgView.frame.size.width, roomImgView.frame.size.height);
    }
    
    [self configureCell:roomCell atIndex:indexPath.row];
    return cell;
}

#pragma mark - table view delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_clickedRoom != nil) {
        return;
    }
    
    _clickedRoom = _roomArray[indexPath.row];
    [self enterRoom:_clickedRoom];
    
}

#define RECOMMEND_CELL_HEIGHT_TOP (IS_IPAD ? 190 : 110)
#define RECOMMEND_CELL_HEIGHT     (IS_IPAD ? 160 : 95)
#define NORMAL_CELL_HEIGHT        (IS_IPAD ? 126 : 62)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeRoom *room = _roomArray[indexPath.row];
    if (room.isTop) {
        BOOL shouldHideDivider = indexPath.row + 1 < _roomArray.count && [_roomArray[indexPath.row + 1]isTop];
        return ((indexPath.row == 0 ? RECOMMEND_CELL_HEIGHT_TOP : RECOMMEND_CELL_HEIGHT) - (shouldHideDivider ? 3 : 0));
    } else {
        return NORMAL_CELL_HEIGHT;
    }
}

#pragma mark - GotyeGeneralDelegate -

- (void)onLoginResp:(GotyeStatusCode)statusCode account:(NSString *)account appKey:(NSString *)appKey
{
    CheckIfCurrentViewControllerAtTop
    
    if (statusCode != GotyeStatusCodeOK) {
        _clickedRoom = nil;
        return;
    }
    
    if (_clickedRoom != nil) {
        [self enterRoom:_clickedRoom];
    }
}

- (void)onLogout:(GotyeStatusCode)error account:(NSString *)account appKey:(NSString *)appKey
{
    CheckIfCurrentViewControllerAtTop
    
    if (error == GotyeStatusCodeOK) {
        return;
    }
    
    DLog(@"掉线了！");
    _clickedRoom = nil;
    [[GotyeSDKUIControl sharedInstance]hideHudInView:self.view animated:NO];
}

#pragma mark - Room delegate -

- (void)onGetRoomList:(NSArray *)roomList atPage:(NSUInteger)page result:(GotyeStatusCode)status
{
    CheckIfCurrentViewControllerAtTop
    
    DLog(@"onGetRoomList count: %d status: %d isMainThread %d", roomList.count, status, [NSThread isMainThread]);
    [[GotyeSDKUIControl sharedInstance]hideHudInView:self.view animated:NO];
    
    if (status != GotyeStatusCodeOK) {
        [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:@"获取聊天室列表失败" delegate:nil];
        [self finishLoadingData];
        return;
    }
    
    if (roomList.count <= 0) {
        [self finishLoadingData];
        return;
    }
    
    if (_curPage == 0) {
        [_roomArray removeAllObjects];
        _roomArray = [[NSMutableArray alloc]initWithArray:roomList];
    } else {
        assert(roomList != nil);
        [_roomArray addObjectsFromArray:roomList];
    }
    
    [_roomListView reloadData];
    ++_curPage;
    [self finishLoadingData];
}

- (void)onEnterRoom:(GotyeRoom *)room lastMsgID:(NSString *)lastMsgID result:(GotyeStatusCode)status
{
    CheckIfCurrentViewControllerAtTop
    
    DLog(@"onEnterRoom:%@ lastMsgID:%@ result: %d", room.uniqueID, lastMsgID, status);
    
    [[GotyeSDKUIControl sharedInstance]hideHudInView:self.view animated:NO];

    if (status != GotyeStatusCodeOK) {
        _clickedRoom = nil;
        if (status != GotyeStatusCodeTimeout) {
            [[GotyeSDKUIControl sharedInstance]showAlertViewWithTitle:nil message:[GotyeStatusMessage statusMessage:status] delegate:nil];
        }
        
        return;
    }
    
    GotyeChatVC *chatVC = [[GotyeChatVC alloc]initWithChatUnit:_clickedRoom lastMsgID:lastMsgID];
    [[GotyeSDKUIControl sharedInstance]pushViewController:chatVC animated:YES];
    
    _clickedRoom = nil;
}

#pragma mark download delegate -

- (void)onDownloadRes:(NSString *)downloadURL path:(NSString *)savedPath result:(GotyeStatusCode)status
{
    CheckIfCurrentViewControllerAtTop
    
    if (status != GotyeStatusCodeOK) {
        return;
    }
    
    [_roomListView reloadData];
}

@end
