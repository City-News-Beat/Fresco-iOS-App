//
//  FRSCaptureModeEnumHelper.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSCameraConstants.h"

/*
 FRSCaptureModeVideoInterview,
 FRSCaptureModeVideoPan,
 FRSCaptureModeVideoWide,
 FRSCaptureModeVideo,
 FRSCaptureModePhoto,
 FRSCaptureModeOther,
 
 */

//Standard Display Name
static NSString *FRSCaptureModeVideoInterview_StandardDisplayName = @"Interview";
static NSString *FRSCaptureModeVideoPan_StandardDisplayName = @"Steady Pan";
static NSString *FRSCaptureModeVideoWide_StandardDisplayName = @"Wide Shot";
static NSString *FRSCaptureModeVideo_StandardDisplayName = @"Video";
static NSString *FRSCaptureModePhoto_StandardDisplayName = @"Photo";
static NSString *FRSCaptureModeOther_StandardDisplayName = @"Other";

//Raw Value
static NSString *FRSCaptureModeVideoInterview_RawValue = @"INTERVIEW";
static NSString *FRSCaptureModeVideoPan_RawValue = @"PAN";
static NSString *FRSCaptureModeVideoWide_RawValue = @"WIDE";
static NSString *FRSCaptureModeVideo_RawValue = @"VIDEO";
static NSString *FRSCaptureModePhoto_RawValue = @"PHOTO";
static NSString *FRSCaptureModeOther_RawValue = @"OTHER";

@interface FRSCaptureModeEnumHelper : NSObject

+ (NSString *)standardDisplayNameForCaptureMode:(FRSCaptureMode)captureMode;
+ (NSString *)rawValueForCaptureMode:(FRSCaptureMode)captureMode;

+ (FRSCaptureMode)captureModeForStandardDisplayName:(NSString *)standardDisplayName;
+ (FRSCaptureMode)captureModeForRawValue:(NSString *)rawValue;

@end
