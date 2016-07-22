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
    
    CGRect navFrame = self.navigationBar.frame;
    navFrame.origin.y -= 20;
    navFrame.size.height += 20;
    navFrame.size.width = 0;
    _progressView = [[UIView alloc] initWithFrame:navFrame];
    _progressView.backgroundColor = [UIColor colorWithRed:1.00 green:0.71 blue:0.00 alpha:1.0];
    
    [self.navigationBar addSubview:_progressView];
    [self.navigationBar bringSubviewToFront:self.containerView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSUploadUpdate" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSDictionary *update = notification.userInfo;
        
        if ([update[@"type"] isEqualToString:@"progress"]) {
            NSNumber *uploadPercentage = update[@"percentage"];
            float percentage = [uploadPercentage floatValue];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect navFrame = self.navigationBar.frame;
                navFrame.origin.y -= 40;
                navFrame.size.height += 20;
                navFrame.size.width = self.navigationBar.frame.size.width * percentage;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:.05 animations:^{
                        _progressView.frame = navFrame;
                        [self showUploadButtons:TRUE];
                    }];
                });
            });
        }
        else if ([update[@"type"] isEqualToString:@"completion"]) {
            CGRect navFrame = self.navigationBar.frame;
            navFrame.origin.y -= 20;
            navFrame.size.height += 20;
            navFrame.size.width = 0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.2 animations:^{
                    _progressView.alpha = 0;
                    [self showUploadButtons:FALSE];
                } completion:^(BOOL finished) {
                    _progressView.frame = navFrame;
                    _progressView.alpha = 1;
                }];
            });
        }
        else if ([update[@"type"] isEqualToString:@"failure"]) {
            CGRect navFrame = self.navigationBar.frame;
            navFrame.origin.y -= 20;
            navFrame.size.height += 20;
            navFrame.size.width = 0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.2 animations:^{
                    _progressView.alpha = 0;
                    [self showFailureUI];
                } completion:^(BOOL finished) {
                    _progressView.frame = navFrame;
                    _progressView.alpha = 1;
                }];
            });

        }
        
    }];
}

-(void)showFailureUI {
    
    //
    [self showFailureButtons:TRUE];
    [self showUploadButtons:FALSE];
}

-(void)showFailureButtons:(BOOL)show {
    
}

-(void)showUploadButtons:(BOOL)show {
    
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

-(instancetype)init {
    self = [super initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    
    if (self) {
        
    }
    
    return self;
}

@end
