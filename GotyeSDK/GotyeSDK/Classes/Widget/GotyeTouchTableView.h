//
//  GotyeTouchTableView.h
//  GotyeSDK
//
//  Created by ouyang on 14-3-7.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//
//  UITableView的子类，实现了捕捉UITableView上的touch事件

#import <UIKit/UIKit.h>

@protocol GotyeTouchTableViewDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
 touchesCancelled:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesEnded:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesMoved:(NSSet *)touches
        withEvent:(UIEvent *)event;


@end

@interface GotyeTouchTableView : UITableView

@property (nonatomic, GOTYESDK_WEAK_ATTR) id<GotyeTouchTableViewDelegate> touchDelegate;

@end
