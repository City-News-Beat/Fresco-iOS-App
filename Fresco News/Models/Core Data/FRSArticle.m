//
//  FRSArticle.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSArticle.h"

#import "FRSDateFormatter.h"

#import <MagicalRecord/MagicalRecord.h>

@implementation FRSArticle

+(instancetype)articleWithDictionary:(NSDictionary *)dictionary{
    FRSArticle *article = [FRSArticle MR_createEntity];
    [article configureWithDictionary:dictionary];
    return article;
}


-(void)configureWithDictionary:(NSDictionary *)dictionary{
    self.title = dictionary[@"title"];
    self.imageStringURL = dictionary[@"favicon"];
    self.articleStringURL = dictionary[@"link"];
    self.source = dictionary[@"source"];
    self.uid = dictionary[@"_id"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dictionary[@"time_created"] milliseconds:YES];
}
// Insert code here to add functionality to your managed object subclass

@end
