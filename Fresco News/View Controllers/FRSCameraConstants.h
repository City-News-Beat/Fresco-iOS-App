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
typedef NS_ENUM(NSUInteger, FRSCaptureMode) {
    FRSCaptureModeVideoInterview,
    FRSCaptureModeVideoPan,
    FRSCaptureModeVideoWide,
    FRSCaptureModeVideo,
    FRSCaptureModePhoto,
    
};
