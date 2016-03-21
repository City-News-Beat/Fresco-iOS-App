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

+(instancetype)postWithDictionary:(NSDictionary *)dict {
    FRSPost *post = [FRSPost MR_createEntity];
    
    if (!dict){
        NSLog(@"does not have dict");
    }
    
    
    if (dict) [post configureWithDictionary:dict];
    
    return post;
}

-(void)configureWithDictionary:(NSDictionary *)dict {
    self.uid = dict[@"_id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.imageUrl = dict[@"image"];
    self.byline = dict[@"byline"];
    self.address = [self shortAddressFromAddress:dict[@"location"][@"address"]];
    
    NSNumber *height = dict[@"meta"][@"height"] ? : @0;
    NSNumber *width = dict[@"meta"][@"width"] ? : @0;
    
    self.meta = @{@"image_height" : height, @"image_width" : width};
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSPost *post = [FRSPost MR_createEntityInContext:context];
    [post configureWithDictionary:properties];
    return post;
}


-(NSString *)shortAddressFromAddress:(NSString *)address {
    NSArray *comps = [address componentsSeparatedByString:@","];
    NSMutableString *str = [NSMutableString new];
    if (comps.count >= 3){
        [str appendString:comps[0]];
        [str appendString:@","];
        [str appendString:comps[2]];
    }
    else if (comps.count == 2){
        [str appendString:comps[0]];
        [str appendString:@","];
        [str appendString:comps[1]];
    }
    else if (comps.count == 1){
        [str appendString:comps[0]];
    }
    return str;
}

@end
