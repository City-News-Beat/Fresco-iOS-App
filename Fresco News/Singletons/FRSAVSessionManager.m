//
//  FRSAVSessionManager.m
//  Fresco
//
//  Created by Daniel Sun on 11/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAVSessionManager.h"

@import AVFoundation;

@interface FRSAVSessionManager()

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
//@property (nonatomic, assign) BOOL capturingStilImage;

@end

@implementation FRSAVSessionManager

+(instancetype)defaultManager{
    static FRSAVSessionManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[FRSAVSessionManager alloc] init];
    });
    return _manager;
}

-(void)startImageCaptureSession{
    
}

@end
