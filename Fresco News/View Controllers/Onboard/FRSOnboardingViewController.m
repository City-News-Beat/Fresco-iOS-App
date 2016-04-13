//
//  FRSOnboardingViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSOnboardingViewController.h"

#import "FRSOnboardOneView.h"
#import "FRSOnboardTwoView.h"
#import "FRSOnboardThreeView.h"

#import "UIView+Helpers.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

#import "FRSContentActionsBar.h"

#import "FRSLoginViewController.h"
#import "FRSSignUpViewController.h"

#import "OEParallax.h"

@interface FRSOnboardingViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) FRSOnboardThreeView *viewThree;
@property (strong, nonatomic) FRSOnboardOneView *viewOne;
@property NSInteger page;

@end

@implementation FRSOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureParallax];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - UI Configuration

-(NSString *)titleForActionButton{
    return @"READ MORE";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)configureUI{
    [self configureScrollView];
    [self configureOnboardingViews];
    [self configurePageControl];
    [self configureLogo];
    [self configureActionBar];
    
    //check zeplin for official value
    self.view.backgroundColor = [UIColor colorWithRed:0.953 green:0.953 blue:0.933 alpha:1.00];
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delaysContentTouches = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scrollView];
}

-(void)configureOnboardingViews{
    NSInteger offset = (self.scrollView.frame.size.width - 320)/2;
    
    self.viewOne = [[FRSOnboardOneView alloc] initWithOrigin:CGPointMake(offset, 0)];

    [self.scrollView addSubview:self.viewOne];
    
    FRSOnboardTwoView *viewTwo = [[FRSOnboardTwoView alloc] initWithOrigin:CGPointMake(self.view.frame.size.width + offset, 0)];
    [self.scrollView addSubview:viewTwo];
    
    self.viewThree = [[FRSOnboardThreeView alloc] initWithOrigin:CGPointMake(self.view.frame.size.width * 2 + offset, 0)];
    [self.scrollView addSubview:self.viewThree];
}

-(void)configurePageControl{
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = 3;
    self.pageControl.userInteractionEnabled = NO;
    [self.pageControl sizeToFit];
    
    [self.pageControl setPageIndicatorTintColor:[UIColor frescoLightTextColor]];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor frescoMediumTextColor]];
    
    NSInteger offset = 32;
    if (IS_IPHONE_5){
        offset = 24;
    }
    
    [self.pageControl centerHorizontallyInView:self.view];
    self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, self.view.frame.size.height - 44 - offset, self.pageControl.frame.size.width, self.pageControl.frame.size.height - 32);
    [self.view addSubview:self.pageControl];
}

-(void)configureLogo{
    self.logo =[[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 188/2, 36, 188, 65)];
    self.logo.image=[UIImage imageNamed:@"largeLogo"];
    [self.view addSubview:self.logo];
}

-(void)configureActionBar{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    [self.view addSubview:container];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoLightTextColor];
    [self.view addSubview:line];
    
//    UIButton *logIn = [[UIButton alloc] initWithFrame:CGRectMake(-5, 0, 85, 44)];
//    [logIn setTitle:@"SIGN UP" forState:UIControlStateNormal];
//    logIn.titleLabel.font = [UIFont notaBoldWithSize:15];
//    [logIn setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
//    [logIn addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
//    [container addSubview:logIn];
    
    UIButton *logIn = [UIButton buttonWithType:UIButtonTypeSystem];
    logIn.frame = CGRectMake(0, 0, 85, 44);
    [logIn setTitle:@"LOG IN" forState:UIControlStateNormal];
    logIn.titleLabel.font = [UIFont notaBoldWithSize:15];
    [logIn setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [logIn addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
    [logIn addTarget:self action:@selector(highlight:) forControlEvents:UIControlEventTouchDown];
    [logIn setTitleEdgeInsets:UIEdgeInsetsMake(-10, 20, -10, 20)];
    [container addSubview:logIn];
    
    UIButton *signUp = [UIButton buttonWithType:UIButtonTypeSystem];
    signUp.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 85, 0, 85, 44);
    [signUp setTitle:@"SIGN UP" forState:UIControlStateNormal];
    signUp.titleLabel.font = [UIFont notaBoldWithSize:15];
    [signUp setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [signUp addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:signUp];
    
    /* DEBUG */
//        signUp.backgroundColor = [UIColor greenColor];
//        logIn.backgroundColor = [UIColor redColor];
}

-(void)highlight:(UIButton *)sender {
}

-(void)configureParallax{
    [OEParallax createParallaxFromView:self.logo withMaxX:10 withMinX:-10 withMaxY:10 withMinY:-10];
}


#pragma mark - UIButton Actions

-(void)logIn {
    FRSLoginViewController *loginViewController = [[FRSLoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

-(void)signUp {
    FRSSignUpViewController *signUpViewController = [[FRSSignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}


#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    self.page = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    
    if (self.pageControl.currentPage == self.page) return;
    
    if (self.page == 0){
        [self.viewOne animate];
    } else if (self.page == 1){
        [self.viewOne reset];
    } else if (self.page == 2) {
        [self.viewThree animate];
    }
    
    self.pageControl.currentPage = self.page;
}















@end
