//
//  FRSAVSessionManager.h
//  Fresco
//
//  Created by Daniel Sun on 11/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;


typedef NS_ENUM(NSUInteger, FRSAVAuthStatus) {
    FRSAVStatusAuthorized,
    FRSAVStatusDenied,
    FRSAVStatusNotDetermined
};

@interface FRSAVSessionManager : NSObject

@property (nonatomic) FRSAVAuthStatus authStatus;

@property (nonatomic, readonly) BOOL AVSetupSuccess;

@property (strong, nonatomic) AVCaptureSession *session;

@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.

@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

+(instancetype)defaultManager;

-(void)startCaptureSessionAndRun:(BOOL)run;

-(void)clearCaptureSession;

-(void)configureOrientationForPreview:(UIView *)preview;

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange;


@end
