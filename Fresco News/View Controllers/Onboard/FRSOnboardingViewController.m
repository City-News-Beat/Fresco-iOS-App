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
    
    FRSContentActionsBar *bar = [[FRSContentActionsBar alloc] initWithOrigin:(CGPointMake(0, 400)) delegate:self];
    [self.view addSubview:bar];
        
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 288)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.953 green:0.953 blue:0.933 alpha:1.00];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
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
    self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, self.view.frame.size.height - 44 - offset, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
    [self.view addSubview:self.pageControl];
    
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
