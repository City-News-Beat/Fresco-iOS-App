//
//  FRSAPIClient.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSLocator.h"
#import "FRSUser.h"
#import "FRSSocial.h"
#import "FRSJSONResponseSerializer.h"
#import "AFNetworking.h"
#import "SAMKeychain.h"
#import <Photos/Photos.h>
#import <Mixpanel/Mixpanel.h>
#import "FRSAlertView.h"
#import "UIColor+Fresco.h"

typedef void (^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);
typedef void (^FRSAPIBooleanCompletionBlock)(BOOL response, NSError *error);
typedef void (^FRSAPISizeCompletionBlock)(NSInteger size, NSError *error);

@protocol FRSApp
- (UITabBarController *)tabBar;
@property (nonatomic, retain) UIWindow *window;
@end

@interface FRSAPIClient : NSObject <FRSAlertViewDelegate>

@property (nonatomic, retain) AFHTTPSessionManager *requestManager;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

+ (instancetype)sharedClient;

- (void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void) delete:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters withData:(NSData *)data withName:(NSString *)name withFileName:(NSString *)fileName completion:(FRSAPIDefaultCompletionBlock)completion;

- (NSDate *)dateFromString:(NSString *)string;

- (NSArray *)parsedObjectsFromAPIResponse:(NSArray *)response cache:(BOOL)cache;

- (AFHTTPSessionManager *)managerWithFrescoConfigurations:(NSString *)endpoint withRequestType:(NSString *)requestType;

@end
