//
//  FRSTransparentAlertView.h
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
//  This is a semi-transparent alert view that is used in the CameraVC for the tips alerts.

#import "FRSAlertView.h"
#import "FRSCameraViewController.h"

@interface FRSTransparentAlertView : FRSAlertView


/**
 Creates a paginating FRSAlertView with a transparent background, to be used in the CameraVC.

 @param captureMode FRSCaptureMode used to determine which tips to present.
 @param tipIndex NSInteger index of the current tip.
 @return FRSTransparentAlertView
 */
- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode tipIndex:(NSInteger)tipIndex delegate:(id)delegate;

@end
