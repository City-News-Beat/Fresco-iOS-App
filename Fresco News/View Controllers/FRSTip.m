//
//  FRSTip.m
//  Fresco
//
//  Created by Omar Elfanek on 5/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTip.h"

@implementation FRSTip

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.title = [FRSTipsManager titleFromDictionary:dictionary];
        self.subtitle = [FRSTipsManager subtitleFromDictionary:dictionary];
        self.videoURL = [FRSTipsManager videoURLStringFromDictionary:dictionary];
        self.thumbnailURL = [FRSTipsManager thumbnailURLStringFromDictionary:dictionary];
    };
    
    return self;
}

@end
