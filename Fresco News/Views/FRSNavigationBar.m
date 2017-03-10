//
//  FRSNavigationBar.m
//  Fresco
//
//  Created by Philip Bernstein on 6/1/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSNavigationBar.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "FRSAppDelegate.h"

@interface FRSNavigationBar ()

@property (nonatomic, retain) UIView *progressView;
@property (nonatomic, retain) UIView *failureView;
@property (nonatomic, retain) NSDate *lastAnimated;

@end

@implementation FRSNavigationBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {

    CGRect navFrame = self.frame;
    navFrame.origin.y -= 20;
    navFrame.size.height += 20;
    navFrame.size.width = 0;
    _progressView = [[UIView alloc] initWithFrame:navFrame];
    _progressView.backgroundColor = [UIColor colorWithRed:1.00 green:0.71 blue:0.00 alpha:1.0];

    [self addSubview:_progressView];
    [self sendSubviewToBack:_progressView];

    [[NSNotificationCenter defaultCenter] addObserverForName:FRSUploadNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self handleUploadNotificaiton:notification.userInfo];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:FRSDismissUpload
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [UIView animateWithDuration:.2
                                                                           animations:^{
                                                                               [_failureView removeFromSuperview];
                                                                           }];
                                                          
                                                          CGRect navFrame = self.frame;
                                                          navFrame.origin.y -= 20;
                                                          navFrame.size.height += 20;
                                                          navFrame.size.width = 0;
                                                          
                                                          _progressView.frame = navFrame;
                                                      });
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:FRSRetryUpload
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [UIView animateWithDuration:.2
                                                                           animations:^{
                                                                               [_failureView removeFromSuperview];
                                                                           }];
                                                          
                                                          CGRect navFrame = self.frame;
                                                          navFrame.origin.y -= 20;
                                                          navFrame.size.height += 20;
                                                          navFrame.size.width = 0;
                                                          
                                                          _progressView.frame = navFrame;
                                                      });
                                                  }];

}


/**
 Handles regular upload notification based on type passed in the info dictionary

 @param notificationInfo NSDictionary of the notification's user info
 */
- (void)handleUploadNotificaiton:(NSDictionary *)notificationInfo {
    if ([notificationInfo[@"type"] isEqualToString:@"progress"]) {
        NSNumber *uploadPercentage = notificationInfo[@"percentage"];
        float percentage = [uploadPercentage floatValue];
        
        if (CGRectIsNull(self.frame) || isnan(percentage)) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect navFrame = self.frame;
            navFrame.origin.y = -20;
            navFrame.size.height += 20;
            navFrame.size.width = self.frame.size.width * percentage;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // [UIView animateWithDuration:.05 animations:^{
                [self sendSubviewToBack:_progressView];
                _progressView.frame = navFrame;
                // }];
            });
        });
        
        _lastAnimated = [NSDate date];
    } else if ([notificationInfo[@"type"] isEqualToString:@"completion"]) {
        
        CGRect navFrame = self.frame;
        navFrame.origin.y = -20;
        navFrame.size.height += 20;
        navFrame.size.width = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.2
                             animations:^{
                                 _progressView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 _progressView.frame = navFrame;
                                 _progressView.alpha = 1;
                             }];
        });
    } else if ([notificationInfo[@"type"] isEqualToString:@"failure"]) {
        NSLog(@"handleUploadNotificaiton");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect navFrame = self.frame;
            navFrame.origin.y -= 20;
            navFrame.size.height += 20;
            navFrame.size.width = 0;
            [self showFailureView];
            
            _progressView.frame = navFrame;
            _progressView.alpha = 1;
            
            //Present error to user if needed
            if([notificationInfo[@"error"] isKindOfClass:[NSError class]]){
                NSError *uploadError = (NSError *) notificationInfo[@"error"];
                [((FRSAppDelegate *)[[UIApplication sharedApplication] delegate]) presentError:uploadError withTitle:@"Upload error"];
            }
        });
    }
}



/**
 Presents failure view in navigation bar
 */
- (void)showFailureView {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!_failureView) {
          _failureView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.frame.size.width, self.frame.size.height + 20)];
          _failureView.backgroundColor = [UIColor frescoRedColor];

          UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_failureView.frame.size.width / 2 - 115 / 2, 35, 115, 19)];
          label.text = @"UPLOAD FAILED";
          label.textColor = [UIColor whiteColor];
          label.textAlignment = NSTextAlignmentCenter;
          [label setFont:[UIFont notaBoldWithSize:17]];
          [_failureView addSubview:label];

          UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
          [dismissButton addTarget:self action:@selector(dismissFailureView) forControlEvents:UIControlEventTouchUpInside];
          dismissButton.frame = CGRectMake(12, 30, 24, 24);
          [dismissButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
          dismissButton.tintColor = [UIColor whiteColor];
          [_failureView addSubview:dismissButton];

          UIButton *retryUploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
          [retryUploadButton addTarget:self action:@selector(retryUpload) forControlEvents:UIControlEventTouchUpInside];
          retryUploadButton.frame = CGRectMake(_failureView.frame.size.width - 24 - 10, 30, 24, 24);
          [retryUploadButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
          retryUploadButton.tintColor = [UIColor whiteColor];
          [_failureView addSubview:retryUploadButton];
      }

      [self addSubview:_failureView];
      [self bringSubviewToFront:_failureView];

      CGRect navFrame = self.frame;
      navFrame.origin.y = -20;
      navFrame.size.height += 20;
      navFrame.size.width = 0;

      _progressView.frame = navFrame;
    });
}


/**
 Dimisses upload and cancels
 */
- (void)dismissFailureView {
    [FRSTracker track:uploadCancel];
    [[NSNotificationCenter defaultCenter] postNotificationName:FRSDismissUpload object:nil userInfo:@{ @"type" : @"dismiss" }];

    [UIView animateWithDuration:.2
                     animations:^{
                       [_failureView removeFromSuperview];
                     }];
}


/**
 Triggers an upload retry
 */
- (void)retryUpload {
    [FRSTracker track:uploadRetry];
    [[NSNotificationCenter defaultCenter] postNotificationName:FRSRetryUpload object:nil userInfo:@{ @"type" : @"retry" }];

    [UIView animateWithDuration:.2
                     animations:^{
                       [_failureView removeFromSuperview];
                     }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

@end
