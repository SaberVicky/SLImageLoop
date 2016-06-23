//
//  SLImageLoopView.m
//  SLImageLoopDemo
//
//  Created by songlong on 16/6/20.
//  Copyright © 2016年 SaberGame. All rights reserved.
//

#import "SLImageLoopView.h"
#import "SLLineLayout.h"

static NSInteger const SLImageLoopViewMultiple = 4;
static NSString *const SLImageLoopViewReusedId = @"SLImageLoopViewReusedId";

@interface SLImageLoopView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger imagesCount;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) SLImageLoopLayoutStyle style;

@end

@implementation SLImageLoopView


- (instancetype)initWithFrame:(CGRect)frame Style:(SLImageLoopLayoutStyle)style; {
    if (self = [super initWithFrame:frame]) {
        _autoScroll = YES;
        _style = style;
        _timeInterval = 2.0;
        
        switch (style) {
            case SLImageLoopLayoutStyleDefault:
                [self defaultInitWithFrame:frame];
                break;
              
            case SLImageLoopLayoutStyleLineLayout:
                [self lineLayoutInitWithFrame:frame];
                break;
                
            default:
                break;
        }
        
        [self addTimer];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.collectionView.frame.size.width / 2 - 100, self.collectionView.frame.size.height - 50, 200, 50)];
        _pageControl.pageIndicatorTintColor = [UIColor orangeColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
        [self addSubview:_pageControl];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.dataSource respondsToSelector:@selector(numberOfImages:)] && [self.dataSource numberOfImages:self] > 1) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.dataSource numberOfImages:self] * SLImageLoopViewMultiple / 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    

    if (_hidePageControl) {
        [_pageControl removeFromSuperview];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame Style:SLImageLoopLayoutStyleDefault];
}

#pragma mark --- Private Method

- (void)lineLayoutInitWithFrame:(CGRect)frame {
    SLLineLayout *layout = [[SLLineLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:SLImageLoopViewReusedId];
    [self addSubview:_collectionView];
}

- (void)defaultInitWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = frame.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:SLImageLoopViewReusedId];
    [self addSubview:_collectionView];
}

#pragma mark --- UICollectionView Delegate / DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(numberOfImages:)]) {
        _imagesCount = [self.dataSource numberOfImages:self];
        _pageControl.numberOfPages = _imagesCount;
        if (_imagesCount == 1) {
            _autoScroll = NO;
            [_pageControl removeFromSuperview];
            return 1;
        }
        return _imagesCount * SLImageLoopViewMultiple;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SLImageLoopViewReusedId forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if ([self.delegate respondsToSelector:@selector(placeholderViewForImageLoopView:)]) {
        if ([self.delegate placeholderViewForImageLoopView:self]) {
            UIView *view = [self.delegate placeholderViewForImageLoopView:self];
            view.frame = cell.contentView.frame;
            [cell.contentView addSubview:view];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(imageLoopView:viewForItemAtIndex:)]) {
        if ([self.delegate imageLoopView:self viewForItemAtIndex:indexPath.item % [self.dataSource numberOfImages:self]]) {
            UIView *view = [self.delegate imageLoopView:self viewForItemAtIndex:indexPath.item % _imagesCount];
            view.frame = cell.contentView.frame;
            [cell.contentView addSubview:view];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(imageLoopView:didSelectItemAtIndex:)]) {
        [self.delegate imageLoopView:self didSelectItemAtIndex:indexPath.item % _imagesCount];
    }
}

#pragma mark --- ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_pageControl) {
        return;
    }
    
    CGFloat width = _style == SLImageLoopLayoutStyleDefault ? self.collectionView.frame.size.width : (self.collectionView.frame.size.width * 2 / 3);
    CGFloat times = scrollView.contentOffset.x / width;
    NSInteger count = (NSInteger)times;
    
    
    CGFloat decimals = times - (NSInteger)(times);
    _currentIndex = count;
    
    if (decimals > 0.5) {
        _pageControl.currentPage = count % _imagesCount + 1 == _imagesCount ? 0 : count % _imagesCount + 1;
    } else {
        _pageControl.currentPage = count % _imagesCount;
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}


#pragma mark --- Timer Method

- (void)addTimer {
    
    if (_autoScroll) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextImage {
    if (_imagesCount <= 1) {
        [self removeTimer];
        return;
    }
    
    
    if (_currentIndex == _imagesCount * SLImageLoopViewMultiple - 1) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_imagesCount * SLImageLoopViewMultiple / 2  inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        return;
    }
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark --- Setter Method

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    [self removeTimer];
    [self addTimer];
}


@end
