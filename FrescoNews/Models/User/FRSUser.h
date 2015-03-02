//
//  FRSUser.h
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface FRSUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *userID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *surname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *token;

- (NSString *)displayName;

@end
