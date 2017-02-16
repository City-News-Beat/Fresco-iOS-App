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

@interface FRSNotificationHandler : NSObject


/**
 This method is used to handle notifications filtered by their type.

 @param push NSDictionary with the notifications meta data.
 @param shouldTrack BOOL that logs the notificationOpened event with all associated data when enabled.
 */
+ (void)handleNotification:(NSDictionary *)push track:(BOOL)shouldTrack;

/*
 * @discussion This method is used to retrieve the assignment from the passed IDs and subsequnetly navigate to the assignment view controller
 where the presentation of the assignment is handled
 * @param assignmentID The ID of the assignment we want to segue to
 */
+ (void)segueToAssignment:(NSString *)assignment;

+ (void)segueToUser:(NSString *)user;
+ (void)segueToGallery:(NSString *)gallery;
+ (void)segueToStory:(NSString *)story;
+ (void)segueToTodayInNews:(NSArray *)galleryIDs title:(NSString *)title;
+ (void)segueToPayment;
+ (void)segueToIdentification;

+ (BOOL)isDeeplinking;
+ (void)setIsDeeplinking:(BOOL)value;


/**
 Set this BOOL to YES when coming from feeds that should be tracked.
 */
@property BOOL enableTrack;

@end
