//
//  EVRollingView.m
//  EVRollingView
//
//  Created by iwevon on 16/8/15.
//  Copyright © 2016年 iwevon. All rights reserved.
//


#import "EVRollingView.h"


#define EVMaxSections 100
#define kCellLabelFont 14.0f
#define kCellLabelInternalWidth 50.0f


typedef NS_ENUM(NSInteger, EVRollingOrientation){
    EVRollingOrientationNone = 0,
    EVRollingOrientationLeft,
    EVRollingOrientationRight
};


#pragma mark - EVAdCollectionCell

@interface EVAdCollectionCell : UICollectionViewCell

@property (nonatomic, copy) NSString *labelTitle;

@property (nonatomic, assign) EVRollingOrientation orientation;
/** Title颜色 */
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, copy) void(^nextBlock)();

- (void)refreshText;

@end

@interface EVAdCollectionCell ()
@property (nonatomic, weak) UILabel *firstLabel;
@property (nonatomic, weak) UILabel *lastLabel;
//播放完成后暂停多少秒
@property (nonatomic, assign) NSInteger curNumber;
//进入时暂停多少秒
@property (nonatomic, assign) NSInteger initialNumber;
@end

@implementation EVAdCollectionCell

- (UILabel *)firstLabel {
    if (!_firstLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kCellLabelFont];
        label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label];
        _firstLabel = label;
    }
    return _firstLabel;
}

- (UILabel *)lastLabel {
    if (!_lastLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:kCellLabelFont];
        label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label];
        _lastLabel = label;
    }
    return _lastLabel;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _firstLabel.textColor = titleColor;
    _lastLabel.textColor = titleColor;
}

- (void)setLabelTitle:(NSString *)labelTitle {
    if (!labelTitle.length) return;
    _labelTitle = labelTitle;
    
    self.firstLabel.text = labelTitle;
    
    CGSize titleSize = [self.firstLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.firstLabel.frame = CGRectMake(0, 0, titleSize.width, self.bounds.size.height);
    if (titleSize.width > self.bounds.size.width) {
        self.lastLabel.text = labelTitle;
        self.lastLabel.frame = CGRectMake(CGRectGetMaxX(self.firstLabel.frame)+kCellLabelInternalWidth, CGRectGetMinY(self.firstLabel.frame), CGRectGetWidth(self.firstLabel.frame),  CGRectGetHeight(self.firstLabel.frame));
    }
}

- (void)refreshText {
    
    if (self.initialNumber <= 60) {
        self.initialNumber ++;
        return;
    }
    if (_lastLabel) {
        CGRect firstLabel = self.firstLabel.frame;
        NSInteger sign = (self.orientation == EVRollingOrientationLeft) ? -1 : 1;
        firstLabel.origin.x += sign;
        self.firstLabel.frame = firstLabel;
        self.lastLabel.frame = CGRectMake(CGRectGetMaxX(self.firstLabel.frame)+kCellLabelInternalWidth, CGRectGetMinY(self.firstLabel.frame), CGRectGetWidth(self.firstLabel.frame),  CGRectGetHeight(self.firstLabel.frame));
        if (CGRectGetMinX(self.lastLabel.frame) < 0) {
            [self.lastLabel removeFromSuperview];
            self.lastLabel = nil;
            firstLabel.origin.x = 0;
            self.firstLabel.frame = firstLabel;
            
            [self realizationWithInterval:30];
        }
    } else {
        [self realizationWithInterval:300];
    }
}

- (void)realizationWithInterval:(NSInteger)interval {
    self.curNumber ++;
    if (self.curNumber == interval) {
        self.curNumber = 0;
        self.initialNumber = 0;
        self.nextBlock?self.nextBlock():nil;
    }
}


@end


#pragma mark - EVRollingView

@interface EVRollingView ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (nonatomic,weak) UICollectionView *collectionView;
@property(nonatomic,strong) NSTimer *timer;


@end

@implementation EVRollingView

NSString * const cellIndetifier = @"EVAdCollectionCell";

#pragma mark getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        // 创建collectionView
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.scrollEnabled = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:collectionView];
        _collectionView = collectionView;
        
        // 注册cell
        [collectionView registerClass:[EVAdCollectionCell class] forCellWithReuseIdentifier:cellIndetifier];
        // 默认显示最中间的那组
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:EVMaxSections/2] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    return _collectionView;
}


#pragma mark public

- (void)setTitlesGroup:(NSArray *)titlesGroup {
    _titlesGroup = titlesGroup;
    [self.collectionView reloadData];
    [self addTimer];
}

/**
 *  添加定时器
 */
- (void)addTimer
{
    if (self.timer) return;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval?:0.02f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

/**
 *  移除定时器
 */
- (void)removeTimer
{
    // 停止定时器
    [self.timer invalidate];
    self.timer = nil;
}

- (NSIndexPath *)resetIndexPath
{
    // 当前正在展示的位置
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    // 马上显示回最中间那组的数据
    NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:EVMaxSections/2];
    [self.collectionView scrollToItemAtIndexPath:currentIndexPathReset atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    return currentIndexPathReset;
}

-(void)timerAction {
    // 当前正在展示的位置
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    if (currentIndexPath.section == EVMaxSections/2) {
        EVAdCollectionCell *cell = (EVAdCollectionCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
        [cell refreshText];
    } else {
        [self resetIndexPath];
    }
}

/**
 *  下一页
 */
- (void)nextPage
{
    // 1.马上显示回最中间那组的数据
    NSIndexPath *currentIndexPathReset = [self resetIndexPath];
    // 2.计算出下一个需要展示的位置
    NSInteger nextItem = currentIndexPathReset.item + 1;
    NSInteger nextSection = currentIndexPathReset.section;
    if (nextItem == self.titlesGroup.count) {
        nextItem = 0;
        nextSection++;
    }
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    
    // 3.通过动画滚动到下一个位置
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titlesGroup.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return EVMaxSections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EVAdCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndetifier forIndexPath:indexPath];
    cell.labelTitle = self.titlesGroup[indexPath.row];
    cell.orientation = EVRollingOrientationLeft;
    if (self.titleColor) {
        cell.titleColor = self.titleColor;
    }
    cell.nextBlock = ^{
        [self nextPage];
    };
    return cell;
}

#pragma mark  - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.clickLableBlock?self.clickLableBlock(indexPath.row):nil;
}

/**
 *  当用户即将开始拖拽的时候就调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

/**
 *  当用户停止拖拽的时候就调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

#pragma mark dealloc

- (void)dealloc {
    [self removeTimer];
}

@end
