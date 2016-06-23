//
//  ViewController.m
//  SLImageLoopDemo
//
//  Created by songlong on 16/6/20.
//  Copyright © 2016年 SaberGame. All rights reserved.
//

#import "ViewController.h"
#import "SLImageLoopView.h"

@interface ViewController ()<SLImageLoopDataSource, SLImageLoopDelegate>

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) SLImageLoopView *loopView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageArray = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.png"];
    _loopView = [[SLImageLoopView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 300) Style:SLImageLoopLayoutStyleLineLayout];
    _loopView.delegate = self;
    _loopView.dataSource = self;
    _loopView.autoScroll = YES;
    [self.view addSubview:_loopView];
}


- (NSInteger)numberOfImages:(SLImageLoopView *)loopView {
    return _imageArray.count;
}

- (UIView *)placeholderViewForImageLoopView:(SLImageLoopView *)loopView {
    return nil;
}

- (UIView *)imageLoopView:(SLImageLoopView *)loopView viewForItemAtIndex:(NSInteger)index {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imageArray[index]]];
}

- (void)imageLoopView:(SLImageLoopView *)loopView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"%zd", index);
}



@end
