//
//  VideoTrimmerViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 4/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "VideoTrimmerViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"

@interface VideoTrimmerViewController ()

@property (strong, nonatomic) AVPlayer *player;

@end

@implementation VideoTrimmerViewController


#pragma mark - Lifecycle
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self shouldShowStatusBar:YES animated:NO];
}

#pragma mark - UI
-(void)configureUI {
    self.view.backgroundColor = [UIColor blackColor];

    [self configureTopContainer];
    [self configurePlayer];
}

-(void)configureTopContainer {
    UIView *topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.view addSubview:topContainer];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.view.frame.size.width, 19)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"TRIM VIDEO TO 1:00";
    titleLabel.font = [UIFont notaBoldWithSize:17];
    [topContainer addSubview:titleLabel];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(12, 30, 24, 24);
    dismissButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 0, 0);
    [dismissButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    [dismissButton setTintColor:[UIColor whiteColor]];
    [topContainer addSubview:dismissButton];
    
    /* DEBUG */
    //    topContainer.backgroundColor = [UIColor redColor];
    //    titleLabel.backgroundColor = [UIColor greenColor];
}

-(void)configurePlayer {
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"lalaunch" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    
    self.player = [[AVPlayer alloc] initWithURL:fileURL];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = CGRectMake(16, self.view.frame.size.height/2 - 100, self.view.frame.size.width - 32, 200);
    
    [self.view.layer addSublayer:playerLayer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
    
    
    [self.player play];
    
    /* DEBUG */
    playerLayer.backgroundColor = [UIColor greenColor].CGColor;
}


#pragma mark - Actions
-(void)tapped:(UITapGestureRecognizer *)sender {
    
    if (self.player.rate == 0) {
        [self.player play];
    }
    else {
        [self.player pause];
    }
}

-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//#pragma mark - Status Bar
//-(void)shouldShowStatusBar:(BOOL)statusBar animated:(BOOL)animated {
//    
//    UIWindow *statusBarApplicationWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
//    
//    int alpha;
//    if (statusBar) {
//        alpha = 1;
//    } else {
//        alpha = 0;
//    }
//    
//    if (animated) {
//        [UIView beginAnimations:@"fade-statusbar" context:nil];
//        [UIView setAnimationDuration:0.3];
//        statusBarApplicationWindow.alpha = alpha;
//        [UIView commitAnimations];
//    } else {
//        statusBarApplicationWindow.alpha = alpha;
//    }
//}

@end
