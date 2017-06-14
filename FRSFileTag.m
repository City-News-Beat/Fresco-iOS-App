//
//  FRSFileTag.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTag.h"
#import "FRSCaptureModeEnumHelper.h"

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
    if([self.name isEqualToString:FRSCaptureModeVideoInterview_StandardDisplayName]) {
        self.captureMode = FRSCaptureModeVideoInterview;
    }
    else if([self.name isEqualToString:FRSCaptureModeVideoWide_StandardDisplayName]) {
        self.captureMode = FRSCaptureModeVideoWide;
    }
    else if([self.name isEqualToString:FRSCaptureModeVideoPan_StandardDisplayName]) {
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
