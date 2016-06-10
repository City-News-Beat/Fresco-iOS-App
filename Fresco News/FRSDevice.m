//
//  FRSDevice.m
//  Fresco
//
//  Created by Philip Bernstein on 6/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDevice.h"
#import <sys/utsname.h>

@implementation FRSDevice
+(FRSDeviceType)currentDevice {
    NSString *mahineString = machineName();
    
    if ([mahineString isEqualToString:@"i386"]) {
        return FRSDeviceTypeSimulator32;
    }
    else if ([mahineString isEqualToString:@"x86_64"]) {
        return FRSDeviceTypeSimulator64;
    }
    else if ([mahineString isEqualToString:@"iPod3,1"]) {
        return FRSDeviceiPod4;
    }
    else if ([mahineString isEqualToString:@"iPod4,1"]) {
        return FRSDeviceiPod5;
    }
    else if ([mahineString isEqualToString:@"iPod7,1"]) {
        return FRSDeviceiPod6;
    }
    else if ([mahineString isEqualToString:@"iPhone5,1"]) {
        return FRSDeviceType5;
    }
    else if ([mahineString isEqualToString:@"iPhone5,2"]) {
        return FRSDeviceType5;
    }
    else if ([mahineString isEqualToString:@"iPhone5,3"]) {
        return FRSDeviceType5C;
    }
    else if ([mahineString isEqualToString:@"iPhone5,4"]) {
        return FRSDeviceType5C;
    }
    else if ([mahineString isEqualToString:@"iPhone6,1"]) {
        return FRSDeviceType5S;
    }
    else if ([mahineString isEqualToString:@"iPhone6,2"]) {
        return FRSDeviceType5S;
    }
    else if ([mahineString isEqualToString:@"iPhone7,1"]) {
        return FRSDeviceType6SP;
    }
    else if ([mahineString isEqualToString:@"iPhone7,2"]) {
        return FRSDeviceType6;
    }
    else if ([mahineString isEqualToString:@"iPhone8,1"]) {
        return FRSDeviceType6S;
    }
    else if ([mahineString isEqualToString:@"iPhone8,2"]) {
        return FRSDeviceType6S;
    }
    else if ([mahineString isEqualToString:@"iPhone8,4"]) {
        return FRSDeviceType5CE;
    }
    
    return FRSDeviceTypeUnknown;
}

NSString *machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
