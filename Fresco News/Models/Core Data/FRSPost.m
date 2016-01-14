//
//  FRSPost.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSPost.h"
#import "FRSGallery.h"
#import "FRSUser.h"


#import "FRSDateFormatter.h"
#import "FRSDataValidator.h"

#import <MagicalRecord/MagicalRecord.h>

@implementation FRSPost

// Insert code here to add functionality to your managed object subclass

+(instancetype)postWithDictionary:(NSDictionary *)dict{
    FRSPost *post = [FRSPost MR_createEntity];
    [post configureWithDictionary:dict];
    return post;
}

-(void)configureWithDictionary:(NSDictionary *)dict{
    self.uid = dict[@"_id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.imageUrl = dict[@"image"];
    self.byline = dict[@"byline"];
    self.coordinates = dict[@"location"][@"geo"][@"coordinates"];
    self.address = [self shortAddressFromAddress:dict[@"location"][@"address"]];
    self.meta = dict[@"meta"];
}

-(NSString *)shortAddressFromAddress:(NSString *)address{
    NSArray *comps = [address componentsSeparatedByString:@","];
    NSMutableString *str = [NSMutableString new];
    if (comps.count >= 3){
        [str appendString:comps[0]];
        [str appendString:@","];
        [str appendString:comps[2]];
    }
    return str;
}

@end
