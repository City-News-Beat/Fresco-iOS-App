//
//  NSDate+ISO.h
//  FrescoNews
//
//  Created by Maurice Wu on 4/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

@interface NSDate (ISO)

- (NSString *)ISODate;
- (NSString *)ISOTime;
- (NSString *)ISODateWithTimeZone;

@end
