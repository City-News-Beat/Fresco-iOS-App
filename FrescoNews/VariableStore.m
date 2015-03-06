//
//  VariableStore.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "VariableStore.h"

@implementation VariableStore
+ (VariableStore *)sharedInstance {
    static VariableStore *sharedInstance = nil;
    
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[VariableStore alloc] init];
        
        // colors
        sharedInstance.colorBrandDark = @"FFB814";
        sharedInstance.colorBrandPrimary = @"FFC53D";
        sharedInstance.colorBrandLight = @"FFD675";
        
        sharedInstance.colorAssignment = @"FF4ABE";
        sharedInstance.colorAlertRed = @"D0021B";
        sharedInstance.colorPhotoUse = @"5C85F5";
        sharedInstance.colorBackground = @"FAFAFA";
        
        sharedInstance.opacityDarkText = 0.87f;
        sharedInstance.opacityLightText = 0.54f;
        sharedInstance.opacityOuterListDividers = 0.26f;
        sharedInstance.opacityInnerListDividers = 0.08f;
        sharedInstance.opacityUnreadNotificationHighlights = 0.08f;
    });
    
    return sharedInstance;
}
@end
