//
//  FRSAssignment.h
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@class FRSUser, FRSTag;

@interface FRSAssignment : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *assignmendId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSArray *galleries;
@property (nonatomic, copy) NSString *active;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSNumber *radius;
@property (nonatomic, strong) NSDate *timeCreated;
@property (nonatomic, strong) NSDate *timeEdited;
@property (nonatomic, strong) NSDate *expirationTime;

@property (nonatomic, strong) FRSUser *owner;

@end
