//
//  TabBarController.h
//  FrescoNews
//
//  Created by Fresco News on 3/13/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
#import "FRSUploadManager.h"
#import "FRSCameraViewController.h"

@interface FRSTabBarController : UITabBarController  <UITabBarDelegate, UITabBarControllerDelegate, UIAlertViewDelegate,FRSUploadManagerDelegate>

- (void)returnToGalleryPost;

- (void)presentCameraForCaptureMode:(FRSCaptureMode)captureMode;

- (void)presentAssignments;

@end
