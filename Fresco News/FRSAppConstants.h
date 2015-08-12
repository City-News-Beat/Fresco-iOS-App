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
#define NOTIFICATION_IMAGE_SET              @"UserImageSet"

#define ERROR_DOMAIN                        @"com.fresconews"


#pragma mark - Keys Plist

#define KEYS_PLIST_PATH                     [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]
#define KEYS_DICTIONARY                     [NSDictionary dictionaryWithContentsOfFile:KEYS_PLIST_PATH]

#pragma mark - Production - Parse

#define PRODUCTION_PARSE_APP_ID             [KEYS_DICTIONARY objectForKey:@"ProductionParseAppID"]
#define PRODUCTION_PARSE_CLIENT_KEY         [KEYS_DICTIONARY objectForKey:@"ProductionParseClientKey"]


#pragma mark - Staging - Parse

#define STAGING_PARSE_APP_ID                [KEYS_DICTIONARY objectForKey:@"StagingParseAppID"]
#define STAGING_PARSE_CLIENT_KEY            [KEYS_DICTIONARY objectForKey:@"StagingParseClientKey"]


#pragma mark - Production - Base URL/API

#define PRODUCTION_BASE_URL                 @"https://beta.fresconews.com"
#define PRODUCTION_BASE_API                 @"https://api.fresconews.com/v1/"
#define BASE_PATH                           @""


#pragma mark - Staging - Base URL/API


#define STAGING_BASE_URL                    @"https://staging.web.fresconews.com"
#define STAGING_BASE_API                    @"http://staging.fresconews.com/v1/"


#pragma mark - Twitter Auth

#define TWITTER_CONSUMER_KEY                [KEYS_DICTIONARY objectForKey:@"TwitterConsumerKey"]
#define TWITTER_CONSUMER_SECRET             [KEYS_DICTIONARY objectForKey:@"TwitterConsumerSecret"]
#define TWITTER_USERS_SHOW_URL              @"https://api.twitter.com/1.1/users/show.json?"
#define TWITTER_VERIFY_URL                  @"https://api.twitter.com/1.1/account/verify_credentials.json"


#pragma mark - CDN

#define CDN_BASE_URL                        @"http://res.cloudinary.com/fresco-news/image/fetch"
#define CDN_FACEBOOK_URL                    @"http://res.cloudinary.com/fresco-news/image/facebook"


#pragma mark - Float/Int Values

#define MAX_VIDEO_LENGTH                    60.0f
#define MAX_ASSET_AGE                       -3600 * 6
#define LOCATION_UPDATE_INTERVAL            60


#pragma mark - User Defaults

#define UD_CAPTION_STRING_IN_PROGRESS       @"captionStringInProgress"
#define UD_DEFAULT_ASSIGNMENT_ID            @"defaultAssignmentID"
#define UD_SELECTED_ASSETS                  @"selectedAssets"
#define UD_NOTIFICATIONS_COUNT              @"notificationsCount"
#define UD_PREVIOUSLY_SELECTED_TAB          @"previouslySelectedTab"
#define UD_HAS_LAUNCHED_BEFORE              @"hasLaunchedBefore"
#define UD_ASSIGNMENTS_ONBOARDING           @"assignmentsOnboarding"
#define UD_UPDATE_PROFILE_HEADER            @"updateProfileHeader"

#pragma mark - Fonts

#define HELVETICA_NEUE_MEDIUM               @"HelveticaNeue-Medium"
#define HELVETICA_NEUE_LIGHT                @"HelveticaNeue-Light"
#define HELVETICA_NEUE_THIN                 @"HelveticaNeue-Thin"
#define HELVETICA_NEUE_REGULAR              @"HelveticaNeue-Regular"


#pragma mark - MapView Identifiers

#define ASSIGNMENT_IDENTIFIER               @"AssignmentAnnotation"
#define CLUSTER_IDENTIFIER                  @"ClusterAnnotation"
#define USER_IDENTIFIER                     @"currentLocation"


#pragma mark - Segue Identifiers

#define SEG_SHOW_ACCT_INFO                  @"showAccountInfo"
#define SEG_REPLACE_WITH_SIGNUP             @"replaceWithSignUp"
#define SEG_SHOW_PERSONAL_INFO              @"showPersonalInfo"
#define SEG_SHOW_PERMISSIONS                @"showPermissions"
#define SEG_SHOW_RADIUS                     @"showRadius"
#define SEG_SETTINGS                        @"settingsSegue"

#pragma mark - Notification Categories/Actions

#define ASSIGNMENT_CATEGORY                 @"ASSIGNMENT_CATEGORY"
#define NAVIGATE_IDENTIFIER                 @"NAVIGATE_IDENTIFIER"

#pragma mark - User-facing Strings

#define FRESCO                              @"Fresco" // Not localizing name i.e. would be Fresh in Spanish
#define FACEBOOK                            @"Facebook"
#define TWITTER                             @"Twitter"
#define FB_LOGOUT_PROMPT                    NSLocalizedString(@"It seems like you logged in through Facebook. If you disconnect it, this would disable your account entirely!", nil)

#define OK                                  NSLocalizedString(@"OK", nil)
#define DISMISS                             NSLocalizedString(@"Dismiss", nil)
#define DISABLE                             NSLocalizedString(@"Disable", nil)
#define CANCEL                              NSLocalizedString(@"Cancel", nil)
#define ERROR                               NSLocalizedString(@"Error", nil)
#define DONE                                NSLocalizedString(@"Done", nil)
#define NEXT                                NSLocalizedString(@"Next", nil)
#define STR_TRY_AGAIN                       NSLocalizedString(@"Try Again", nil)
#define OFF                                 NSLocalizedString(@"Off", nil)
#define WARNING                             NSLocalizedString(@"Warning", nil)
#define WHATS_HAPPENING                     NSLocalizedString(@"What's happening?", nil)

#define LOGIN                               NSLocalizedString(@"Login", nil)
#define LOGIN_ERROR                         NSLocalizedString(@"Login Error", nil)
#define LOGIN_PROMPT                        NSLocalizedString(@"Please enter a valid email and password", nil)
#define NAME_PROMPT                         NSLocalizedString(@"Please enter both first and last name", nil)
#define AVATAR_PROMPT                       NSLocalizedString(@"Choose a new avatar", nil)
#define NOTIF_RADIUS_ERROR_MSG              NSLocalizedString(@"Could not save notification radius", nil)
#define T_O_S_UNAVAILABLE_MSG               NSLocalizedString(@"Terms of Service not available", nil)
#define DISABLE_ACCT_TITLE                  NSLocalizedString(@"Are you sure? You can recover your account up to one year from today.", nil)

#define PROFILE_SAVE_ERROR                  NSLocalizedString(@"Could not save Profile settings", nil)
#define DISABLE_ACCT_ERROR                  NSLocalizedString(@"It seems we couldn't successfully disable your account. Please contact support@fresconews.com for help.", nil)
#define PASSWORD_ERROR_TITLE                NSLocalizedString(@"Passwords do not match", nil)
#define PASSWORD_ERROR_MESSAGE              NSLocalizedString(@"Please make sure your new passwords are equals", nil)

#define INVALID_CREDENTIALS                 NSLocalizedString(@"Invalid Credentials", nil)
#define TWITTER_ERROR                       NSLocalizedString(@"We ran into an error signing you in with Twitter", nil)

#define GO_TO_SETTINGS                      NSLocalizedString(@"Go to Settings", nil)
#define NAVIGATE_STR                        NSLocalizedString(@"Navigate", nil)
#define NAVIGATE_TO_ASSIGNMENT              NSLocalizedString(@"Navigate to the assignment", nil)
#define ENABLE_CAMERA_TITLE                 NSLocalizedString(@"Enable Camera", nil)
#define ENABLE_CAMERA_MSG                   NSLocalizedString(@"needs permission to access the camera to continue.", nil)

#define CAMERA_ENABLED                      NSLocalizedString(@"Camera Enabled", nil)
#define CAMERA_DISABLED                     NSLocalizedString(@"Camera Disabled", nil)

#define LOC_ENABLED                         NSLocalizedString(@"Location Enabled", nil)
#define LOC_DISABLED                        NSLocalizedString(@"Location Disabled", nil)

#define NOTIF_PENDING                       NSLocalizedString(@"Notifications Pending", nil)
#define NOTIF_ENABLED                       NSLocalizedString(@"Notifications Enabled", nil)

#define OPEN_IN_MAPS                        NSLocalizedString(@"Open in Maps", nil)
#define OPEN_IN_GOOG_MAPS                   NSLocalizedString(@"Open in Google Maps", nil)

#define NOTHING_HERE_YET                    NSLocalizedString(@"Nothing here yet!", nil)
#define OPEN_CAMERA                         NSLocalizedString(@"Open your camera to get started", nil)

#define MAIN_HEADER_1                       NSLocalizedString(@"Find breaking news around you", nil)
#define MAIN_HEADER_2                       NSLocalizedString(@"Submit your photos and videos", nil)
#define MAIN_HEADER_3                       NSLocalizedString(@"See your work in the news", nil)

#define SUB_HEADER_1                        NSLocalizedString(@"Keep an eye out, or use Fresco to view a map of nearby events being covered by news outlets", nil)
#define SUB_HEADER_2                        NSLocalizedString(@"Your media is visible not only to Fresco users, but to our news organization partners in need of visual coverage", nil)
#define SUB_HEADER_3                        NSLocalizedString(@"We notify you when your photos and videos are used, and you'll get paid if you took them for an assignment", nil)

#define HIGHLIGHTS                          NSLocalizedString(@"Highlights", nil)
#define STORIES                             NSLocalizedString(@"Stories", nil)

#define VIEW                                NSLocalizedString(@"View", nil)
#define VIEW_ASSIGNMENT                     NSLocalizedString(@"View Assignment", nil)
#define ASSIGNMENT_EXPIRED_TITLE            NSLocalizedString(@"Assignment Expired", nil)
#define ASSIGNMENT_EXPIRED_MSG              NSLocalizedString(@"This assignment has expired already!", nil)

#define GALLERY_UNAVAILABLE_TITLE           NSLocalizedString(@"Gallery Unavailable", nil)
#define GALLERY_UNAVAILABLE_MSG             NSLocalizedString(@"We couldn't find this gallery!", nil)


#pragma mark - Device Macros


#define IS_OS_8_OR_LATER                    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD                             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE                           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4S                       (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height < 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_IPHONE_5                         (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_STANDARD_IPHONE_6                (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)

#define IS_ZOOMED_IPHONE_6                  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)

#define IS_STANDARD_IPHONE_6_PLUS           (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS             (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)
