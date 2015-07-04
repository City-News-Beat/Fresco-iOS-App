//
//  VariableStore.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

//NSError *frsError = [NSError errorWithDomain:@"com.fresconews" code:101 userInfo:@{@"msg" : @"Couldn't get FRSUser from server"}];

enum FRSErrorCodes {
    ErrorSignupDuplicateEmail = 101,
    ErrorSignupCantCreateUser,
    ErrorSignupCantGetUser,
    ErrorSignupNoUserOnServer,
    ErrorSignupNoUserFromParseUser,
} frsErrorCodes;

@interface VariableStore : NSObject
+ (VariableStore *)sharedInstance;
+ (NSString *)endpointForPath:(NSString *)endpoint;
+ (void)resetDraftGalleryPost;

// errors
@property NSString *errorDomain;

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
@property NSString *cdnFacebookBaseURL;
@property NSString *parseAppId;
@property NSString *parseClientKey;
@property NSString *twitterConsumerKey;
@property NSString *twitterConsumerSecret;

@property CGFloat maximumVideoLength;
@property NSInteger maximumAssetAge;
@property NSInteger locationUpdateInterval;

@end
