//
//  VariableStore.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "VariableStore.h"

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
        sharedInstance.errorDomain = @"com.fresconews";
        
        // colors
        sharedInstance.colorBrandDark = @"FFB814";
        sharedInstance.colorBrandPrimary = @"FFC53D";
        sharedInstance.colorBrandLight = @"FFD675";
        
        sharedInstance.colorAssignment = @"FF4ABE";
        sharedInstance.colorAlertRed = @"D0021B";
        sharedInstance.colorPhotoUse = @"5C85F5";
        sharedInstance.colorBackground = @"FAFAFA";
        
        sharedInstance.colorStoryBreaksBackground = @"5C85F5";
        
        sharedInstance.opacityDarkText = 0.87f;
        sharedInstance.opacityLightText = 0.54f;
        sharedInstance.opacityOuterListDividers = 0.26f;
        sharedInstance.opacityInnerListDividers = 0.08f;
        sharedInstance.opacityUnreadNotificationHighlights = 0.08f;
        
        // configuration that might change in debug
        sharedInstance.parseAppId = @"XYBXNv2HLxukd5JGbE6bK4vXy1JlwUVjeTKQEzZU";
        sharedInstance.parseClientKey = @"BttF0WEtSrKdLA2Xst2wfc9VQE8PUwP0OwheKEoY";
        sharedInstance.twitterConsumerKey = @"o6y4zv5yq0AfCU4HKUHQYJMXE";
        sharedInstance.twitterConsumerSecret = @"PqPWPJRAp37ZE3vLn6Uxu29BGXAaMvi0ooaiqsPQxAn0PSG0Vz";
        
        sharedInstance.baseURL = @"https://api.fresconews.com/v1/";
        sharedInstance.basePath = @"";
        sharedInstance.cdnBaseURL = @"http://res.cloudinary.com/fresco-news/image/fetch";
        sharedInstance.cdnFacebookBaseURL = @"http://res.cloudinary.com/fresco-news/image/facebook";

//        #ifdef DEBUG
//        sharedInstance.parseAppId = @"ttJBFHzdOoPrnwp8IjrZ8cD9d1kog01jiSDAK8Fc";
//        sharedInstance.parseClientKey = @"KyUgpyFKxNWg2WmdUOhasAtttr33jPLpgRc63uc4";
//        sharedInstance.baseURL = @"http://staging.fresconews.com/v1/";
//        #endif
        
        sharedInstance.maximumVideoLength = 60.0f; // Per @im
        sharedInstance.maximumAssetAge = -3600 * 6; // Per @im
        sharedInstance.locationUpdateInterval = 30; // (While the app is running)
    });
    
    return sharedInstance;
}

+ (NSString *)endpointForPath:(NSString *)endpoint
{
    return [NSString stringWithFormat:@"%@%@%@",
            [NSURL URLWithString:[VariableStore sharedInstance].baseURL],
            [NSURL URLWithString:[VariableStore sharedInstance].basePath],
            endpoint];
}

+ (void)resetDraftGalleryPost
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"captionStringInProgress"];
    [defaults setObject:nil forKey:@"defaultAssignmentID"];
    [defaults setObject:nil forKey:@"selectedAssets"];
}

@end
