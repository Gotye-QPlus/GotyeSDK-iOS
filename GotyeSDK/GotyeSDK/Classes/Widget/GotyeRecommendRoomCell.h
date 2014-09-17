//
//  GotyeRecommendRoomCell.h
//  GotyeSDK
//
//  Created by ouyang on 14-1-8.
//  Copyright (c) 2014年 AiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface GotyeRecommendRoomCell : UITableViewCell

@property(nonatomic, assign) IBOutlet UIImageView *roomImageView;
@property(nonatomic, assign) IBOutlet UILabel *roomNameLabel;
@property(nonatomic, assign) IBOutlet UIImageView *roomHeatView;
@property(nonatomic, assign) IBOutlet UIImageView *roomIcon;
@property(nonatomic, assign) IBOutlet UIView *divider;
@property(nonatomic, assign) IBOutlet UIView *rootView;

@end
