//
//  FRSAssignment.h
//  FrescoNews
//
//  Created by Fresco News on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;
#import <Mantle/Mantle.h>

@class FRSUser, CLLocation;

@interface FRSAssignment : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *assignmentId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSArray *galleries;
@property (nonatomic, copy) NSString *active;
@property (nonatomic, strong) NSDictionary *location;
@property (strong, nonatomic) CLLocation *locationObject;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSNumber *radius; // in miles
@property (nonatomic, strong) NSDate *timeCreated;
@property (nonatomic, strong) NSDate *timeEdited;
@property (nonatomic, strong) NSDate *expirationTime;
@property (nonatomic, strong) FRSUser *owner;

@end
