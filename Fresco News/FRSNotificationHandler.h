//
//  FRSNotificationHandler.h
//  Fresco
//
//  Created by Philip Bernstein on 11/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fresco.h"
#import <UIKit/UIKit.h>
#import "FRSAssignment+CoreDataProperties.h"

// Upload - local
static NSString *const restartUploadNotification = @"user-local-upload";

// News
static NSString *const photoOfDayNotification = @"user-news-photos-of-day";
static NSString *const todayInNewsNotification = @"user-news-today-in-news";
static NSString *const userNewsGalleryNotification = @"user-news-gallery";
static NSString *const userNewsStoryNotification = @"user-news-story";
static NSString *const userNewsCustomNotification = @"user-news-custom-push";

// Social
static NSString *const followedNotification = @"user-social-followed";
static NSString *const likedNotification = @"user-social-gallery-liked";
static NSString *const repostedNotification = @"user-social-reposted";
static NSString *const commentedNotification = @"user-social-commented";
static NSString *const mentionCommentNotification = @"user-social-mentioned-comment"; //cc: api
static NSString *const mentionGalleryNotification = @"user-social-mentioned-gallery"; //cc: api

// Payment
static NSString *const purchasedContentNotification = @"user-dispatch-purchased";
static NSString *const paymentExpiringNotification = @"user-payment-payment-expiring";
static NSString *const paymentSentNotification = @"user-payment-payment-sent";
static NSString *const paymentDeclinedNotification = @"user-payment-payment-declined";
static NSString *const taxInfoRequiredNotification = @"user-payment-tax-info-required";
static NSString *const taxInfoProcessedNotification = @"user-payment-tax-info-processed";
static NSString *const taxInfoDeclinedNotification = @"user-payment-tax-info-declined";

// Assignments
static NSString *const newAssignmentNotification = @"user-dispatch-new-assignment";
static NSString *const galleryApprovedNotification = @"user-dispatch-content-verified";

// Smooch Whisper
static NSString *const smoochSupportNotification = @"user-support-request";
static NSString *const smoochSupportTempNotification = @"Fresco Support Request"; // This will be removed when support is added on the web platform
static NSString *const smoochNotificationEventName = @"smooch-invite";

@interface FRSNotificationHandler : NSObject

+ (void)handleNotification:(NSDictionary *)notification;
+ (void)segueToUser:(NSString *)user;

/*
 * @discussion This method is used to retrieve the assignment from the passed IDs and subsequnetly navigate to the assignment view controller
 where the presentation of the assignment is handled
 * @param assignmentID The ID of the assignment we want to segue to
 */
+ (void)segueToAssignment:(NSString *)assignment;

+ (void)segueToGallery:(NSString *)gallery;
+ (void)segueToStory:(NSString *)story;
+ (void)segueToTodayInNews:(NSArray *)galleryIDs title:(NSString *)title;
+ (void)segueToPayment;
+ (void)segueToIdentification;

+ (BOOL)isDeeplinking;
+ (void)setIsDeeplinking:(BOOL)value;

@end
