//
//  VariableStore.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VariableStore : NSObject
+ (VariableStore *)sharedInstance;

// colors
@property NSString *colorBrandDark;
@property NSString *colorBrandPrimary;
@property NSString *colorBrandLight;

@property NSString *colorAssignment;
@property NSString *colorAlertRed;
@property NSString *colorPhotoUse;
@property NSString *colorBackground;

@property CGFloat opacityDarkText;
@property CGFloat opacityLightText;
@property CGFloat opacityOuterListDividers;
@property CGFloat opacityInnerListDividers;
@property CGFloat opacityUnreadNotificationHighlights;

@end
