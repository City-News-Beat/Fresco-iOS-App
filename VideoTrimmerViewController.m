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
    [self configureTrimmer];
}

-(void)configureTrimmer {
    trimmer = [[FRSTrimTool alloc] initWithFrame:CGRectMake(5, [UIScreen mainScreen].bounds.size.height-70, [UIScreen mainScreen].bounds.size.width-10, 60)];
    trimmer.delegate = self;
    [self.view addSubview:trimmer];
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

-(void)trimmingWillBegin {
    
}

-(void)trimmingDidEnd {
    [self.player play];
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

-(void)trimmersDidAdjust {
    float videoDuration = CMTimeGetSeconds(self.player.currentItem.duration);
    
    float startTime = trimmer.left * videoDuration;
    float endTime = trimmer.right * videoDuration;
    
    NSLog(@"%f", startTime);
    [self.player pause];
    
    int32_t timeScale = self.player.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(startTime, timeScale);
    if (CMTIME_IS_INVALID(time))
        return;
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

@end
