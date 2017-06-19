//
//  FRSCameraTracker.h
//  Fresco
//
//  Created by Omar Elfanek on 5/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
//  This class handles all gyroscope and accelerometer actions, such as showing the wobble and pan alerts.

#import <UIKit/UIKit.h>
#import "FRSAVSessionManager.h"
@import CoreMotion;

@interface FRSCameraTracker : NSObject {
    
    float beginGestureScale;
    float effectiveScale;
    NSTimer *thumb;
    NSTimer *wobble;
    NSTimer *pan;
    UILabel *title;
    
    FRSWobbleView *panAlert;
    FRSWobbleView *shakeAlert;
    
    BOOL isShowingWobble;
    BOOL isShowingPan;
    
    BOOL hasShaken;
    BOOL hasPanned;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) FRSAVSessionManager *sessionManager;
@property (strong, nonatomic) FRSCameraViewController *parentController;

- (void)startTrackingMovement;
- (void)stopTrackingMovement;

@end
