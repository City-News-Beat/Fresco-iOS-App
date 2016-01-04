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

@interface FRSOnboardingViewController () <UIScrollViewDelegate, FRSContentActionsBarDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) UIPageControl *pageControl;



@end

@implementation FRSOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureUI];
    
    
    
    // Do any additional setup after loading the view.
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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.953 green:0.953 blue:0.933 alpha:1.00];
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 295)];
//    self.scrollView.backgroundColor = [UIColor colorWithRed:0.953 green:0.953 blue:0.933 alpha:1.00];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    [self.view addSubview:self.scrollView];
    
}

-(void)configureOnboardingViews{
    
    NSInteger offset = (self.scrollView.frame.size.width - 320)/2;
    
    FRSOnboardOneView *viewOne = [[FRSOnboardOneView alloc] initWithOrigin:CGPointMake(offset, 0)];
    [self.scrollView addSubview:viewOne];
    
    FRSOnboardTwoView *viewTwo = [[FRSOnboardTwoView alloc] initWithOrigin:CGPointMake(self.view.frame.size.width + offset, 0)];
    [self.scrollView addSubview:viewTwo];
    
    FRSOnboardThreeView *viewThree = [[FRSOnboardThreeView alloc] initWithOrigin:CGPointMake(self.view.frame.size.width * 2 + offset, 0)];
    [self.scrollView addSubview:viewThree];
}

-(void)configurePageControl{
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = 3;
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
    
    UIImageView *logo =[[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 188/2, 36, 188, 65)];
    logo.image=[UIImage imageNamed:@"largeLogo"];
    [self.view addSubview:logo];

}

-(void)configureActionBar{

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    [self.view addSubview:container];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoLightTextColor];
    [self.view addSubview:line];
    
    
    UIButton *logIn = [UIButton buttonWithType:UIButtonTypeSystem];
    logIn.frame = CGRectMake(-5, 0, 85, 44);
    [logIn setTitle:@"LOG IN" forState:UIControlStateNormal];
    logIn.titleLabel.font = [UIFont notaBoldWithSize:15];
    [logIn setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [logIn addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
    logIn.backgroundColor = [UIColor redColor];
    [container addSubview:logIn];
    
    UIButton *signUp = [UIButton buttonWithType:UIButtonTypeSystem];
    signUp.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 85, 0, 85, 44);
    [signUp setTitle:@"SIGN UP" forState:UIControlStateNormal];
    signUp.titleLabel.font = [UIFont notaBoldWithSize:15];
    [signUp setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [signUp addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    signUp.backgroundColor = [UIColor greenColor];
    [container addSubview:signUp];
    
}

#pragma mark - UIButton Actions

-(void)logIn{
    //Gets called but does not always fade the titleLabel
    NSLog(@"logIn");
}

-(void)signUp{
    NSLog(@"signUp");
}



#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
