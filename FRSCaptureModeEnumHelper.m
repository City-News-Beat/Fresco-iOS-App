//
//  FRSCaptureModeEnumHelper.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCaptureModeEnumHelper.h"

@implementation FRSCaptureModeEnumHelper

+ (NSString *)standardDisplayNameForCaptureMode:(FRSCaptureMode)captureMode {
    NSString *displayStr = nil;

    switch (captureMode) {
        case FRSCaptureModeVideoInterview:
            displayStr = FRSCaptureModeVideoInterview_StandardDisplayName;
            break;
        case FRSCaptureModeVideoPan:
            displayStr = FRSCaptureModeVideoPan_StandardDisplayName;
            break;
        case FRSCaptureModeVideoWide:
            displayStr = FRSCaptureModeVideoWide_StandardDisplayName;
            break;
        case FRSCaptureModeVideo:
            displayStr = FRSCaptureModeVideo_StandardDisplayName;
            break;
        case FRSCaptureModePhoto:
            displayStr = FRSCaptureModePhoto_StandardDisplayName;
            break;
        case FRSCaptureModeOther:
            displayStr = FRSCaptureModeOther_StandardDisplayName;
            break;
            
        default:
            break;
    }
    
    return displayStr;
}

+ (NSString *)rawValueForCaptureMode:(FRSCaptureMode)captureMode {
    NSString *rawValue = nil;
    
    switch (captureMode) {
        case FRSCaptureModeVideoInterview:
            rawValue = FRSCaptureModeVideoInterview_RawValue;
            break;
        case FRSCaptureModeVideoPan:
            rawValue = FRSCaptureModeVideoPan_RawValue;
            break;
        case FRSCaptureModeVideoWide:
            rawValue = FRSCaptureModeVideoWide_RawValue;
            break;
        case FRSCaptureModeVideo:
            rawValue = FRSCaptureModeVideo_RawValue;
            break;
        case FRSCaptureModePhoto:
            rawValue = FRSCaptureModePhoto_RawValue;
            break;
        case FRSCaptureModeOther:
            
        default:
            rawValue = FRSCaptureModeOther_RawValue;
            break;
    }
    
    return rawValue;
}

+ (FRSCaptureMode)captureModeForStandardDisplayName:(NSString *)standardDisplayName {
    FRSCaptureMode captureMode = FRSCaptureModeOther;
    
    if([standardDisplayName isEqualToString:FRSCaptureModeVideoInterview_StandardDisplayName]) {
        captureMode = FRSCaptureModeVideoInterview;
    }
    else if([standardDisplayName isEqualToString:FRSCaptureModeVideoPan_StandardDisplayName]) {
        captureMode = FRSCaptureModeVideoPan;
    }
    else if([standardDisplayName isEqualToString:FRSCaptureModeVideoWide_StandardDisplayName]) {
        captureMode = FRSCaptureModeVideoWide;
    }
    else if([standardDisplayName isEqualToString:FRSCaptureModeVideo_StandardDisplayName]) {
        captureMode = FRSCaptureModeVideo;
    }
    else if([standardDisplayName isEqualToString:FRSCaptureModePhoto_StandardDisplayName]) {
        captureMode = FRSCaptureModePhoto;
    }
    else if([standardDisplayName isEqualToString:FRSCaptureModeOther_StandardDisplayName]) {
        captureMode = FRSCaptureModeOther;
    }
    
    return captureMode;
}

+ (FRSCaptureMode)captureModeForRawValue:(NSString *)rawValue {
    FRSCaptureMode captureMode = FRSCaptureModeOther;
    
    if([rawValue isEqualToString:FRSCaptureModeVideoInterview_RawValue]) {
        captureMode = FRSCaptureModeVideoInterview;
    }
    else if([rawValue isEqualToString:FRSCaptureModeVideoPan_RawValue]) {
        captureMode = FRSCaptureModeVideoPan;
    }
    else if([rawValue isEqualToString:FRSCaptureModeVideoWide_RawValue]) {
        captureMode = FRSCaptureModeVideoWide;
    }
    else if([rawValue isEqualToString:FRSCaptureModeVideo_RawValue]) {
        captureMode = FRSCaptureModeVideo;
    }
    else if([rawValue isEqualToString:FRSCaptureModePhoto_RawValue]) {
        captureMode = FRSCaptureModePhoto;
    }
    else if([rawValue isEqualToString:FRSCaptureModeOther_RawValue]) {
        captureMode = FRSCaptureModeOther;
    }

    return captureMode;
}

@end
