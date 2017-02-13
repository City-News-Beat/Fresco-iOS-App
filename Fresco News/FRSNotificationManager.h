//
//  FRSNotificationManager.h
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSNotificationManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)getNotificationsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getNotificationsWithLast:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)setPushNotificationWithBool:(BOOL)sendPush completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)markAsRead:(NSDictionary *)params;

@end
