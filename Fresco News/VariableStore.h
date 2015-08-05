//
//  VariableStore.h
//  FrescoNews
//
//  Created by Fresco News on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

//FOUNDATION_EXPORT NSString * const kNotificationAPIKeyAvailable;

//FOUNDATION_EXPORT NSString * const kNotificationViewDismiss;

//FOUNDATION_EXPORT NSString * const kNotificationBadgeReset;

//FOUNDATION_EXPORT NSString * const kNotificationImageSet;

enum FRSErrorCodes {
    ErrorSignupDuplicateEmail = 101,
    ErrorSignupCantCreateUser,
    ErrorSignupCantSaveUser,
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

/*
** Colors
*/

@property UIColor *brandDarkColor;
@property UIColor *backgroundColor;

/*
** API
*/

@property NSString *baseUrl;
@property NSString *baseAPI;
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

//@property NSString * const kNotificationAPIKeyAvailable;

//@property NSString * const kNotificationViewDismiss;

@end
