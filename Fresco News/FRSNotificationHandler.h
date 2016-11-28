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
+(void)handleNotification:(NSDictionary *)notification;
+(void)segueToUser:(NSString *)user;
+(void)segueToAssignment:(NSString *)assignment;
+(void)segueToGallery:(NSString *)gallery;
+(void)segueToGallery:(NSString *)gallery post:(NSString *)post;
+(void)segueToStory:(NSString *)story;
+(void)segueToTodayInNews:(NSArray *)galleryIDs title:(NSString *)title;
+(void)segueToPayment;
+(void)segueToIdentification;
//+(BOOL)isDeeplinking;
@end
