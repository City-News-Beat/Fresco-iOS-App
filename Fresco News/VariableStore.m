//
//  VariableStore.m
//  FrescoNews
//
//  Created by Fresco News on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "VariableStore.h"

//NSString * const kNotificationAPIKeyAvailable = @"NotificationAPIKeyAvailable";

//NSString * const kNotificationViewDismiss = @"DismissNotificationsView";

//NSString * const kNotificationBadgeReset = @"ResetNotificationBadge";

NSString * const kNotificationImageSet = @"UserImageSet";

@implementation VariableStore

+ (VariableStore *)sharedInstance
{
    static VariableStore *sharedInstance = nil;
    
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        sharedInstance = [[VariableStore alloc] init];
        
        // errors
        sharedInstance.errorDomain = ERROR_DOMAIN;
        
        // colors
        sharedInstance.brandDarkColor = [UIColor brandDarkColor];
        sharedInstance.backgroundColor = [UIColor whiteBackgroundColor];

        // configuration that might change in debug
        sharedInstance.parseAppId = PRODUCTION_PARSE_APP_ID;
        sharedInstance.parseClientKey = PRODUCTION_PARSE_CLIENT_KEY;
        sharedInstance.twitterConsumerKey = TWITTER_CONSUMER_KEY;
        sharedInstance.twitterConsumerSecret = TWITTER_CONSUMER_SECRET;
        
        sharedInstance.baseUrl = PRODUCTION_BASE_URL;
        sharedInstance.baseAPI = PRODUCTION_BASE_API;
        sharedInstance.basePath = BASE_PATH;
        sharedInstance.cdnBaseURL = CDN_BASE_URL;
        sharedInstance.cdnFacebookBaseURL = CDN_FACEBOOK_URL;

        #ifdef DEBUG
        sharedInstance.parseAppId = STAGING_PARSE_APP_ID;
        sharedInstance.parseClientKey = STAGING_PARSE_CLIENT_KEY;
        sharedInstance.baseUrl = STAGING_BASE_URL;
        sharedInstance.baseAPI = STAGING_BASE_API;
        #endif

        sharedInstance.maximumVideoLength = MAX_VIDEO_LENGTH; // Per @im
        sharedInstance.maximumAssetAge = MAX_ASSET_AGE; // Per @im
        sharedInstance.locationUpdateInterval = LOCATION_UPDATE_INTERVAL; // (While the app is running)
    });
    
    return sharedInstance;
}

+ (NSString *)endpointForPath:(NSString *)endpoint
{
    return [NSString stringWithFormat:@"%@%@%@",
            [NSURL URLWithString:[VariableStore sharedInstance].baseAPI],
            [NSURL URLWithString:[VariableStore sharedInstance].basePath],
            endpoint];
}

+ (void)resetDraftGalleryPost
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:UD_CAPTION_STRING_IN_PROGRESS];
    [defaults setObject:nil forKey:UD_DEFAULT_ASSIGNMENT_ID];
    [defaults setObject:nil forKey:UD_SELECTED_ASSETS];
}

@end
