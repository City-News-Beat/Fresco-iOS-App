//
//  StoryCellMosaicHeader.m
//  FrescoNews
//
//  Created by Fresco News on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryCellMosaicHeader.h"
#import "FRSStory.h"
#import "FRSPost.h"
#import "MTLModel+Additions.h"

static NSString * const kCellIdentifier = @"StoryCellMosaicHeader";

@interface StoryCellMosaicHeader()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (weak, nonatomic) IBOutlet UILabel *labelTimestamp;

@end

@implementation StoryCellMosaicHeader

+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)populateViewWithStory:(FRSStory *)story
{
    self.labelTitle.text = story.title;
    
    if([story.thumbnails count]){
        
        self.labelTimestamp.text = [MTLModel relativeDateStringFromDate:((FRSPost *)story.thumbnails[0]).date];
    }
    
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
    [viewWithBlurredBackground setFrame:self.frame];
    
    [self addSubview:viewWithBlurredBackground];
    [self sendSubviewToBack:viewWithBlurredBackground];
    self.backgroundColor = [UIColor clearColor];
    
}
@end
