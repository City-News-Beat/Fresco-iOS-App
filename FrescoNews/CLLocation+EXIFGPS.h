//
//  CLLocation+EXIFGPS.h
//  FrescoNews
//
//  Created by Joshua Lerner on 4/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import CoreLocation;

@interface CLLocation (EXIFGPS)

- (NSDictionary *)EXIFMetadata;

@end
