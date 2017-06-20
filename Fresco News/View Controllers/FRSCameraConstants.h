//
//  FRSCameraConstants.h
//  Fresco
//
//  Created by Omar Elfanek on 5/8/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
//  This class houses all constants used in the camera view controller,
//  and camera related classes.

#import <Foundation/Foundation.h>

/**
 This enum is used across the app when tagging and setting camera types.

 - FRSCaptureModeVideoInterview: Interview capture mode
 - FRSCaptureModeVideoPan: Pan capture mode
 - FRSCaptureModeVideoWide: Wide shot capture mode
 - FRSCaptureModeVideo: Regular video capture mode
 - FRSCaptureModePhoto: Photo capture mode
 */


typedef NS_ENUM(NSInteger, FRSCaptureMode) {
    FRSCaptureModeVideoInterview = 0,
    FRSCaptureModeVideoPan,
    FRSCaptureModeVideoWide,
    FRSCaptureModeVideo,
    FRSCaptureModePhoto,
    FRSCaptureModeOther,
    FRSCaptureModeInvalid = -1,
};

typedef NS_ENUM(NSUInteger, FRSTagViewMode) {
    FRSTagViewModeNewTag,
    FRSTagViewModeEditTag,
};

typedef NS_ENUM(NSUInteger, FRSPackageProgressLevel) {
    FRSPackageProgressLevelZero = 0,
    FRSPackageProgressLevelOne,
    FRSPackageProgressLevelTwo,
    FRSPackageProgressLevelThree,
};
