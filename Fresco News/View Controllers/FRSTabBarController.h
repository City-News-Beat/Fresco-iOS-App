//
//  FRSTabBarController.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FRSCameraViewController.h"

@interface FRSTabBarController : UITabBarController


@property (nonatomic) NSInteger lastActiveIndex;

- (void)returnToGalleryPost;

- (void)presentCameraForCaptureMode:(FRSCaptureMode)captureMode;

- (void)presentAssignments;

@end
