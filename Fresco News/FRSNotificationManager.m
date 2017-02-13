//
//  FRSNotificationManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSNotificationManager.h"

static NSString *const notificationEndpoint = @"user/notifications";
static NSString *const updateSettingsEndpoint = @"user/settings/update";
static NSString *const seeNotificationsEndpoint = @"user/notifications/see";

@implementation FRSNotificationManager

+ (instancetype)sharedInstance {
    static FRSNotificationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSNotificationManager alloc] init];
    });
    return instance;
}

- (void)getNotificationsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:notificationEndpoint
        withParameters:@{}
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)setPushNotificationWithBool:(BOOL)sendPush completion:(FRSAPIDefaultCompletionBlock)completion {
    NSDictionary *dict = @{ @"send_push" : [NSNumber numberWithBool:sendPush] };

    [[FRSAPIClient sharedClient] post:updateSettingsEndpoint
        withParameters:@{ @"notify-user-dispatch-new-assignment" : dict }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)getNotificationsWithLast:(nonnull NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion {
    if (!last) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:Nil]);
    }

    [[FRSAPIClient sharedClient] get:notificationEndpoint
        withParameters:@{ @"last" : last }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)markAsRead:(NSDictionary *)params {
    [[FRSAPIClient sharedClient] post:seeNotificationsEndpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {
                           }];
}

@end
