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
    

    self.imageStringURL = (dictionary[@"favicon"] && [dictionary[@"favicon"] isEqual:[NSNull null]]) ? @"" : dictionary[@"favicon"];
    self.articleStringURL = (dictionary[@"link"] && [dictionary[@"link"] isEqual:[NSNull null]]) ?dictionary[@"link"] : @"";
    
    if (dictionary[@"title"] && ![dictionary[@"title"] isEqual:[NSNull null]]) {
        self.title = dictionary[@"title"];
    }
    else {
        self.title = self.articleStringURL;
    }
    
    self.source = (dictionary[@"source"] && [dictionary[@"source"] isEqual:[NSNull null]]) ? dictionary[@"source"] : @"";
    self.uid = (dictionary[@"source"] && [dictionary[@"source"] isEqual:[NSNull null]]) ? dictionary[@"id"] : @"";
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
