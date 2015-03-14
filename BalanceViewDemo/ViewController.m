//
//  ViewController.m
//  BalanceViewDemo
//
//  Created by Yang Han on 15/3/14.
//  Copyright (c) 2015年 Yang Han. All rights reserved.
//

#import "ViewController.h"
#import "GYBalanceLayoutHelper.h"

@interface ViewController ()

@property (strong, nonatomic) UIView *displayView;
@property (strong, nonatomic) NSArray *images;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self.view addSubview:self.displayView];
  
  [GYBalanceLayoutHelper layoutItems:[self.images copy] withPreferredRowHeight:120 callback: ^(NSArray *items, CGSize contentSize) {
    NSLog(@"%@", [NSValue valueWithCGSize:contentSize]);
    
    self.displayView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    self.displayView.center = self.view.center;
    
    for (NSUInteger index = 0; index < [items count]; index++) {
      NSValue *rectValue = items[index];
      CGRect itemRect = [rectValue CGRectValue];
      
      UIImageView *imageView = [[UIImageView alloc] initWithFrame:itemRect];
      imageView.image = self.images[index];
      [self.displayView addSubview:imageView];
    }
  }];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSArray *)images {
  if (!_images) {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 9; i++) {
      NSString *imageName = [NSString stringWithFormat:@"%d.png", i];
      [images addObject:[UIImage imageNamed:imageName]];
    }
    _images = [images copy];
  }
  
  return _images;
}

- (UIView *)displayView {
  if (!_displayView) {
    _displayView = [[UIView alloc] init];
  }
  
  return _displayView;
}

@end
