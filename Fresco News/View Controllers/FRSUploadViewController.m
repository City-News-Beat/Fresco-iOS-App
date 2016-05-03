//
//  FRSUploadViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/3/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadViewController.h"

@interface FRSUploadViewController ()

@end

@implementation FRSUploadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}


#pragma mark - UI
-(void)configureUI {
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.navigationController.navigationBarHidden = YES;
    
    [self configureNavigationBar];
}

-(void)configureNavigationBar {

    /* Configure sudo navigationBar */
        // Used UIView instead of UINavigationBar for increased flexibility when animating
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navigationBar.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:navigationBar];
    
    /* Configure backButton */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(12, 30, 24, 24);
    [backButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:backButton];
    
    /* Configure squareButton */
    UIButton *squareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    squareButton.frame = CGRectMake(navigationBar.frame.size.width-12-24, 30, 24, 24);
    [squareButton setImage:[UIImage imageNamed:@"square"] forState:UIControlStateNormal];
    [squareButton setTintColor:[UIColor whiteColor]];
    [squareButton addTarget:self action:@selector(square) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:squareButton];
    
    /* Configure titleLabel */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -66/2, 35, 66, 19)];
    [titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [titleLabel setText:@"GALLERY"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [navigationBar addSubview:titleLabel];
    
    /* Height for scrollView */
    int height;
    if (IS_IPHONE_5) {
        height = 240;
    } else if (IS_IPHONE_6) {
        height = 280;
    } else if (IS_IPHONE_6_PLUS) {
        height = 310;
    }
    
    /* Configure scrollView */
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, height)];
    scrollView.backgroundColor = [UIColor redColor];
    scrollView.alpha = 0.1;
    [navigationBar addSubview:scrollView];
    
    /* Configure bottom container */
    UIView *bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -44, self.view.frame.size.width, 44)];
    bottomContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:bottomContainer];

    UIView *bottomContainerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    bottomContainerLine.backgroundColor = [UIColor frescoShadowColor];
    [bottomContainer addSubview:bottomContainerLine];
    
    
    /* Configure bottom bar */
        //Configure Twitter post button
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitterButton addTarget:self action:@selector(postToTwitter) forControlEvents:UIControlEventTouchDown];
    UIImage *twitter = [[UIImage imageNamed:@"twitter-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [twitterButton setImage:twitter forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(16, 10, 24, 24);
    [bottomContainer addSubview:twitterButton];
    
        //Configure Facebook post button
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitterButton addTarget:self action:@selector(postToFacebook) forControlEvents:UIControlEventTouchDown];
    UIImage *facebook = [[UIImage imageNamed:@"facebook-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [facebookButton setImage:facebook forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(56, 10, 24, 24);
    [bottomContainer addSubview:facebookButton];
    
        //Configure anonymous posting button
    UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [anonymousButton addTarget:self action:@selector(postAnonymously) forControlEvents:UIControlEventTouchDown];
    UIImage *eye = [[UIImage imageNamed:@"eye-26"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [anonymousButton setImage:eye forState:UIControlStateNormal];
    anonymousButton.frame = CGRectMake(96, 10, 24, 24);
    [bottomContainer addSubview:anonymousButton];
    
        //Configure next button
//    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [nextButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
//    [nextButton setTintColor:[UIColor frescoLightTextColor]];
//    nextButton.frame = CGRectMake(self.view.frame.size.width-64, 0, 60, 40);
//    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
//    [nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
//    nextButton.userInteractionEnabled = NO;
//    [bottomContainer addSubview:nextButton];
    
    //^ SHOULD BE SEND BUTTON
}


#pragma mark - Actions

/* Navigation bar*/
    //Back button action
-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

    //Square button action
-(void)square {
    
}

/* Bottom Bar */
    //Post to Facebook
-(void)postToFacebook {
    
}

    //Post to Twitter
-(void)postToTwitter {
    
}

    //Post Anonymously
-(void)postAnonymously {
    
}






    /* TODO */
    //  Pull selected photos/videos from FRSFileViewController.m
    //  Post to social toggles, should save options from previous view controller
            //Ideally would segue similarly to Onboard -> Login, while keeping tab at the bototm and sliding nav bar up
    // Anonymous posting (?)
    // Nav bar show/hide on scroll










@end