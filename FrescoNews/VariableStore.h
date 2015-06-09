//
//  VariableStore.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

@interface VariableStore : NSObject
+ (VariableStore *)sharedInstance;
+ (NSString *)endpointForPath:(NSString *)endpoint;

// colors
@property NSString *colorBrandDark;
@property NSString *colorBrandPrimary;
@property NSString *colorBrandLight;

@property NSString *colorAssignment;
@property NSString *colorAlertRed;
@property NSString *colorPhotoUse;
@property NSString *colorBackground;

@property NSString *colorStoryBreaksBackground;

@property CGFloat opacityDarkText;
@property CGFloat opacityLightText;
@property CGFloat opacityOuterListDividers;
@property CGFloat opacityInnerListDividers;
@property CGFloat opacityUnreadNotificationHighlights;

@property NSString *baseURL;
@property NSString *basePath;
@property NSString *cdnBaseURL;

@end