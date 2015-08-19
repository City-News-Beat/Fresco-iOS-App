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

-(void)setStory:(FRSStory *)story{

    _story = story;
    
    if([story.thumbnails count]){
        
        if(_story.editedTime != nil)
            self.labelTimestamp.text = [MTLModel relativeDateStringFromDate:_story.editedTime];
        else
            self.labelTimestamp.text = @"";

    }
    else
        self.labelTimestamp.text = @"";
    
    self.labelTitle.text = _story.title;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    gesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gesture];
    
    //Disabled blur effects
//    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
//    [viewWithBlurredBackground setFrame:self.frame];
//    
//    [self addSubview:viewWithBlurredBackground];
//    [self sendSubviewToBack:viewWithBlurredBackground];
//    self.backgroundColor = [UIColor clearColor];

}

#pragma mark - UITapGestureRecognizer Selector

- (void)handleTapGesture:(id)sender{
    
    [self.tapHandler tappedStoryHeader:self.story];
    
}
    


@end
