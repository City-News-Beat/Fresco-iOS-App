//
//  CameraPreviewView.m
//  FrescoNews
//
//  Created by Fresco News on 3/15/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "CameraPreviewView.h"
@import AVFoundation;

@implementation CameraPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return ((AVCaptureVideoPreviewLayer *)self.layer).session;
}

- (void)setSession:(AVCaptureSession *)session
{
    ((AVCaptureVideoPreviewLayer *)self.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    ((AVCaptureVideoPreviewLayer *)self.layer).session = session;
}

@end
