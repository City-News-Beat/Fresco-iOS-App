//
//  FRSGallery.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSStory.h"
#import "FRSUser.h"

#import "FRSDataValidator.h"

@implementation FRSGallery

-(void)configureWithDictionary:(NSDictionary *)dict{
    if ([FRSDataValidator isNonNullObject:dict]){
        self.uid = dict[@"_id"];
        self.visibility = dict[@"visiblity"];
        self.createdDate = dict[@"time_created"];
        self.caption = dict[@"caption"];
        self.byline = dict[@"byline"];
    }
}

// Insert code here to add functionality to your managed object subclass

@end
