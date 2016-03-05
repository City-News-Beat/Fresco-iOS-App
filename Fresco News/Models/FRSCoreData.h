//
//  FRSPersistence.h
//  Fresco
//
//  Created by Philip Bernstein on 3/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol FRSManagedObject
@optional // don't want to force this for every data models
-(instancetype)initWithProperties:(NSDictionary *)properties;
@end
