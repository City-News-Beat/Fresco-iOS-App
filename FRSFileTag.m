//
//  FRSFileTag.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTag.h"

@interface FRSFileTag ()

@end

@implementation FRSFileTag

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if(self){
        self.name = name;
        [self setupCaptureMode];
    }
    return self;
}

- (void)setupCaptureMode {
    if([self.name isEqualToString:@"Interview"]) {
        self.captureMode = FRSCaptureModeVideoInterview;
    }
    else if([self.name isEqualToString:@"Wide Shot"]) {
        self.captureMode = FRSCaptureModeVideoWide;
    }
    else if([self.name isEqualToString:@"Steady Pan"]) {
        self.captureMode = FRSCaptureModeVideoPan;
    }
    else {
        self.captureMode = FRSCaptureModeOther;
    }
}

- (instancetype) copyWithZone: (NSZone *) zone
{
    FRSFileTag *obj = [[[self class] allocWithZone:zone] init];
    if (obj) {
        [obj setCaptureMode:_captureMode];
        [obj setName:_name];
    }
    
    return obj;
}

@end
