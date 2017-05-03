//
//  FRSCameraViewController.h
//  Fresco
//
//  Created by Daniel Sun on 11/13/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFileLoader.h"
#import "FRSFileViewController.h"
#import "FRSWobbleView.h"
#import "FRSLocator.h"

typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModeInterview,
    FRSCaptureModePan,
    FRSCaptureModeWide,
    FRSCaptureModeVideo,
    FRSCaptureModePhoto,
    
};

@interface FRSCameraViewController : FRSBaseViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {

    NSDate *entry;
    NSDate *exit;

}

@property (nonatomic) FRSCaptureMode captureMode;

@property (nonatomic, retain) FRSFileLoader *fileLoader;

@property (nonatomic, retain) NSDictionary *preselectedGlobalAssignment;
@property (nonatomic, retain) NSDictionary *preselectedAssignment;

- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode;
- (instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode selectedAssignment:(NSDictionary *)assignment selectedGlobalAssignment:(NSDictionary *)globalAssignment;

- (void)dismissAndReturnToPreviousTab;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) UIDeviceOrientation lastOrientation;

- (void)rotateAppForOrientation:(UIDeviceOrientation)o; // TODO: Abstract orientation into it's own class.

@end
