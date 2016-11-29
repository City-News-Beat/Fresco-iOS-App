//
//  FRSDevice.h
//  Fresco
//
//  Created by Philip Bernstein on 6/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    FRSDeviceiPod4,
    FRSDeviceiPod5,
    FRSDeviceiPod6,
    FRSDeviceType5,
    FRSDeviceType5S,
    FRSDeviceType6,
    FRSDeviceType6S,
    FRSDeviceType6SP,
    FRSDeviceType7,
    FRSDeviceType5CE,
    FRSDeviceType5C,
    FRSDeviceTypeSimulator32,
    FRSDeviceTypeSimulator64,
    FRSDeviceTypeUnknown
} FRSDeviceType;
@interface FRSDevice : NSObject
+(FRSDeviceType)currentDevice;
@end
