//
//  CameraPreviewView.h
//  FrescoNews
//
//  Created by Fresco News on 3/15/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class AVCaptureSession;

@interface CameraPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@property (nonatomic, assign) CGRect savedBounds;

@end
