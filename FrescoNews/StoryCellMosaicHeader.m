//
//  StoryCellMosaicHeader.m
//  FrescoNews
//
//  Created by Fresco News on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryCellMosaicHeader.h"
#import "FRSStory.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString * const kCellIdentifier = @"StoryCellMosaicHeader";

@implementation StoryCellMosaicHeader
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)populateViewWithStory:(FRSStory *)story
{
    self.labelTitle.text = story.title;
}
@end
