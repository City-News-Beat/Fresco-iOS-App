//
//  FRSCameraViewController.h
//  Fresco
//
//  Created by Daniel Sun on 11/13/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModePhoto,
    FRSCaptureModeVideo
};

@interface FRSCameraViewController : UIViewController

@property (nonatomic) BOOL isPresented;

@property (nonatomic) FRSCaptureMode captureMode;


-(instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode;

-(void)handlePreviewButtonTapped;
-(void)toggleCaptureMode;


- (void)dismissAndReturnToPreviousTab;


@end
