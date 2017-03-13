//
//  Fresco.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import <Foundation/Foundation.h>

// file loading

static int const maxFileAge = 86400; //1 day, in seconds

// notifications
static NSString *const kStatusBarTappedNotification = @"statusBarTappedNotification";

static NSString *const serviceName = @"frescoNewsService3";
static NSString *const FRSUploadNotification = @"FRSUploadUpdateNotification";
static NSString *const FRSRetryUpload = @"FRSRetryUpload";
static NSString *const FRSDismissUpload = @"FRSDismissUpload";

static NSString *const userNeedsToMigrate = @"userNeedsToMigrate";
static NSString *const userHasFinishedMigrating = @"userHasFinishedMigrating";

// object types
static NSString *const postObjectType = @"post";
static NSString *const galleryObjectType = @"gallery";
static NSString *const storyObjectType = @"story";

// user defaults
static NSString *const settingsUserNotificationRadius = @"notification-radius";
static NSString *const settingsPaymentLastFour = @"payment-last-four";
static NSString *const settingsUserNotificationToggle = @"notifications-enabled";
static NSString *const userHasSeenPermissionsAlert = @"userHasSeenPermissionsAlert";
static NSString *const startDate = @"startDate";
static NSString *const isFirstRun = @"isFirstRun";
static NSString *const locationEnabled = @"location-enabled";
static NSString *const facebookConnected = @"facebook-connected";
static NSString *const facebookName = @"facebook-name";
static NSString *const twitterConnected = @"twitter-connected";
static NSString *const twitterHandle = @"twitter-handle";
static NSString *const kClientToken = @"kClientToken";
static NSString *const kUserToken = @"kUserToken";

// nsnotification
static NSString *const enableAssignmentAccept = @"enableAssignmentAccept";
static NSString *const disableAssignmentAccept = @"disableAssignmentAccept";

// mixpanel
static NSString *const activityDuration = @"activity_duration";

// user - data
static NSInteger const maxUsernameChars = 20;
static NSInteger const maxNameChars = 40;
static NSInteger const maxLocationChars = 40;
static NSInteger const maxBioChars = 160;
static NSString *const validUsernameChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";

// map + location
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
static int const maxVideoAge = 86400; // seconds in a day
static int const maxAssetCount = 8;
static NSString *const localDirectory = @"frs";

// UI
static NSString *const settingsCellIdentifier = @"SettingsCell";

// TOS

#define USER_NAME @"username"
#define PASS_WORD @"password"
#define E_MAIL @"email"
#define FULL_NAME @"full_name"

// callbacks / blocks
typedef void (^StoryImageBlock)(NSInteger storyImageIndex);
typedef void (^ShareSheetBlock)(NSArray *sharedContent);
typedef void (^ActionButtonBlock)();
typedef void (^TransferPercentage)(float percentage);
typedef void (^FRSAPIResponseBlock)(id responseObject, NSError *error);
typedef void (^FRSDataResponseBlock)(NSData *data, NSError *error);
typedef void (^FRSAPISuccessBlock)(BOOL sucess, NSError *error);
typedef void (^FRSAPIArrayResponseBlock)(NSArray *responseObject, NSError *error);

// errors
static NSString *const errorDomain = @"com.fresconews.Fresco";

// fields needed
static NSString *const lineOneField = @"legal_entity.address.line1";
static NSString *const cityField = @"legal_entity.address.city";
static NSString *const postalCodeField = @"legal_entity.address.postal_code";
static NSString *const stateField = @"legal_entity.address.state";
static NSString *const birthDayField = @"legal_entity.dob.day";
static NSString *const birthMonthField = @"legal_entity.dob.month";
static NSString *const birthYearField = @"legal_entity.dob.year";
static NSString *const ssnField = @"legal_entity.ssn_last_4";
static NSString *const firstNameField = @"legal_entity.first_name";
static NSString *const lastNameField = @"legal_entity.last_name";

static NSString *const settingsKey = @"notification-type";


#define OBJECT @"object"
#define OBJECT_ID @"object_id"
#define DISTANCE_AWAY @"distance_away"


// API dictionary response keys
    // todo: add other keys and create new class for all response keys
// Notification
#define TYPE @"type"
#define TITLE @"title"
#define META @"meta"
#define PUSH_KEY @"push_key"

// Assignment
#define ASSIGNMENT @"assignment"
#define ASSIGNMENT_ID @"assignment_id"
#define IS_GLOBAL @"is_global"
#define GLOBAL @"global"

// Gallery
#define GALLERY @"gallery"
#define GALLERY_IDS @"gallery_ids"
#define GALLERY_ID @"gallery_id"

// User
#define USER @"user"
#define USER_IDS @"user_ids"
#define HAS_PAYMENT @"has_payment"

// Story
#define STORY @"story"
#define STORY_ID @"story_id"

// scrolling, video playback
static float const maxScrollVelocity = 2.1;

#define ResourcePath(path) [[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path) [UIImage imageWithContentsOfFile:path]

#define ImageWithData(data) [UIImage imageWithData:data]

/* Device Macros */

#pragma mark - Device Macros

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4S (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height < 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_IPHONE_5 (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_IPHONE_6 (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 667.0))

#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_STANDARD_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)

#define IS_ZOOMED_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)

#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)
