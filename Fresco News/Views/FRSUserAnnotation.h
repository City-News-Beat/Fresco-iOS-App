//
//  FRSUserAnnotation.h
//  Fresco
//
//  Created by Omar Elfanek on 7/26/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface FRSUserAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) UIImage *image;

@end
