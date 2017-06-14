//
//  FRSFileTagManager.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSCameraConstants.h"
#import <Photos/Photos.h>

@interface FRSFileTagManager : NSObject

+ (FRSFileTagManager *)sharedInstance;

- (void)saveCaptureMode:(FRSCaptureMode)captureMode forAsset:(PHAsset *)asset;
- (FRSCaptureMode)fetchCaptureModeForAsset:(PHAsset *)asset;
    

@end
