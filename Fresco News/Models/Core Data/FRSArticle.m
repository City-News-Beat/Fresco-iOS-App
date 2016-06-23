//
//  FRSArticle.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSArticle.h"

#import "FRSDateFormatter.h"

#import "MagicalRecord.h"

#import "FRSCoreData.h"

@implementation FRSArticle

+(instancetype)articleWithDictionary:(NSDictionary *)dictionary{
    FRSArticle *article = [FRSArticle MR_createEntity];
    [article configureWithDictionary:dictionary];
    return article;
}


-(void)configureWithDictionary:(NSDictionary *)dictionary{
    //CHECK FOR RELEASE data validation especially favicon
    
    self.title = dictionary[@"title"];
    self.imageStringURL = [dictionary[@"favicon"] isEqual:[NSNull null]] ? @"" : dictionary[@"favicon"];
    self.articleStringURL = dictionary[@"link"];
    self.source = dictionary[@"source"];
    self.uid = dictionary[@"_id"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dictionary[@"time_created"] milliseconds:YES];
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSArticle *article = [NSEntityDescription insertNewObjectForEntityForName:@"FRSArticle" inManagedObjectContext:context];
    [article configureWithDictionary:properties];
    return article;
}
-(NSDictionary *)jsonObject {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    
    
    return jsonObject;
}
// Insert code here to add functionality to your managed object subclass

@end
