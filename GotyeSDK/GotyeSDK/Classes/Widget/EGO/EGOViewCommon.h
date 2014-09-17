//
//  EGOViewCommon.h
//  TableViewRefresh
//
//  Created by  Abby Lin on 12-5-2.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef TableViewRefresh_EGOViewCommon_h
#define TableViewRefresh_EGOViewCommon_h

//#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define TEXT_COLOR     [UIColor colorWithHexString:[[GotyeSDkSkin sharedInstance]textColors][GotyeTextColorHeaderAndFooter]]

#define FLIP_ANIMATION_DURATION 0.18f

#define  REFRESH_REGION_HEIGHT ( MAX(scrollView.contentSize.height, scrollView.frame.size.height) - scrollView.contentSize.height + PULLING_OFFSET)

#define UPDATE_LABEL_FONT_SIZE      (IS_IPAD ? 20 : 12)
#define UPDATE_LABEL_HEIGHT         (IS_IPAD ? 35 : 20)

#define STATUS_LABEL_FONT_SIZE      (IS_IPAD ? 22 : 13)
#define STATUS_LABEL_HEIGHT         (IS_IPAD ? 35 : 20)
#define LABEL_OFFSET                (IS_IPAD ? 10 : 5)

#define INDICATOR_MARGIN_LEFT       (IS_IPAD ? 45 : 25)
#define INDICATOR_SIZE              (IS_IPAD ? 37 : 20)
#define INDICATOR_MARGIN_BOTTOM     (IS_IPAD ? 28 : 15)
#define INDICATOR_MARGIN_TOP        (IS_IPAD ? 38 : 20)
#define INDICATOR_STYLE             (IS_IPAD ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleGray)

#define ARROW_WIDTH                 (IS_IPAD ? 37 : 20)
#define ARROW_HEIGHT                (IS_IPAD ? 67 : 37)
#define ARROW_MARGIN_BOTTOM         (IS_IPAD ? 18 : 10)
#define ARROW_MARGIN_TOP            (IS_IPAD ? 25 : 10)

#define LOADING_OFFSET              (IS_IPAD ? 115 : 60)
#define PULLING_OFFSET              (IS_IPAD ? 120 : 65)

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;

typedef enum{
	EGORefreshHeader = 0,
	EGORefreshFooter	
} EGORefreshPos;

@protocol EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos;
- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view;
@optional
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view;
@end

#endif
