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
#import "FRSTabBarController.h"

#import "OEParallax.h"

@interface FRSOnboardingViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) FRSOnboardThreeView *viewThree;
@property (strong, nonatomic) FRSOnboardOneView *viewOne;
@property (strong, nonatomic) UIView *actionBarContainer;
@property (strong, nonatomic) UIButton *logInButton;
@property (strong, nonatomic) UIView *mainContainer; //Animating view on intro

@property NSInteger page;

@end

@implementation FRSOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureParallax];
    
    [self animateFirstLaunch];
    
    
    //TODO
    //Make delegate
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateIn)
                                                 name:@"returnToOnboard"
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UI Configuration

-(NSString *)titleForActionButton{
    return @"READ MORE";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)configureUI{
    
    self.mainContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    self.mainContainer.backgroundColor = [UIColor redColor];
    
    [self configureScrollView];
    [self configureOnboardingViews];
    [self configurePageControl];
    [self configureLogo];
    [self configureActionBar];
    [self configureDismissButton];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
}

-(void)configureDismissButton {
    //Placeholder,
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(12, 30, 24, 24);
    [self.closeButton setImage:[UIImage imageNamed:@"close-dark"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.alpha = 0;
    [self.view addSubview:self.closeButton];
}

-(void)configureScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delaysContentTouches = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.alpha = 0;
    [self.view addSubview:self.scrollView];
}

-(void)configureOnboardingViews {
    NSInteger offset = (self.scrollView.frame.size.width - 320)/2;
    
    self.viewOne = [[FRSOnboardOneView alloc] initWithOrigin:CGPointMake(offset, 0)];

    [self.scrollView addSubview:self.viewOne];
    
    FRSOnboardTwoView *viewTwo = [[FRSOnboardTwoView alloc] initWithOrigin:CGPointMake(self.view.frame.size.width + offset, 0)];
    [self.scrollView addSubview:viewTwo];
    
    self.viewThree = [[FRSOnboardThreeView alloc] initWithOrigin:CGPointMake(self.view.frame.size.width * 2 + offset, 0)];
    [self.scrollView addSubview:self.viewThree];
}

-(void)configurePageControl {
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = 3;
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.alpha = 0;
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

-(void)configureLogo {
    self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 188/2, 36, 188, 65)];
    self.logo.image =[UIImage imageNamed:@"largeLogo"];
    self.logo.alpha = 0;
    [self.view addSubview:self.logo];
}

-(void)configureActionBar {
    self.actionBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    [self.view addSubview:self.actionBarContainer];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoLightTextColor];
    [self.actionBarContainer addSubview:line];

    self.logInButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logInButton.frame = CGRectMake(0, 0, 85, 44);
    [self.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    self.logInButton.titleLabel.font = [UIFont notaBoldWithSize:15];
    [self.logInButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [self.logInButton addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
    [self.logInButton setTitleEdgeInsets:UIEdgeInsetsMake(-10, 20, -10, 20)];
    [self.actionBarContainer addSubview:self.logInButton];
    
    UIButton *signUp = [UIButton buttonWithType:UIButtonTypeSystem];
    signUp.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 85, 0, 85, 44);
    [signUp setTitle:@"SIGN UP" forState:UIControlStateNormal];
    signUp.titleLabel.font = [UIFont notaBoldWithSize:15];
    [signUp setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [signUp addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    [self.actionBarContainer addSubview:signUp];
    
    /* DEBUG */
//        signUp.backgroundColor = [UIColor greenColor];
//        logIn.backgroundColor = [UIColor redColor];
}

-(void)configureParallax {
//    [OEParallax createParallaxFromView:self.logo withMaxX:10 withMinX:-10 withMaxY:10 withMinY:-10];
}


#pragma mark - UIButton Actions

-(void)logIn {

    [self animateOut];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        FRSLoginViewController *loginViewController = [[FRSLoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewController animated:NO];
    });
}

-(void)signUp {
    FRSSignUpViewController *signUpViewController = [[FRSSignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

-(void)dismiss {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
    [translate setFromValue:[NSNumber numberWithFloat:self.view.center.y]];
    [translate setToValue:[NSNumber numberWithFloat:self.view.center.y +50]];
    [translate setDuration:0.6];
    [translate setRemovedOnCompletion:NO];
    [translate setFillMode:kCAFillModeForwards];
    [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
    [[self.view layer] addAnimation:translate forKey:@"translate"];
    
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {

    }];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

}

#pragma mark - Transition Animations

-(void)animateFirstLaunch {

    //REF
    //https://material-design.storage.googleapis.com/publish/material_v_8/material_ext_publish/0B14F_FSUCc01Znc0RmE0Ni0taFU/CreationChoreo_06_NewDialogueDo_v2.mp4

    self.actionBarContainer.transform = CGAffineTransformMakeTranslation(0, 44);
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionBarContainer.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
    
    [self animateMaterialIntroOnPageControl:self.pageControl delay:0.1];
    [self animateMaterialIntroOnScrollView:self.scrollView delay:0.2];
    [self animateMaterialIntroOnImageView:self.logo delay:0.3];
    
    [UIView animateWithDuration:1.0 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.closeButton.alpha = 1;
    } completion:nil];
    
    [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:0.25];
}

-(void)showStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)animateMaterialIntroOnPageControl:(UIPageControl *)pageControl delay:(CGFloat)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
        [translate setFromValue:[NSNumber numberWithFloat:pageControl.center.y +50]];
        [translate setToValue:[NSNumber numberWithFloat:pageControl.center.y]];
        [translate setDuration:0.6];
        [translate setRemovedOnCompletion:NO];
        [translate setFillMode:kCAFillModeForwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[pageControl layer] addAnimation:translate forKey:@"translate"];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:0.9]];
        [scale setToValue:[NSNumber numberWithFloat:1.0]];
        [scale setDuration:0.25];
        [scale setRemovedOnCompletion:NO];
        [scale setFillMode:kCAFillModeBackwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[pageControl layer] addAnimation:scale forKey:@"scale"];
        
        pageControl.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            pageControl.alpha = 1;
        } completion:nil];
    });
}

-(void)animateMaterialIntroOnScrollView:(UIScrollView *)scrollView delay:(CGFloat)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
        [translate setFromValue:[NSNumber numberWithFloat:scrollView.center.y +50]];
        [translate setToValue:[NSNumber numberWithFloat:scrollView.center.y]];
        [translate setDuration:0.6];
        [translate setRemovedOnCompletion:NO];
        [translate setFillMode:kCAFillModeForwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[scrollView layer] addAnimation:translate forKey:@"translate"];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:0.9]];
        [scale setToValue:[NSNumber numberWithFloat:1.0]];
        [scale setDuration:0.25];
        [scale setRemovedOnCompletion:NO];
        [scale setFillMode:kCAFillModeBackwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[scrollView layer] addAnimation:scale forKey:@"scale"];
        
        scrollView.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            scrollView.alpha = 1;
        } completion:nil];
    });
}

-(void)animateMaterialIntroOnImageView:(UIImageView *)imageView delay:(CGFloat)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
        [translate setFromValue:[NSNumber numberWithFloat:imageView.center.y +50]];
        [translate setToValue:[NSNumber numberWithFloat:imageView.center.y]];
        [translate setDuration:0.6];
        [translate setRemovedOnCompletion:NO];
        [translate setFillMode:kCAFillModeForwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[imageView layer] addAnimation:translate forKey:@"translate"];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:0.9]];
        [scale setToValue:[NSNumber numberWithFloat:1.0]];
        [scale setDuration:0.25];
        [scale setRemovedOnCompletion:NO];
        [scale setFillMode:kCAFillModeBackwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[imageView layer] addAnimation:scale forKey:@"scale"];
        
        imageView.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            imageView.alpha = 1;
        } completion:nil];
    });
}


-(void)animateOut {
    
    /* TOTAL ANIMATION DURATION [  1.0  ] */

    
    /* Animate scrollView xPos */
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.transform = CGAffineTransformMakeTranslation(5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.transform = CGAffineTransformMakeTranslation(-90, 0);
        } completion:nil];
    }];
    
    /* Animate scrollView alpha */
    [UIView animateWithDuration:0.6 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.alpha = 0;
    } completion:nil];
    

    /* Animate pageControl xPos */
    [UIView animateWithDuration:0.2 delay:0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pageControl.transform = CGAffineTransformMakeTranslation(2.5, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.pageControl.transform = CGAffineTransformMakeTranslation(-70, 0);
        } completion:nil];
    }];
    
    /* Animate pageControl alpha */
    [UIView animateWithDuration:0.5 delay:0.3 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pageControl.alpha = 0;
    } completion:nil];
    
    
    /* Animate actionBar xPos and alpha */
    [UIView animateWithDuration:0.4 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.actionBarContainer.transform = CGAffineTransformMakeTranslation(0, 50);
        self.actionBarContainer.alpha = 0;
        
    } completion:nil];
}


-(void)prepareForAnimation {
    
    self.logInButton.enabled = NO;
    
    self.scrollView.transform = CGAffineTransformMakeTranslation(-50, 0);
    self.scrollView.alpha = 0;

    self.pageControl.transform = CGAffineTransformMakeTranslation(-50, 0);
    self.pageControl.alpha = 0;
    
    self.actionBarContainer.transform = CGAffineTransformMakeTranslation(0, 50);
    self.actionBarContainer.alpha = 0;
    
}

-(void)animateIn {
    
    [self prepareForAnimation];
    
    /* TOTAL ANIMATION DURATION [  1.0  ] */
    
    
    /* Animate scrollView xPos */
    [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.transform = CGAffineTransformMakeTranslation(2.5, 0);

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.transform = CGAffineTransformMakeTranslation(0, 0);

        } completion:nil];
    }];
    
    /* Animate scrollView alpha */
    [UIView animateWithDuration:0.7 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.alpha = 1;
    } completion:nil];
    
    
    /* Animate pageControl xPos */
    [UIView animateWithDuration:0.6 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pageControl.transform = CGAffineTransformMakeTranslation(2.5, 0);
        self.pageControl.alpha = 1;

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.pageControl.transform = CGAffineTransformMakeTranslation(0, 0);

        } completion:nil];
    }];
    
    /* Animate actionBar xPos and alpha */
    [UIView animateWithDuration:0.5 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.actionBarContainer.transform = CGAffineTransformMakeTranslation(0, 0);
        self.actionBarContainer.alpha = 1;
        
    } completion:^(BOOL finished) {
        self.logInButton.enabled = YES;
    }];
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
