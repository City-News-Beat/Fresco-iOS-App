//
//  Fresco.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import <Foundation/Foundation.h>

// notifications
static NSString *const kStatusBarTappedNotification = @"statusBarTappedNotification";

static NSString *const serviceName = @"frescoNewsService3";
static NSString *const FRSUploadNotification = @"FRSUploadUpdateNotification";

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
static NSString *const locationEnabled = @"location-enabled";

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

// callbacks / blocks
typedef void (^StoryImageBlock)(NSInteger storyImageIndex);
typedef void (^ShareSheetBlock)(NSArray *sharedContent);
typedef void (^ActionButtonBlock)();
typedef void (^TransferPercentage)(float percentage);
typedef void (^FRSAPIResponseBlock)(id responseObject, NSError *error);
typedef void (^FRSDataResponseBlock)(NSData *data, NSError *error);
typedef void (^FRSAPISuccessBlock)(BOOL sucess, NSError *error);
typedef void (^FRSAPIArrayResponseBlock)(NSArray *responseObject, NSError *error);

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
