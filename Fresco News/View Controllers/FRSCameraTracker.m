//
//  FRSCameraTracker.m
//  Fresco
//
//  Created by Omar Elfanek on 5/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCameraTracker.h"

@implementation FRSCameraTracker

- (void)startTrackingMovement {
    self.motionManager = [[CMMotionManager alloc] init];
    
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 if (!error) {
                                                     [self outputAccelertionData:accelerometerData.acceleration];
                                                     
                                                 } else {
                                                     DDLogError(@"Motion Manager Error: %@", error);
                                                 }
                                             }];
    
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 2;
    }
    
    __block float lastZ = 0;
    __block float lastY = 0;
    
    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                withHandler:^(CMGyroData *_Nullable gyroData, NSError *_Nullable error) {
                                    CGFloat rotationRate = fabs(gyroData.rotationRate.x);
                                    if (rotationRate > .4) {
                                        [self alertUserOfFastPan:TRUE];
                                    }
                                    
                                    CGFloat wobbleRate = fabs(gyroData.rotationRate.z);
                                    if (lastZ == 0) {
                                        lastZ = wobbleRate;
                                    } else if (lastZ - wobbleRate < -.7) {
                                        [self alertUserOfWobble:YES];
                                    }
                                    
                                    CGFloat forwardWobble = fabs(gyroData.rotationRate.y);
                                    if (lastY == 0) {
                                        lastY = forwardWobble;
                                    } else if (lastY - forwardWobble < -1) {
                                        [self alertUserOfWobble:YES];
                                    }
                                    
                                }];
}

- (void)stopTrackingMovement {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
}


- (void)outputAccelertionData:(CMAcceleration)acceleration {
    
    UIDeviceOrientation orientationNew;
    
    if (self.parentController.isRecording)
        return;
    
    if (acceleration.z > -2 && acceleration.z < 2) {
        
        if (acceleration.x >= 0.75) {
            orientationNew = UIDeviceOrientationLandscapeRight;
            
        } else if (acceleration.x <= -0.75) {
            orientationNew = UIDeviceOrientationLandscapeLeft;
            
        } else if (acceleration.y <= -0.75) {
            orientationNew = UIDeviceOrientationPortrait;
            
        } else if (acceleration.y >= 0.75) {
            orientationNew = self.parentController.lastOrientation;
        } else {
            // Consider same as last time
            return;
        }
    }
    
    if (orientationNew == self.parentController.lastOrientation)
        return;
    
    self.parentController.lastOrientation = orientationNew;
    
    [self.parentController rotateAppForOrientation:orientationNew];
}

- (void)alertUserOfFastPan:(BOOL)isTooFast {
    
    [self showPan];
    
    if (wobble && [wobble isValid]) {
        [wobble invalidate];
    }
    
    wobble = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(hideAlert) userInfo:Nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:wobble forMode:NSDefaultRunLoopMode];
}

- (void)alertUserOfWobble:(BOOL)isTooFast {
    
    [self showWobble];
    
    if (wobble && [wobble isValid]) {
        [wobble invalidate];
    }
    
    wobble = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(hideAlert) userInfo:Nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:wobble forMode:NSDefaultRunLoopMode];
}

- (void)showPan {
    
    if (!hasPanned) {
        hasPanned = TRUE;
        [FRSTracker track:aggressivePan];
    }
    
    if (self.parentController.isRecording == FALSE) {
        return;
    }
    
    if (isShowingPan) {
        return;
    }
    
    isShowingPan = TRUE;
    
    panAlert = [[FRSWobbleView alloc] init];
    CGAffineTransform transform;
    
    if (self.parentController.lastOrientation == UIDeviceOrientationLandscapeLeft) {
        // 90 degrees
        double rads = DEGREES_TO_RADIANS(90);
        transform = CGAffineTransformRotate(panAlert.transform, rads);
        
        panAlert.transform = transform;
        
        CGRect shakeFrame = panAlert.frame;
        shakeFrame.origin.x += self.parentController.view.frame.size.width - (panAlert.frame.size.height / 2) - 33;
        shakeFrame.origin.y += 120;
        
        if (isShowingWobble) {
            shakeFrame.origin.x -= 50;
        }
        
        shakeFrame.origin.y = ((self.parentController.view.frame.size.height - shakeFrame.size.width) / 2) - 120 + (shakeFrame.size.width) + 25;
        panAlert.frame = shakeFrame;
        panAlert.alpha = 0;
        [self.parentController.view addSubview:panAlert];
        
        [UIView animateWithDuration:.3
                         animations:^{
                             panAlert.alpha = 1;
                         }];
        
        [self.parentController.view bringSubviewToFront:panAlert];
    } else if (self.parentController.lastOrientation == UIDeviceOrientationLandscapeRight) {
        double rads = DEGREES_TO_RADIANS(-90);
        transform = CGAffineTransformRotate(panAlert.transform, rads);
        panAlert.transform = transform;
        
        CGRect shakeFrame = panAlert.frame;
        shakeFrame.origin.x = 15;
        shakeFrame.origin.y += 120;
        
        if (isShowingWobble) {
            shakeFrame.origin.x += 50;
        }
        
        shakeFrame.origin.y = ((self.parentController.view.frame.size.height - shakeFrame.size.width) / 2) - 120 + (shakeFrame.size.width) + 25;
        panAlert.frame = shakeFrame;
        panAlert.alpha = 0;
        [self.parentController.view addSubview:panAlert];
        
        [UIView animateWithDuration:.3
                         animations:^{
                             panAlert.alpha = 1;
                         }];
        
        [self.parentController.view bringSubviewToFront:panAlert];
    }
}

- (void)showWobble {
    
    if (!hasShaken) {
        hasShaken = TRUE;
        [FRSTracker track:captureWobble];
    }
    
    if (self.parentController.isRecording == FALSE) {
        return;
    }
    
    if (isShowingWobble) {
        return;
    }
    
    isShowingWobble = TRUE;
    
    shakeAlert = [[FRSWobbleView alloc] init];
    [shakeAlert configureForWobble];
    CGAffineTransform transform;
    
    if (self.parentController.lastOrientation == UIDeviceOrientationLandscapeLeft) {
        // 90 degrees
        double rads = DEGREES_TO_RADIANS(90);
        transform = CGAffineTransformRotate(shakeAlert.transform, rads);
        
        shakeAlert.transform = transform;
        
        CGRect shakeFrame = shakeAlert.frame;
        shakeFrame.origin.x += self.parentController.view.frame.size.width - (shakeAlert.frame.size.height / 2) - 33;
        shakeFrame.origin.y += 120;
        
        if (isShowingPan) {
            shakeFrame.origin.x -= 50;
        }
        
        shakeFrame.origin.y = ((self.parentController.view.frame.size.height - shakeFrame.size.width) / 2) - 120;
        shakeAlert.frame = shakeFrame;
        shakeAlert.alpha = 0;
        [self.parentController.view addSubview:shakeAlert];
        
        [UIView animateWithDuration:.3
                         animations:^{
                             shakeAlert.alpha = 1;
                         }];
        
        [self.parentController.view bringSubviewToFront:shakeAlert];
    } else if (self.parentController.lastOrientation == UIDeviceOrientationLandscapeRight) {
        double rads = DEGREES_TO_RADIANS(-90);
        transform = CGAffineTransformRotate(shakeAlert.transform, rads);
        shakeAlert.transform = transform;
        
        CGRect shakeFrame = shakeAlert.frame;
        shakeFrame.origin.x = 15;
        shakeFrame.origin.y += 120;
        
        if (isShowingPan) {
            shakeFrame.origin.x += 50;
        }
        
        shakeFrame.origin.y = ((self.parentController.view.frame.size.height - shakeFrame.size.width) / 2) - 120;
        shakeAlert.frame = shakeFrame;
        shakeAlert.alpha = 0;
        [self.parentController.view addSubview:shakeAlert];
        
        [UIView animateWithDuration:.3
                         animations:^{
                             shakeAlert.alpha = 1;
                         }];
        
        [self.parentController.view bringSubviewToFront:shakeAlert];
    }
}

- (void)hideAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             shakeAlert.alpha = 0;
                             panAlert.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [shakeAlert removeFromSuperview];
                             [panAlert removeFromSuperview];
                             
                             shakeAlert = Nil;
                             panAlert = Nil;
                             isShowingWobble = FALSE;
                             isShowingPan = FALSE;
                         }];
    });
}


@end
