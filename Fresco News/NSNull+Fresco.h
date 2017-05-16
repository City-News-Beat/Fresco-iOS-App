//
//  NSNull+Fresco.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 This category provides implementation for the methods which may be accidentally called on NSNull. Usually some of the common (but crash-prone) NSString methods can be implemented here. 
 
 This is only to correct certain blunders we might have done all across the app like calling these on string objects without actually checking the object isKindOfClass NSString or not. 
 
 Few Dictionary and Array methods can also find their place here for extra safety. 
 */

@interface NSNull (Fresco)

- (NSUInteger)length;

- (NSInteger)integerValue;

- (float)floatValue;

- (NSString *)description;

- (NSArray *)componentsSeparatedByString:(NSString *)separator;

- (id)objectForKey:(id)key;

- (id)valueForKey:(id)key;

- (BOOL)boolValue;

@end
