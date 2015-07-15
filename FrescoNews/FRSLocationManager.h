//
//  FRSLocationManager.h
//  Fresco
//
//  Created by Elmir Kouliev on 7/15/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface FRSLocationManager : CLLocationManager <CLLocationManagerDelegate>


+ (FRSLocationManager *)sharedManager;

/*
** Sets up location monitoring
*/
- (void)setupLocationMonitoring;


@end
