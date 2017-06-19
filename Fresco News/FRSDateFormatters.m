//
//  FRSDateFormatters.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSDateFormatters.h"

@interface FRSDateFormatters ()

@property (nonatomic, strong) NSDateFormatter *defaultFullDateFormatter;

@end

@implementation FRSDateFormatters

+ (FRSDateFormatters *)sharedInstance {
    static FRSDateFormatters *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.defaultFullDateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    self.defaultFullDateFormatter.timeZone = timeZone;
    self.defaultFullDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
}

- (NSDateFormatter *)defaultUTCTimeZoneFullDateFormatter {
    return self.defaultFullDateFormatter;
}

@end
