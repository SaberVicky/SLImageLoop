//
//  SLImageLoopView.h
//  SLImageLoopDemo
//
//  Created by songlong on 16/6/20.
//  Copyright © 2016年 SaberGame. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLImageLoopView;

typedef NS_OPTIONS(NSUInteger, SLImageLoopLayoutStyle) {
    SLImageLoopLayoutStyleDefault,
    SLImageLoopLayoutStyleLineLayout
};


@protocol SLImageLoopDataSource <NSObject>

- (NSInteger)numberOfImages:(SLImageLoopView *)loopView;

@end

@protocol SLImageLoopDelegate <NSObject>

- (UIView *)placeholderViewForImageLoopView:(SLImageLoopView *)loopView;
- (UIView *)imageLoopView:(SLImageLoopView *)loopView viewForItemAtIndex:(NSInteger)index;
- (void)imageLoopView:(SLImageLoopView *)loopView didSelectItemAtIndex:(NSInteger)index;

@end

@interface SLImageLoopView : UIView

@property (nonatomic, weak) id<SLImageLoopDataSource> dataSource;
@property (nonatomic, weak) id<SLImageLoopDelegate> delegate;

//是否隐藏pageControl，默认为NO
@property (nonatomic, assign) BOOL hidePageControl;
//滑动时间间隔，默认为2s
@property (nonatomic, assign) NSTimeInterval timeInterval;
//是否开启自动滑动，默认为YES
@property (nonatomic, assign) BOOL autoScroll;

- (instancetype)initWithFrame:(CGRect)frame Style:(SLImageLoopLayoutStyle)style;

@end
