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

typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModePhoto,
    FRSCaptureModeVideo
};

//<<<<<<< HEAD
@interface FRSCameraViewController : FRSBaseViewController
{
    float beginGestureScale;
    float effectiveScale;
}
//=======
//@interface FRSCameraViewController : FRSBaseViewController

//>>>>>>> 3.0-omar
@property (nonatomic) BOOL isPresented;

@property (nonatomic) FRSCaptureMode captureMode;

@property (nonatomic, retain) FRSFileLoader *fileLoader;

-(instancetype)initWithCaptureMode:(FRSCaptureMode)captureMode;

-(void)handlePreviewButtonTapped;
-(void)toggleCaptureMode;


- (void)dismissAndReturnToPreviousTab;


@end
