//
//  FRSDateFormatters.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSDateFormatters : NSObject

+ (FRSDateFormatters *)sharedInstance;
- (NSDateFormatter *)defaultUTCTimeZoneFullDateFormatter;

@end
