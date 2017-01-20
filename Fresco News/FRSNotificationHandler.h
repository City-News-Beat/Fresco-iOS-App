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

+ (void)handleNotification:(NSDictionary *)notification;
+ (void)segueToUser:(NSString *)user;

/*
 * @discussion This method is used to retrieve the assignment from the passed IDs and subsequnetly navigate to the assignment view controller
 where the presentation of the assignment is handled
 * @param assignmentID The ID of the assignment we want to segue to
 */
+ (void)segueToAssignment:(NSString *)assignment;

+ (void)segueToGallery:(NSString *)gallery;
+ (void)segueToGallery:(NSString *)gallery post:(NSString *)post;
+ (void)segueToStory:(NSString *)story;
+ (void)segueToTodayInNews:(NSArray *)galleryIDs title:(NSString *)title;
+ (void)segueToPayment;
+ (void)segueToIdentification;

+ (BOOL)isDeeplinking;
+ (void)setIsDeeplinking:(BOOL)value;

@end
