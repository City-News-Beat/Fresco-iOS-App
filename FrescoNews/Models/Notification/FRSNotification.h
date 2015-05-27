//
//  FRSNotification.h
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@interface FRSNotification : MTLModel

@property (nonatomic, copy) NSNumber *notificaitonId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, copy) NSString *notificationDescription;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSDictionary *notificationData;

@end
