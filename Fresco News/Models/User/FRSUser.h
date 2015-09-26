//
//  FRSUser.h
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;
#import <Mantle/Mantle.h>
@interface FRSUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *first;
@property (nonatomic, copy) NSString *last;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSNumber *payable;
@property (nonatomic, copy) NSNumber *notificationRadius;

- (NSString *)displayName;
- (NSString *)asJSONString;
- (NSURL *)avatarUrl;

@end
