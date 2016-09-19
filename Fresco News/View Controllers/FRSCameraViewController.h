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
#import "UIImage+Pixels.h"

typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModePhoto,
    FRSCaptureModeVideo
};

@interface FRSCameraViewController : FRSBaseViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    float beginGestureScale;
    float effectiveScale;
    NSTimer *thumb;
    NSTimer *wobble;
    NSTimer *pan;
    UILabel *title;
    
    NSDate *entry;
    NSDate *exit;
}

@property (nonatomic) BOOL isPresented;

@property (nonatomic) FRSCaptureMode captureMode;

@property (nonatomic, retain) FRSFileLoader *fileLoader;

@property (nonatomic, retain) NSDictionary *preselectedGlobalAssignment;
@property (nonatomic, retain) NSDictionary *preselectedAssignment;

-(instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode;
-(instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode selectedAssignment:(NSDictionary *)assignment selectedGlobalAssignment:(NSDictionary *)globalAssignment;

-(void)handlePreviewButtonTapped;
-(void)toggleCaptureMode;


- (void)dismissAndReturnToPreviousTab;


@end
