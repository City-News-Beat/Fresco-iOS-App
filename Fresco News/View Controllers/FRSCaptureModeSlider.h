//
//  FRSCaptureModeSlider.h
//  Fresco
//
//  Created by Omar Elfanek on 4/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSCameraViewController.h"
#define CAPTURE_MODE_COUNT 5

@interface FRSCaptureModeSlider : UIView

- (instancetype)initWithFrame:(CGRect)frame captureMode:(FRSCaptureMode)captureMode;
- (void)swipeLeft;
- (void)swipeRight;
   
@end
