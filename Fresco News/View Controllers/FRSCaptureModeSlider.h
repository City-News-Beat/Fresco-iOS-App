//
//  FRSCaptureModeSlider.h
//  Fresco
//
//  Created by Omar Elfanek on 4/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSCameraConstants.h"

#define CAPTURE_MODE_COUNT 5
#define SLIDER_WIDTH 500

@protocol FRSCaptureModeSliderDelegate <NSObject>

- (void)captureModeDidUpdate:(FRSCaptureMode)captureMode;

@end

@interface FRSCaptureModeSlider : UIView

@property (weak, nonatomic) NSObject<FRSCaptureModeSliderDelegate> *delegate;


- (instancetype)initWithFrame:(CGRect)frame captureMode:(FRSCaptureMode)captureMode;

/**
 Handle left swipes passed in from the implementing view controller.
 */
- (void)swipeLeft;

/**
 Handle right swipes passed in from the implementing view controller.
 */
- (void)swipeRight;

/**
 This method sets the capture mode and updates the UI accordingly.

 @param captureMode FRSCaptureMode that will be used to update the interface.
 */
- (void)setCaptureMode:(FRSCaptureMode)captureMode;

@property NSInteger currentIndex;

- (void)hideNewFeaturesForABTesting;

@end
