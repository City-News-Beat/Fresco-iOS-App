//
//  FRSMotionManager.m
//  Fresco
//
//  Created by Fresco News on 9/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSMotionManager.h"

@implementation FRSMotionManager

+ (FRSMotionManager *)sharedManager {
    
    static FRSMotionManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[FRSMotionManager alloc] init];
    });
    
    return manager;
}

- (void)startTrackingMovement {
    
    self.accelerometerUpdateInterval = .2;
    self.gyroUpdateInterval = .2;
    
    [[FRSMotionManager sharedManager] startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                            if (!error) {
                                                [self outputAccelertionData:accelerometerData.acceleration];
                                                
                                            } else {
                                                NSLog(@"%@", error);
                                            }
                                        }];
}


- (void)outputAccelertionData:(CMAcceleration)acceleration {
    
    UIInterfaceOrientation orientationNew;
        
    if (acceleration.z > -2 && acceleration.z < 2) {
        
        if (acceleration.x >= 0.75) {
            orientationNew = UIInterfaceOrientationLandscapeLeft;
            
        
        } else if (acceleration.x <= -0.75) {
            orientationNew = UIInterfaceOrientationLandscapeRight;
            
        } else if (acceleration.y <= -0.75) {
            orientationNew = UIInterfaceOrientationPortrait;
            
            
        } else if (acceleration.y >= 0.75) {
            orientationNew = UIInterfaceOrientationPortraitUpsideDown;
            
            
        } else if (acceleration.z < -0.85) {
            orientationNew = UIInterfaceOrientationLandscapeRight;
            
        }
        else {
            // Consider same as last time
            return;
        }
    }
    
//    NSLog(@"X: %f", acceleration.x);
//    NSLog(@"Y: %f", acceleration.y);
//    NSLog(@"Z: %f", acceleration.z);
    
    if (orientationNew == self.lastOrientation)
        return;
    
    self.lastOrientation = orientationNew;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORIENTATION_CHANGE object:nil];

}

-(void)stopTrackingMovement {
    [self stopAccelerometerUpdates];
}

@end
