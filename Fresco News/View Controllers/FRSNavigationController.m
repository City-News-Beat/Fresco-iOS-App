//
//  FRSNavigationController.m
//  Fresco
//
//  Created by Daniel Sun on 12/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSNavigationController.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import "FRSNavigationBar.h"

#define BAR_BUTTON_WIDTH 24
#define SIDE_MARGIN 6
#define SIDE_PADDING 6

@interface FRSNavigationController ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIButton *firstTab;
@property (strong, nonatomic) UIButton *secondTab;

@property (strong, nonatomic) UIButton *firstTabContainer;
@property (strong, nonatomic) UIButton *secondTabContainer;

@property (strong, nonatomic) UIButton *leftBarItem;
@property (strong, nonatomic) UIButton *rightBarItem;

@property (strong, nonatomic) UIButton *extraBarItem;
@property (strong, nonatomic) UIView *progressView;

@end

@implementation FRSNavigationController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    self.hidesBarsOnSwipe = false;
    self.hidesBarsOnTap = false;
    self.hidesBarsWhenVerticallyCompact=false;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.titleView.backgroundColor = [UIColor frescoOrangeColor];
    
    [self.containerView addSubview:self.titleView];
    [self.navigationBar bringSubviewToFront:self.containerView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)configureFRSNavigationBarWithTitle:(NSString *)title{
    
    if (!self.titleLabel){
        self.titleLabel = [[UILabel alloc] init];
        [self.titleView addSubview:self.titleLabel];
    }
    
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont notaBoldWithSize:17];
    [self.titleLabel sizeToFit];
    [self.titleLabel centerHorizontallyInView:self.titleView];
    [self.titleLabel setOriginWithPoint:CGPointMake(self.titleLabel.frame.origin.x, 15)];
    
    self.navigationBar.topItem.titleView = self.containerView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Showed Nav");
}

-(void)adjustFrames{
    
    NSInteger availableWidth = [UIScreen mainScreen].bounds.size.width - SIDE_MARGIN * 2 - SIDE_PADDING * 4 - BAR_BUTTON_WIDTH * 2;
    NSInteger minusButtons = availableWidth - self.firstTab.frame.size.width - self.secondTab.frame.size.width;
    NSInteger centerPadding = minusButtons/2.2;
    
    self.firstTab.frame = CGRectMake(self.firstTabContainer.frame.size.width - centerPadding/2 - self.firstTab.frame.size.width, 7, self.firstTab.frame.size.width, self.firstTab.frame.size.height);
    self.secondTab.frame = CGRectMake(centerPadding/2, 7, self.secondTab.frame.size.width , self.secondTab.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
