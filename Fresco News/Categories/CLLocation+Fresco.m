//
//  CLLocation+Fresco.m
//  Fresco
//
//  Created by Elmir Kouliev on 2/27/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "CLLocation+Fresco.h"

@implementation CLLocation (Fresco)

- (void)fetchAddress:(FRSAPIDefaultCompletionBlock)completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __block NSString *address;
    
    [geocoder reverseGeocodeLocation:self
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (placemarks && placemarks.count > 0) {
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           
                           NSString *thoroughFare = @"";
                           if ([placemark thoroughfare] && [[placemark thoroughfare] length] > 0) {
                               thoroughFare = [[placemark thoroughfare] stringByAppendingString:@", "];
                               
                               if ([placemark subThoroughfare]) {
                                   thoroughFare = [[[placemark subThoroughfare] stringByAppendingString:@" "] stringByAppendingString:thoroughFare];
                               }
                           }
                           
                           address = [NSString stringWithFormat:@"%@%@, %@", thoroughFare, [placemark locality], [placemark administrativeArea]];
                           completion(address, Nil);
                       } else {
                           completion(@"No address found.", Nil);
                           [FRSTracker track:addressError parameters:@{ @"coordinates" : @[ @(self.coordinate.longitude), @(self.coordinate.latitude) ] }];
                       }
                       
                   }];
}


@end
