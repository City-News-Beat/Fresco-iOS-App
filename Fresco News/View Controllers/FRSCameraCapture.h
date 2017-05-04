//
//  FRSCameraCapture.h
//  Fresco
//
//  Created by Omar Elfanek on 5/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSAVSessionManager.h"
#import "FRSAPIClient.h"

@protocol FRSCameraCaptureDelegate <NSObject>

- (void)didCaptureStillImage;

@end


@interface FRSCameraCapture : NSObject

- (instancetype)initWithDelegate:(id)delegate;

@property (weak, nonatomic) NSObject<FRSCameraCaptureDelegate> *delegate;

- (void)captureStillImageWithSessionManager:(FRSAVSessionManager *)sessionManager completion:(FRSAPIDefaultCompletionBlock)completion;


@end
