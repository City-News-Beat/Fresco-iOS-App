//
//  FRSCameraCapture.h
//  Fresco
//
//  Created by Omar Elfanek on 5/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
//  This class should handle all capturing for the camera.
//  Currently it only handles photo capturing, with video capturing in the FRSCameraViewController waiting to be abstracted.


#import <Foundation/Foundation.h>
#import "FRSAVSessionManager.h"
#import "FRSAPIClient.h"

@protocol FRSCameraCaptureDelegate <NSObject>

/**
 Delegate method used to detect when a still image has been captured.
 */
- (void)didCaptureStillImage;

@end


@interface FRSCameraCapture : NSObject

- (instancetype)initWithDelegate:(id)delegate;
@property (weak, nonatomic) NSObject<FRSCameraCaptureDelegate> *delegate;


/**
 Captures a photo with the given session manager.

 @param sessionManager FRSAVSessionManager
 @param completion FRSAPIDefaultCompletionBlock
 */
- (void)captureStillImageWithSessionManager:(FRSAVSessionManager *)sessionManager completion:(FRSAPIDefaultCompletionBlock)completion;


@end
