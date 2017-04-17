//
//  FRSTracker.h
//  Fresco
//
//  Created by Philip Bernstein on 9/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGAnalytics.h>
#import <UXCam/UXCam.h>

static NSString *const gallerySession = @"Gallery session";
static NSString *const galleryLiked = @"Gallery liked";
static NSString *const galleryUnliked = @"Gallery unliked";
static NSString *const galleryReposted = @"Gallery reposted";
static NSString *const galleryUnreposted = @"Gallery unreposted";
static NSString *const cameraSession = @"Camera session";
static NSString *const cameraSessionPhotoCount = @"Camera session photo count";
static NSString *const cameraSessionVideoCount = @"Camera session video count";
static NSString *const highlightsSession = @"Highlights session";
static NSString *const profileSession = @"Profile session";
static NSString *const storiesSession = @"Stories session";
static NSString *const uploadError = @"Upload error";
static NSString *const uploadDebug = @"Upload debug";
static NSString *const uploadClose = @"Upload close";
static NSString *const uploadCancel = @"Upload cancel";
static NSString *const uploadRetry = @"Upload retry";
static NSString *const onboardingEvent = @"Onboarding";
static NSString *const onboardingReads = @"Onboarding reads";
static NSString *const onboardingQuits = @"Onboarding immediate quits";
static NSString *const galleryShared = @"Gallery shared";
static NSString *const signupsWithTwitter = @"Signups with Twitter";
static NSString *const signupsWithFacebook = @"Signups with Facebook";
static NSString *const signupsWithEmail = @"Signups with email";
static NSString *const signupEvent = @"Signup";
static NSString *const loginEvent = @"Logins";
static NSString *const addressError = @"Address Error";
static NSString *const notificationsEnabled = @"Permissions notification enables";
static NSString *const notificationsDisabled = @"Permissions notification disables";
static NSString *const notificationOpened = @"Notification opened";
static NSString *const cameraEnabled = @"Permissions camera enabled";
static NSString *const cameraDisabled = @"Permissions camera disables";
static NSString *const microphoneEnabled = @"Permissions microphone enables";
static NSString *const microphoneDisabled = @"Permissions microphone disables";
static NSString *const logoutEvent = @"Logouts";
static NSString *const aggressivePan = @"Capture Agressive Pan";
static NSString *const captureWobble = @"Capture Wobble";
static NSString *const articleOpens = @"Article opens";
static NSString *const photosEnabled = @"Permissions photos enables";
static NSString *const photosDisabled = @"Permissions photos disables";
static NSString *const videosInGallery = @"Submission videos in gallery";
static NSString *const photosInGallery = @"Submission photos in gallery";
static NSString *const sharedFromHighlights = @"Galleries shared from highlights";
static NSString *const galleryOpenedFromHighlights = @"Gallery opened";
static NSString *const galleryOpenedFromProfile = @"Gallery opened";
static NSString *const galleryOpenedFromStories = @"Gallery opened";
static NSString *const galleryOpenedFromSearch = @"Gallery opened";
static NSString *const galleryOpenedFromFollowing = @"Gallery opened";
static NSString *const galleryOpenedFromPush = @"Gallery opened";
static NSString *const locationPermissionsEnabled = @"Permissions location enables";
static NSString *const locationPermissionsDisabled = @"Permissions location disables";
static NSString *const loginError = @"Login Error";
static NSString *const registrationError = @"Registration Error";
static NSString *const signupRadiusChange = @"Signup radius changes";
static NSString *const submissionsEvent = @"Submissions";
static NSString *const itemsInGallery = @"Submission item in gallery";
static NSString *const assignmentAccepted = @"Assignment accepted";
static NSString *const assignmentUnaccepted = @"Assignment un_accepted";
static NSString *const assignmentClicked = @"Assignment clicked";
static NSString *const assignmentDismissed = @"Assignment dismissed";

@interface FRSTracker : NSObject {
}

+ (void)track:(NSString *)eventName parameters:(NSDictionary *)parameters;
+ (void)track:(NSString *)eventName;
+ (void)screen:(NSString *)screen;
+ (void)screen:(NSString *)screen parameters:(NSDictionary *)parameters;
+ (void)startSegmentAnalytics;
+ (void)reset;

/**
 Combines both the Segment user tracking event with the UXCam tracking event into one method call.
 */
+ (void)trackUser;

/**
 Stops tracking users screen.
 */
+ (void)stopUXCam;

/**
 Starts tracking users screen using UXCam.
 */
+ (void)startUXCam;


/**
 Launches Adjust for us
 */
+ (void)launchAdjust;

+ (void)configureFabric;

+ (void)configureSmooch;


@end
