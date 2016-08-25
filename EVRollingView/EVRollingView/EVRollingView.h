//
//  EVRollingView.h
//  EVRollingView
//
//  Created by iwevon on 16/8/15.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^RollingViewClickLableBlock)(NSInteger index);;

@interface EVRollingView: UIView

@property (nonatomic, strong) NSArray *titlesGroup;

/** 自动滚动间隔时间,默认0.02s */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

/** Title颜色 */
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic,copy) RollingViewClickLableBlock clickLableBlock;

- (void)removeTimer;
- (void)addTimer;

@end
