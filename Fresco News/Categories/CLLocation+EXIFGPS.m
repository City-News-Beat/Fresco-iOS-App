//
//  CLLocation+EXIFGPS.m
//  FrescoNews
//
//  Created by Joshua Lerner on 4/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import ImageIO;

#import "CLLocation+EXIFGPS.h"
#import "NSDate+ISO.h"

@implementation CLLocation (EXIFGPS)

- (NSDictionary *)EXIFMetadata
{
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    
    NSNumber *altitudeRef = [NSNumber numberWithInteger:self.altitude < 0.0 ? 1 : 0];
    NSString *latitudeRef = self.coordinate.latitude < 0.0 ? @"S" : @"N";
    NSString *longitudeRef = self.coordinate.longitude < 0.0 ? @"W" : @"E";
    
    [metadata setValue:[NSNumber numberWithDouble:ABS(self.coordinate.latitude)] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [metadata setValue:[NSNumber numberWithDouble:ABS(self.coordinate.longitude)] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    [metadata setValue:latitudeRef forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    [metadata setValue:longitudeRef forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    
    [metadata setValue:[NSNumber numberWithDouble:ABS(self.altitude)] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    [metadata setValue:altitudeRef forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
    
    [metadata setValue:[self.timestamp ISOTime] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [metadata setValue:[self.timestamp ISODate] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    
    //Should be saved into dictionary under key forKey:(NSString *)kCGImagePropertyGPSDictionary
    return [metadata copy];
}

@end
