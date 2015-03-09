//
//  StoryCellHeader.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryCellHeader.h"
#import "FRSTag.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString * const kCellIdentifier = @"StoryCellHeader";

@implementation StoryCellHeader
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)populateViewWithStory:(FRSTag *)tag
{
    self.labelTitle.text = tag.identifier;
}
@end
