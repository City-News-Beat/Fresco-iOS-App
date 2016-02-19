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

@end

@implementation FRSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.titleView.backgroundColor = [UIColor frescoOrangeColor];

    
    [self.containerView addSubview:self.titleView];
    
    
//    self.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Do any additional setup after loading the view.
}

-(void)configureTabContainers{
    
    //    NSInteger availableWidth = [UIScreen mainScreen].bounds.size.width - SIDE_MARGIN * 2 - SIDE_PADDING * 4 - BAR_BUTTON_WIDTH * 2;
    //    NSInteger minusButtons = availableWidth - self.firstTab.frame.size.width - self.secondTab.frame.size.width;
    //    NSInteger centerPadding = minusButtons/3;
    NSInteger firstOrigin = SIDE_MARGIN + SIDE_PADDING*2 + BAR_BUTTON_WIDTH;
    if (!self.firstTabContainer){
        self.firstTabContainer = [[UIButton alloc] initWithFrame:CGRectMake(firstOrigin, 0, [UIScreen mainScreen].bounds.size.width/2 - firstOrigin, 44)];
        [self.titleView addSubview:self.firstTabContainer];
    }
    
    if (!self.secondTabContainer){
        self.secondTabContainer = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 0, self.firstTabContainer.frame.size.width, 44)];
        [self.titleView addSubview:self.secondTabContainer];
    }
    
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

-(void)configureFRSNavigationBarWithTabs:(NSArray *)tabs{
    
    [self configureTabContainers];
    
    if (!self.firstTab) {
        self.firstTab = [[UIButton alloc] init];
        [self.firstTabContainer addSubview:self.firstTab];
    }
    
    if (!self.secondTab) {
        self.secondTab = [[UIButton alloc] init];
        [self.secondTabContainer addSubview:self.secondTab];
    }
    
    [self.firstTab setTitle:[tabs firstObject] forState:UIControlStateNormal];
    [self.secondTab setTitle:[tabs lastObject] forState:UIControlStateNormal];
    
    [self.firstTab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.secondTab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.firstTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.secondTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    
    [self.firstTab sizeToFit];
    [self.secondTab sizeToFit];
    
    [self adjustFrames];
    
    self.navigationBar.topItem.titleView = self.containerView;
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
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
