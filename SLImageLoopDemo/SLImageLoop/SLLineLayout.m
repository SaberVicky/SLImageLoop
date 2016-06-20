//
//  SLLineLayout.m
//  线性布局
//
//  Created by songlong on 15/11/30.
//  Copyright © 2015年 songlong. All rights reserved.
//

#import "SLLineLayout.h"

@implementation SLLineLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat itemWH = self.collectionView.frame.size.height * 0.8;
    self.itemSize = CGSizeMake(itemWH, itemWH * 0.7);
    
    CGFloat insetLR = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, insetLR, 0, insetLR);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    NSArray *array = [[NSArray alloc] initWithArray:original copyItems:YES];
    
    CGFloat centerX = self.collectionView.contentOffset.x  + self.collectionView.frame.size.width * 0.5;
    
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGFloat delta = ABS(attrs.center.x - centerX);
        
        CGFloat scale = 1- delta / (self.collectionView.frame.size.width + self.itemSize.width);
        attrs.transform = CGAffineTransformMakeScale(scale, scale);
        attrs.alpha = scale * scale * scale * scale;
    }
    return array;
}

//当CollectionView的bounds发生改变的时候是否刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGRect rect;
    rect.origin = proposedContentOffset;
    rect.size = self.collectionView.frame.size;
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGFloat delta = attrs.center.x - centerX;
        
        if (ABS(delta) < ABS(minDelta)) {
            minDelta = delta;
        }
    }
//    NSLog(@"%f", minDelta);
    return CGPointMake(proposedContentOffset.x + minDelta, proposedContentOffset.y);
    
}

@end































