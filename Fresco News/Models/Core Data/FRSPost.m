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
#import "MagicalRecord.h"
#import "FRSAPIClient.h"

@implementation FRSPost
@synthesize currentContext, location, contentType;

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
    
    self.uid = dict[@"id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    
    self.imageUrl = dict[@"image"];
    self.byline = dict[@"byline"];
    self.address = [self shortAddressFromAddress:dict[@"address"]];
    
    if (dict[@"owner"][@"id"] && ![dict[@"owner"][@"uid"] isEqual:[NSNull null]]) {
        self.creator = [FRSUser MR_createEntity];
        self.creator.uid = dict[@"owner"][@"id"];
        self.creator.username = dict[@"owner"][@"username"];
        self.creator.firstName = (dict[@"owner"][@"full_name"] != Nil && ![dict[@"owner"][@"full_name"] isEqual:[NSNull null]] && [[dict[@"owner"][@"full_name"] class] isSubclassOfClass:[NSString class]]) ? dict[@"owner"][@"full_name"] : @"";;
        self.creator.bio = (dict[@"owner"][@"bio"] != Nil) ? dict[@"owner"][@"bio"] : @"";
    }
    
    if (dict[@"video"] != Nil && dict[@"stream"] != [NSNull null]) {
        self.videoUrl = dict[@"stream"];
    }
    
    NSNumber *height = dict[@"height"] ? : @0;
    NSNumber *width = dict[@"width"] ? : @0;
    
    self.meta = @{@"image_height" : height, @"image_width" : width};
}

-(void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context {
    self.uid = dict[@"id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.imageUrl = dict[@"image"];
    self.byline = dict[@"byline"];
    self.address = [self shortAddressFromAddress:dict[@"address"]];
    self.creator = [FRSUser MR_createEntityInContext:context];
    
    if (dict[@"owner"] != Nil && ![dict[@"owner"] isEqual:[NSNull null]]) {
        self.creator.uid = dict[@"owner"][@"id"];
        self.creator.username = (dict[@"owner"][@"username"] != nil && ![dict[@"owner"][@"username"] isEqual:[NSNull null]]) ? dict[@"owner"][@"username"] : @"";
        
        self.creator.firstName = (dict[@"owner"][@"full_name"] != nil && ![dict[@"owner"][@"full_name"] isEqual:[NSNull null]]) ? dict[@"owner"][@"full_name"] : @"";
        
        self.creator.bio = (dict[@"owner"][@"bio"] != nil) ? dict[@"owner"][@"bio"] : @"";
    }

    if ([dict objectForKey:@"stream"] != [NSNull null]) {
        self.mediaType = @(1);
        self.videoUrl = [dict objectForKey:@"stream"];
    }
    
    if ([dict objectForKey:@"owner"] != [NSNull null] && [dict objectForKey:@"owner"]) {
        //self.creator = [FRSUser MR_createEntityInContext:context];
        self.creator.profileImage = [[dict objectForKey:@"owner"] objectForKey:@"avatar"];
    }
    
    NSNumber *height = dict[@"meta"][@"height"] ? : @0;
    NSNumber *width = dict[@"meta"][@"width"] ? : @0;
    
    self.meta = @{@"image_height" : height, @"image_width" : width};
    
    if (dict[@"created_at"] && ![dict[@"created_at"] isEqual:[NSNull null]]) {
        self.createdDate = [[FRSAPIClient sharedClient] dateFromString:dict[@"created_at"]];
    }
}

-(void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context save:(BOOL)save {
    self.uid = dict[@"id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    
    if (dict[@"image"] && ![dict[@"image"] isEqual:[NSNull null]]) {
        self.imageUrl = dict[@"image"];
    }
    
    self.byline = dict[@"byline"];
    self.address = [self shortAddressFromAddress:dict[@"address"]];
    
    self.creator = [FRSUser nonSavedUserWithProperties:dict[@"owner"] context:context];
    self.creator.uid = dict[@"owner"][@"id"];
    self.creator.username = (dict[@"owner"][@"username"] != Nil && ![dict[@"owner"][@"username"] isEqual:[NSNull null]]) ?dict[@"owner"][@"username"] : @"";
    self.creator.firstName = (dict[@"owner"][@"full_name"] != Nil && ![dict[@"owner"][@"full_name"] isEqual:[NSNull null]] && [[dict[@"owner"][@"full_name"] class] isSubclassOfClass:[NSString class]]) ? dict[@"owner"][@"full_name"] : @"";;
    self.creator.bio = (dict[@"owner"][@"bio"] != Nil) ? dict[@"owner"][@"bio"] : @"";

    if ([dict objectForKey:@"stream"] != [NSNull null]) {
        self.mediaType = @(1);
        self.videoUrl = [dict objectForKey:@"stream"];
    }
    
    if ([dict objectForKey:@"owner"] != [NSNull null] && [dict objectForKey:@"owner"]) {
        //self.creator = [FRSUser MR_createEntityInContext:context];
        self.creator.profileImage = [[dict objectForKey:@"owner"] objectForKey:@"avatar"];
    }
    
    NSNumber *height = dict[@"meta"][@"height"] ? : @0;
    NSNumber *width = dict[@"meta"][@"width"] ? : @0;
    
    self.meta = @{@"image_height" : height, @"image_width" : width};
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSPost *post = [FRSPost MR_createEntityInContext:context];
    post.currentContext = context;
    [post configureWithDictionary:properties context:context];
    return post;
}


-(NSString *)shortAddressFromAddress:(NSString *)address {
    if (!address || [address isEqual:[NSNull null]]) {
        return @"";
    }
    
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
        return address;
    }
    
    return str;
}

-(BOOL)checkVal:(id)val {
    if (val && ![val isEqual:[NSNull null]]) {
        return TRUE;
    }
    
    return FALSE;
}

/*
 
 @property (nullable, nonatomic, retain) NSString *address;
 @property (nullable, nonatomic, retain) NSString *byline;
 @property (nullable, nonatomic, retain) NSDate *createdDate;
 @property (nullable, nonatomic, retain) id image;
 @property (nullable, nonatomic, retain) NSString *imageUrl;
 @property (nullable, nonatomic, retain) NSNumber *mediaType;
 @property (nullable, nonatomic, retain) NSString *source;
 @property (nullable, nonatomic, retain) NSString *uid;
 @property (nullable, nonatomic, retain) NSString *videoUrl;
 @property (nullable, nonatomic, retain) NSString *visibility;
 @property (nullable, nonatomic, retain) id coordinates;
 @property (nullable, nonatomic, retain) id meta;
 @property (nullable, nonatomic, retain) FRSUser *creator;
 @property (nullable, nonatomic, retain) FRSGallery *gallery;
 
 */

-(NSDictionary *)jsonObject {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    if ([self checkVal:self.videoUrl]) {
        jsonObject[@"videoUrl"] = self.videoUrl;
    }
    
    if ([self checkVal:self.imageUrl]) {
        jsonObject[@"media_url"] = self.imageUrl;
    }
    else if ([self checkVal:self.videoUrl]) {
        jsonObject[@"media_url"] = self.videoUrl;
    }
    
    if ([self checkVal:self.createdDate]) {
        jsonObject[@"created_date"] = self.createdDate;
    }
    
    if ([self checkVal:self.coordinates]) {
        jsonObject[@"lat"] = self.coordinates[1];
        jsonObject[@"lng"] = self.coordinates[0]; 
    }
    
    
    return jsonObject;
}

@end
