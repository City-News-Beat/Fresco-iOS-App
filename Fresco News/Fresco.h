//
//  Fresco.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h" // Network
#import "FRSGallery+CoreDataProperties.h"
//#import "markdown_lib.h"
//#import "markdown_peg.h"
#import "FRSAPIClient.h" // imports all extension classes needed (location, persistence, social, upload)
#import "FRSStripe.h"

//libraries
#import <AFNetworking/AFNetworking.h>

// #define distribution TRUE // disable logging
#ifdef distribution 
#define NSLog //
#endif


// image CDN sizing
static NSString * const thumbImageSize = @"150x";
static NSString * const smallImageSize = @"320x";
static NSString * const mediumImageSize = @"600x";
static NSString * const largeImageSize = @""; // actual image

// notifications
static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";

// api - constants
static BOOL const developmentEnvironment = FALSE; // both of these effect the base url (dev takes priority)
static BOOL const stagingEnvironment = FALSE;

// authorization constants
static NSString * const clientAuthorization = @"MTMzNzp0aGlzaXNhc2VjcmV0";
static NSString * const testBearerToken = @"gyOubJIiNaGkLn2BPPO9MIespXhBcp8WQlamDNMmEucedLwAxVovHaa1B55xQuz9eOgPE74M8BgcC3lslwHPidye4eTexKYyvKMeTLkwxQb2EGkvH8LAPVGEo2ZqdGlDsaI2gALhNbt8ZM45pk7gHECc0qj6MjRAATf2c943grQQuL6akUCCQqN7McYoQE";
static NSString * const serviceName = @"frescoNewsService3";

// base URLS
static NSString * const baseURL = @"https://api.dev.fresconews.com/v2/";
static NSString * const stagingURL = @"https://staging.api.fresconews.com/v1/";
static NSString * const developmentURL = @"https://dev.api.fresconews.com/v1/";

// content endpoints
static NSString * const storiesEndpoint = @"story/recent";
static NSString * const highlightsEndpoint = @"gallery/highlights";
static NSString * const assignmentsEndpoint = @"assignment/find";
static NSString * const storyGalleriesEndpoint = @"story/";

// location endpoints
static NSString * const locationEndpoint = @"user/location"; // send location
static NSString * const dualLocationEndpoint = @"user/locationcall";  // send location & get nearby assignments
static NSString * const acceptAssignmentEndpoint = @"assignment/accept";
// sign in / sign up (authorization) methods
static NSString * const loginEndpoint = @"auth/signin";
static NSString * const signUpEndpoint = @"auth/register";
static NSString * const socialLoginEndpoint = @"auth/signin/social";

// user endpoints
static NSString * const userEndpoint = @"user/";
static NSString * const updateUserEndpoint = @"user/update";
static NSString * const authenticatedUserEndpoint = @"user/me";
static NSString * const addSocialEndpoint = @"social/connect/";

// gallery creation
static NSString * const createGalleryEndpoint = @"gallery/create";

// formatted endpoints
static NSString * const likeGalleryEndpoint = @"gallery/%@/like";
static NSString * const repostGalleryEndpoint = @"gallery/%@/repost";
static NSString * const likeStoryEndpoint = @"story/%@/like";
static NSString * const repostStoryEndpoint = @"story/%@/repost";
static NSString * const followUserEndpoint = @"user/%@/follow";
static NSString * const unfollowUserEndpoint = @"user/%@/unfollow";

// quick actions -- app delegate
static NSString * const assignmentsAction = @"FRSAssignmentsAction";
static NSString * const takeVideoAction = @"FRSVideoAction";
static NSString * const takePhotoAction = @"FRSPhotoAction";

// object types
static NSString * const postObjectType = @"post";
static NSString * const galleryObjectType = @"gallery";
static NSString * const storyObjectType = @"story";

// legacy user defaults
static NSString * const previouslySelectedTabKey = @"previouslySelectedTab";

#define FRBASEURL (developmentEnvironment) ? developmentURL : (stagingEnvironment) ? stagingURL : baseURL

// user - data
static NSInteger const maxUsernameChars = 20;
static NSInteger const maxNameChars = 40;
static NSInteger const maxLocationChars = 40;
static NSInteger const maxBioChars = 160;
static NSString * const validUsernameChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";

// map + location
static float const maxRadius = 50.0; // miles
static int const userTrackingDelay = 10;
static float const metersInAMile = 1609.34;
static float const degreesInAMile = 69.0; // this is really only true with latutide, no idea how

//gallery
static NSInteger const maxDescriptionChars = 1500;
static NSInteger const maxGalleryItems = 10;
static float const maxVideoDuration = 60.0;

// story
static NSInteger const maxStoryTitleChar = 60;
static NSInteger const maxStoryDescriptionChar = 1500;

// social
static NSInteger const maxCommentChar = 200;

// assets
static int const maxVideoLength = 60.0; // in seconds, triggers trim
static int const maxVideoAge = 86400; // seconds in a day
static int const maxAssetCount = 8;

// UI
static NSString * const loadingCellIdentifier = @"LoadingMoreCell";
static NSString * const highlightCellIdentifier = @"HighlightCell";
static NSString * const storyCellIdentifier = @"StoryCell";
static NSString * const settingsCellIdentifier = @"SettingsCell";
static NSString * const galleryCellIdentifier = @"gallery-cell";

// callbacks / blocks
typedef void (^StoryImageBlock)(NSInteger storyImageIndex);
typedef void (^ShareSheetBlock)(NSArray *sharedContent);
typedef void (^ActionButtonBlock)();
typedef void (^TransferPercentage)(float percentage);
typedef void(^FRSAPIResponseBlock)(id responseObject, NSError *error);
typedef void(^FRSDataResponseBlock)(NSData *data, NSError *error);
typedef void(^FRSAPISuccessBlock)(BOOL sucess, NSError *error);
typedef void(^FRSAPIArrayResponseBlock)(NSArray *responseObject, NSError *error);

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]

#define ImageWithData(data)[UIImage imageWithData:data]

/*  NotificationCenter Strings */

#pragma mark - NotificationCenter Strings

#define NOTIF_API_KEY_AVAILABLE             @"NotificationAPIKeyAvailable"
#define NOTIF_VIEW_DISMISS                  @"DismissNotificationsView"
#define NOTIF_BADGE_RESET                   @"ResetNotificationBadge"
#define NOTIF_IMAGE_SET                     @"UserProfileImageChanged"
#define NOTIF_REACHABILITY_MONITORING       @"ReachabilityManagerIsMonitoring"
#define NOTIF_ONBOARD                       @"Onboard"
#define NOTIF_UPDATED_TOS                   @"UpdatedTOS"
#define NOTIF_ORIENTATION_CHANGE            @"OrientationChanged"
#define NOTIF_GALLERY_HEADER_UPDATE         @"UpdateGalleryHeader"
#define NOTIF_UPLOAD_FAILURE                @"UploadFailed"
#define NOTIF_UPLOAD_PROGRESS               @"UploadProgress"
#define NOTIF_UPLOAD_COMPLETE               @"UploadComplete"
#define NOTIF_GALLERY_ASSET_CHANGE          @"GalleryAssetsChanged"

#define NOTIF_LOCATIONS_UPDATE              @"DidUpdateLocations"

/* Fonts */

#pragma mark - Fonts

#define HELVETICA_NEUE_MEDIUM               @"HelveticaNeue-Medium"
#define HELVETICA_NEUE_LIGHT                @"HelveticaNeue-Light"
#define HELVETICA_NEUE_THIN                 @"HelveticaNeue-Thin"
#define HELVETICA_NEUE_REGULAR              @"HelveticaNeue"


/* Segue Identifiers */

#pragma mark - Segue Identifiers

#define SEG_SHOW_ACCT_INFO                  @"showAccountInfo"
#define SEG_REPLACE_WITH_SIGNUP             @"replaceWithSignUp"
#define SEG_SIGNUP_REPLACE_WITH_TOS         @"signup_replaceWithTOS"
#define SEG_SHOW_PERMISSIONS                @"showPermissions"
#define SEG_SHOW_RADIUS                     @"showRadius"
#define SEG_SETTINGS                        @"settingsSegue"
#define SEG_PRESENT_TOS                     @"presentTOS"



/* Notification Categories/Actions */

#pragma mark - Notification Categories/Actions

#define ASSIGNMENT_CATEGORY                 @"ASSIGNMENT_CATEGORY"
#define NAVIGATE_IDENTIFIER                 @"NAVIGATE_IDENTIFIER"

#define NOTIF_BREAKING                      @"breaking"
#define NOTIF_ASSIGNMENT                    @"assignment"
#define NOTIF_USE                           @"use"
#define NOTIF_STORY                         @"story"
#define NOTIF_LIST                          @"list"


/* User-facing Strings */

#pragma mark - User-facing Strings



/* Brand Names / Trademarks */

#pragma mark - Brand Names / Trademarks

#define FRESCO                              @"Fresco" // Not localizing name i.e. would be Fresh in Spanish
#define FACEBOOK                            @"Facebook"
#define TWITTER                             @"Twitter"



/* Global */

#pragma mark - Global Macros

#define OK                                  NSLocalizedString(@"OK", nil)
#define DISMISS                             NSLocalizedString(@"Dismiss", nil)
#define DISABLE                             NSLocalizedString(@"Disable", nil)
#define CANCEL                              NSLocalizedString(@"Cancel", nil)
#define ERROR                               NSLocalizedString(@"Error", nil)
#define SUCCESS                             NSLocalizedString(@"Success", nil)
#define DONE                                NSLocalizedString(@"Done", nil)
#define NEXT                                NSLocalizedString(@"Next", nil)
#define STR_TRY_AGAIN                       NSLocalizedString(@"Try Again", nil)
#define OFF                                 NSLocalizedString(@"Off", nil)
#define WARNING                             NSLocalizedString(@"Warning", nil)
#define WHATS_HAPPENING                     NSLocalizedString(@"What's happening?", nil)



/* First Run Log in / Sign up */

#pragma mark - First Run Log in / Sign up

#define LOGIN                               NSLocalizedString(@"Login", nil)
#define LOGIN_ERROR                         NSLocalizedString(@"Login Error", nil)
#define LOGIN_PROMPT                        NSLocalizedString(@"Please enter a valid email and password", nil)

#define SIGNUP_ERROR                        NSLocalizedString(@"It seems there was an error signing you up. Please try again in a bit.", nil)
#define SIGNUP_EXISTS                       NSLocalizedString(@"Looks like that email is taken! Please use a different one", nil)

#define NAME_PROMPT                         NSLocalizedString(@"Please enter both a first and last name", nil)
#define NAME_ERROR_MSG                      NSLocalizedString(@"We could not successfully save your first and last name", nil)

#define AVATAR_PROMPT                       NSLocalizedString(@"Choose a new avatar", nil)

#define NOTIF_RADIUS_ERROR_MSG              NSLocalizedString(@"Could not save notification radius", nil)

#define DISABLE_ACCT_TITLE                  NSLocalizedString(@"Are you sure? You can recover your account up to one year from today.", nil)
#define DISABLE_ACCT_ERROR                  NSLocalizedString(@"It seems we couldn't successfully disable your account. Please contact support@fresconews.com for help.", nil)

#define PROFILE_SAVE_ERROR                  NSLocalizedString(@"Could not save Profile settings", nil)

#define PASSWORD_ERROR_TITLE                NSLocalizedString(@"Passwords do not match", nil)
#define PASSWORD_ERROR_MESSAGE              NSLocalizedString(@"Please make sure your new passwords are equal", nil)

#define INVALID_CREDENTIALS                 NSLocalizedString(@"Invalid Credentials", nil)

#define TWITTER_ERROR                       NSLocalizedString(@"We ran into an error signing you in with Twitter", nil)
#define FACEBOOK_ERROR                      NSLocalizedString(@"We ran into an error signing you in with Facebook", nil)

#define NO_THANKS                           NSLocalizedString(@"No thanks, I’ll sign up later", nil)


/* First Run Permissions */

#pragma mark - First Run Permissions

#define CAMERA_ENABLED                      NSLocalizedString(@"Camera Enabled", nil)
#define CAMERA_DISABLED                     NSLocalizedString(@"Camera Disabled", nil)

#define LOC_ENABLED                         NSLocalizedString(@"Location Enabled", nil)
#define LOC_DISABLED                        NSLocalizedString(@"Location Disabled", nil)
#define CASUAL_LOC_DISABLED                 NSLocalizedString(@"Where did you go?", nil)
#define ENABLE_LOC_SETTINGS                 NSLocalizedString(@"We need your location to show you nearby assignments. Please go to Settings to enable location.", nil)

#define NOTIF_PENDING                       NSLocalizedString(@"Notifications Pending", nil)
#define NOTIF_ENABLED                       NSLocalizedString(@"Notifications Enabled", nil)

#define ENABLE_CAMERA_TITLE                 NSLocalizedString(@"Camera disabled", nil)
#define ENABLE_CAMERA_SETTINGS              NSLocalizedString(@"We can't open your camera! Please give us permission to use the camera in Settings", nil)

#define ENABLE_LOCATION_TITLE               NSLocalizedString(@"Location disabled", nil)
#define ENABLE_LOCATION_SETTINGS            NSLocalizedString(@"Fresco needs your device location to verify photos. Give us permission to use your location in Settings to open the camera.", nil)

#define ENABLE_CAMERA_LOCATION_TITLE        NSLocalizedString(@"No permission", nil)
#define ENABLE_CAMERA_LOCATION_SETTINGS     NSLocalizedString(@"Fresco needs to use your camera and device location. Please give us permission to use your location and camera in Settings.", nil)


/*  First Run Radius */

#pragma mark - First Run Radius

#define NOTIF_RADIUS_ERROR_MSG              NSLocalizedString(@"Could not save notification radius", nil)

#pragma mark - First Run TOS

#define T_O_S_UNAVAILABLE_MSG               NSLocalizedString(@"Terms of Service not available", nil)



/* Profile Settings */

#pragma mark - Profile Settings

#define AVATAR_PROMPT                       NSLocalizedString(@"Choose a new avatar", nil)

#define PROFILE_SETTINGS_SAVE_ERROR         NSLocalizedString(@"We couldn't save your profile settings. Please try again in a bit.", nil)
#define PASSWORD_SAVE_ERROR                 NSLocalizedString(@"We could successfully save your settings, but your new password wasn't saved. Please try again in a bit.", nil)


#define DISABLE_ACCT_TITLE                  NSLocalizedString(@"Are you sure? You can recover your account up to one year from today.", nil)
#define DISABLE_ACCT_ERROR                  NSLocalizedString(@"It seems we couldn't successfully disable your account. Please contact support@fresconews.com for help.", nil)
#define ACCT_WILL_BE_DISABLED               NSLocalizedString(@"Account will be disabled", nil)

#define WELL_MISS_YOU                       NSLocalizedString(@"We'll miss you!", nil)
#define YOU_CAN_LOGIN_FOR_ONE_YR            NSLocalizedString(@"You can log in any time in the next year to restore your account.", nil)

#define FB_LOGOUT_PROMPT                    NSLocalizedString(@"It seems like you logged in through Facebook. If you disconnect it, this would disable your account entirely!", nil)

#define NOTHING_HERE_YET                    NSLocalizedString(@"Nothing here yet!", nil)
#define OPEN_CAMERA                         NSLocalizedString(@"Open your camera to get started", nil)

#define PAYMENT_MESSSAGE                    NSLocalizedString(@"When a news outlet uses your content we’ll pay you directly.", nil)
#define DISABLED_CAMERA_SCAN                NSLocalizedString(@"Enable your camera to scan your debit card", nil)


#define CARD_MAX_LENGTH                     19
#define CCV_MAX_LENGTH                      3

/* Onboarding */
#pragma mark - Onboarding

#define MAIN_HEADER_1                       NSLocalizedString(@"Find breaking news around you", nil)
#define MAIN_HEADER_2                       NSLocalizedString(@"Send in your photos and videos", nil)
#define MAIN_HEADER_3                       NSLocalizedString(@"See your work in the news", nil)

#define SUB_HEADER_1                        NSLocalizedString(@"Use Fresco’s map to browse and accept paid assignments from news outlets.", nil)
#define SUB_HEADER_2                        NSLocalizedString(@"Your work can be seen by Fresco users and reporters around the world.", nil)
#define SUB_HEADER_3                        NSLocalizedString(@"When your media is used we’ll tell you who used it and send you a payment!", nil)


/* Highlights */

#pragma mark - Highlights

#define HIGHLIGHTS                          NSLocalizedString(@"Highlights", nil)



/* Stories */
#pragma mark - Stories

#define STORIES                             NSLocalizedString(@"Stories", nil)



/* Notifications */
#pragma mark - Notifications

#define VIEW                                NSLocalizedString(@"View", nil)
#define VIEW_ASSIGNMENT                     NSLocalizedString(@"View Assignment", nil)
#define ADD_CARD                            NSLocalizedString(@"Add my debit card", nil)

#define ASSIGNMENT_EXPIRED_TITLE            NSLocalizedString(@"Assignment Expired", nil)
#define ASSIGNMENT_EXPIRED_MSG              NSLocalizedString(@"This assignment has expired already!", nil)

#define OPEN_IN_MAPS                        NSLocalizedString(@"Open in Maps", nil)
#define OPEN_IN_GOOG_MAPS                   NSLocalizedString(@"Open in Google Maps", nil)

#define GALLERY_UNAVAILABLE_TITLE           NSLocalizedString(@"Gallery Unavailable", nil)
#define GALLERY_UNAVAILABLE_MSG             NSLocalizedString(@"We couldn't find this gallery!", nil)

#define TODAY_TITLE                         NSLocalizedString(@"Today in News", nil)


/* Assignments - MapView */

#pragma mark - Assignments

#define NAVIGATE_STR                        NSLocalizedString(@"Navigate", nil)
#define NAVIGATE_TO_ASSIGNMENT              NSLocalizedString(@"Navigate to the assignment", nil)
#define LOC_DISABLED_BANNER                 NSLocalizedString(@"Tap here to enable location", nil)

#pragma mark - MapView Identifiers

#define ASSIGNMENT_IDENTIFIER               @"AssignmentAnnotation"
#define CLUSTER_IDENTIFIER                  @"ClusterAnnotation"
#define USER_IDENTIFIER                     @"currentLocation"

/* Gallery Post */

#pragma mark - Gallery Post

#define GALLERY_TOOLBAR                    NSLocalizedString(@"Send to Fresco", nil)
#define MAX_POST_ERROR                     NSLocalizedString(@"Galleries can only contain up to 8 photos or videos.", nil)

#define UPLOAD_ERROR_TITLE                 NSLocalizedString(@"Upload Error", nil)
#define UPLOAD_ERROR_MESSAGE               NSLocalizedString(@"We ran into an issue uploading your content. Please try again in a bit.", nil)


/* Device Macros */

#pragma mark - Device Macros

#define IS_OS_8_OR_LATER                    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD                             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE                           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4S                       (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height < 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_IPHONE_5                         (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_IPHONE_6                         (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 667.0))

#define IS_IPHONE_6_PLUS                    (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_STANDARD_IPHONE_6                (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)

#define IS_ZOOMED_IPHONE_6                  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)

#define IS_STANDARD_IPHONE_6_PLUS           (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS             (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)
