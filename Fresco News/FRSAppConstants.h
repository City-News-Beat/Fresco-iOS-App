//
//  FRSAppConstants.h
//  Fresco
//
//  Created by Nicolas Rizk on 8/3/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+Additions.h"
#import "VariableStore.h"
#import "FRSAlertViewManager.h"

#define NOTIFICATION_API_KEY_AVAILABLE      @"NotificationAPIKeyAvailable"
#define NOTIFICATION_VIEW_DISMISS           @"DismissNotificationsView"
#define NOTIFICATION_BADGE_RESET            @"ResetNotificationBadge"

#define ERROR_DOMAIN                        @"com.fresconews";


#pragma mark - Keys Plist

#define KEYS_PLIST_PATH                [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]
#define KEYS_DICTIONARY                [NSDictionary dictionaryWithContentsOfFile:KEYS_PLIST_PATH]

#pragma mark - Production - Parse

#define PRODUCTION_PARSE_APP_ID        [KEYS_DICTIONARY objectForKey:@"ProductionParseAppID"]
#define PRODUCTION_PARSE_CLIENT_KEY    [KEYS_DICTIONARY objectForKey:@"ProductionParseClientKey"]


#pragma mark - Staging - Parse

#define STAGING_PARSE_APP_ID           [KEYS_DICTIONARY objectForKey:@"StagingParseAppID"]
#define STAGING_PARSE_CLIENT_KEY       [KEYS_DICTIONARY objectForKey:@"StagingParseClientKey"]


#pragma mark - Production - Base URL/API

#define PRODUCTION_BASE_URL            @"https://beta.fresconews.com"
#define PRODUCTION_BASE_API            @"https://api.fresconews.com/v1/"
#define BASE_PATH                      @"";


#pragma mark - Staging - Base URL/API

#define STAGING_BASE_URL               @"https://staging.web.fresconews.com"
#define STAGING_BASE_API               @"http://staging.fresconews.com/v1/"


#pragma mark - Twitter Auth

#define TWITTER_CONSUMER_KEY           [KEYS_DICTIONARY objectForKey:@"TwitterConsumerKey"]
#define TWITTER_CONSUMER_SECRET        [KEYS_DICTIONARY objectForKey:@"TwitterConsumerSecret"]


#pragma mark - CDN

#define CDN_BASE_URL                   @"http://res.cloudinary.com/fresco-news/image/fetch"
#define CDN_FACEBOOK_URL               @"http://res.cloudinary.com/fresco-news/image/facebook"


#pragma mark - Float/Int Values

#define MAX_VIDEO_LENGTH               60.0f
#define MAX_ASSET_AGE                  -3600 * 6
#define LOCATION_UPDATE_INTERVAL       60


#pragma mark - User Defaults

#define UD_CAPTION_STRING_IN_PROGRESS  @"captionStringInProgress"
#define UD_DEFAULT_ASSIGNMENT_ID       @"defaultAssignmentID"
#define UD_SELECTED_ASSETS             @"selectedAssets"
#define UD_NOTIFICATIONS_COUNT         @"notificationsCount"


#pragma mark - Fonts

#define HELVETICA_NEUE_MEDIUM          @"HelveticaNeue-Medium"
#define HELVETICA_NEUE_LIGHT           @"HelveticaNeue-Light"
#define HELVETICA_NEUE_THIN            @"HelveticaNeue-Thin"
#define HELVETICA_NEUE_REGULAR         @"HelveticaNeue-Regular"


#pragma mark - MapView Identifiers

#define ASSIGNMENT_IDENTIFIER          @"AssignmentAnnotation"
#define CLUSTER_IDENTIFIER             @"ClusterAnnotation"
#define USER_IDENTIFIER                @"currentLocation"


#pragma mark - Notification Categories/Actions

#define ASSIGNMENT_CATEGORY @"ASSIGNMENT_CATEGORY"
#define NAVIGATE_IDENTIFIER @"NAVIGATE_IDENTIFIER"

#pragma mark - User-facing Strings

#define NAVIGATE_STR                   NSLocalizedString(@"Navigate", nil)


#pragma mark - Device Macros


#define IS_OS_8_OR_LATER          ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_5               (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_STANDARD_IPHONE_6      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)

#define IS_ZOOMED_IPHONE_6        (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)

#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS   (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)



























