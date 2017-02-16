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
#import <Mixpanel/Mixpanel.h>
#import "FRSAlertView.h"
#import "UIColor+Fresco.h"


/**
 All of the API Client's possible completion blocks
 */
typedef void (^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);
typedef void (^FRSAPIBooleanCompletionBlock)(BOOL response, NSError *error);
typedef void (^FRSAPISizeCompletionBlock)(NSInteger size, NSError *error);

typedef NS_ENUM(NSUInteger, FRSRequestAuth) {
    FRSUserAuth,
    FRSClientAuth,
    FRSBasicAuth
};


@protocol FRSApp
- (UITabBarController *)tabBar;
@property (nonatomic, retain) UIWindow *window;
@end

@interface FRSAPIClient : NSObject <FRSAlertViewDelegate>

@property (nonatomic, retain) AFHTTPSessionManager *requestManager;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic) FRSRequestAuth requestAuth;

+ (instancetype)sharedClient;

- (void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)delete:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters withData:(NSData *)data withName:(NSString *)name withFileName:(NSString *)fileName completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Takes an array response and parses it for us into CoreData objects

 @param response API response
 @param cache If we should cache or not
 @return An NSArray with the core data objects
 */
- (NSArray *)parsedObjectsFromAPIResponse:(NSArray *)response cache:(BOOL)cache;


/**
 Returns a new AFHTTP session manager for us that has the correct headers

 @param endpoint Endpoint making a request to
 @param requestType Type of request
 @return A new session manager
 */
- (AFHTTPSessionManager *)managerWithFrescoConfigurations:(NSString *)endpoint withRequestType:(NSString *)requestType;

@end
