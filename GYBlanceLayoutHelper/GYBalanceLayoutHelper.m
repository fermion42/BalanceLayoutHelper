//
//  BalanceView.m
//  BalanceViewDemo
//
//  Created by Yang Han on 15/3/14.
//  Copyright (c) 2015年 Yang Han. All rights reserved.
//

#import "GYBalanceLayoutHelper.h"
#import "NHLinearPartition.h"

@interface GYBalanceLayoutHelper ()

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSMutableArray *itemFrames;

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) CGFloat preferredRowSize;

@end

@implementation GYBalanceLayoutHelper

#pragma mark Public

+ (void)layoutItems:(NSArray *)items withPreferredRowHeight:(CGFloat)height callback:(BalanceLayoutHelperCallback)block {
  GYBalanceLayoutHelper *helper = [[GYBalanceLayoutHelper alloc] init];
  helper.items = items;
  helper.preferredRowSize = height;
  
  [helper perpareLayout];
  block([helper.itemFrames copy], helper.contentSize);
}

#pragma mark Lifecycle

- (void)clearItemFrames {
  [self.itemFrames removeAllObjects];
}

- (void)dealloc {
}

- (instancetype)init {
  if (!(self = [super init])) {
    return nil;
  }
  
  [self initialize];
  return self;
}

- (void)initialize {
  _itemFrames = NULL;
  
  self.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
  self.minimumLineSpacing = 5;
  self.minimumInteritemSpacing = 5;
}

#pragma mark Properties

- (NSMutableArray *)itemFrames {
  if (!_itemFrames) {
    _itemFrames = [[NSMutableArray alloc] init];
  }
  
  return _itemFrames;
}

- (CGFloat)preferredRowSize {
  if (!_preferredRowSize) {
    _preferredRowSize = CGRectGetHeight([UIScreen mainScreen].bounds) / 6;
  }
  
  return _preferredRowSize;
}

#pragma Private methods

- (void)perpareLayout {
  CGFloat idealHeight = self.preferredRowSize;
  CGSize contentSize = CGSizeZero;
  
  [self clearItemFrames];
  
  CGFloat totalItemSize = [self totalItemSizeWithPreferredRowSize:idealHeight];
  NSInteger numberOfRows = MAX(roundf(totalItemSize / [self viewPortAvailableSize]), 1);
  
  [self setFrames:self.itemFrames numberOfRows:numberOfRows contentSize:&contentSize];
  
  self.contentSize = contentSize;
}

- (CGFloat)totalItemSizeWithPreferredRowSize:(CGFloat)preferredRowSize {
  CGFloat totalItemSize = 0;
  for (UIImage *image in self.items) {
    CGSize preferredSize = image.size;
    totalItemSize += (preferredSize.width / preferredSize.height) * preferredRowSize;
  }
  
  return totalItemSize;
}

- (CGFloat)viewPortWidth {
  return CGRectGetWidth([UIScreen mainScreen].bounds) - self.contentInset.left - self.contentInset.right;
}

- (CGFloat)viewPortAvailableSize {
  CGFloat availableSize = 0;
  
  availableSize = [self viewPortWidth];
  
  return availableSize;
}

- (void)setFrames:(NSMutableArray *)frames numberOfRows:(NSUInteger)numberOfRows contentSize:(CGSize *)contentSize {
  NSArray *weights = [self weightsForItems];
  NSArray *partition = [NHLinearPartition linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
  
  int i = 0;
  CGPoint offset = CGPointMake(0, 0);
  CGFloat previousItemSize = 0;
  CGFloat contentMaxValue = 0;
  
  for (NSArray *row in partition) {
    CGFloat summedRatios = 0;
    
    for (NSInteger j = i, n = i + [row count]; j < n; j++) {
      CGSize preferredSize = [(id < BalanceItem >)[self.items objectAtIndex : j] size];
      summedRatios += preferredSize.width / preferredSize.height;
    }
    
    CGFloat rowSize = [self viewPortAvailableSize] - (([row count] - 1) * self.minimumInteritemSpacing);
    for (NSInteger j = i, n = i + [row count]; j < n; j++) {
      CGSize preferredSize = [(id < BalanceItem >)[self.items objectAtIndex : j] size];
      
      CGSize actualSize = CGSizeZero;
      actualSize = CGSizeMake(roundf(rowSize / summedRatios * (preferredSize.width / preferredSize.height)), roundf(rowSize / summedRatios));
      
      CGRect frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height);
      // copy frame into frames ptr and increment ptr
      [self.itemFrames addObject:[NSValue valueWithCGRect:frame]];
      
      offset.x += actualSize.width + self.minimumInteritemSpacing;
      previousItemSize = actualSize.height;
      contentMaxValue = CGRectGetMaxY(frame);
    }
    
    /**
     * Check if row actually contains any items before changing offset,
     * because linear partitioning algorithm might return a row with no items.
     */
    if ([row count] > 0) {
      // move offset to next line
      offset = CGPointMake(0, offset.y + previousItemSize + self.minimumLineSpacing);
    }
    
    i += [row count];
  }
  
  *contentSize = CGSizeMake([self viewPortWidth], (contentMaxValue));
}

- (NSArray *)weightsForItems {
  NSMutableArray *weights = [NSMutableArray array];
  
  for (NSInteger i = 0, n = [self.items count]; i < n; i++) {
    id <BalanceItem> item = self.items[i];
    CGSize preferredSize = [item size];
    NSInteger aspectRatio =  roundf((preferredSize.width / preferredSize.height) * 100);
    [weights addObject:@(aspectRatio)];
  }
  
  return [weights copy];
}

@end
