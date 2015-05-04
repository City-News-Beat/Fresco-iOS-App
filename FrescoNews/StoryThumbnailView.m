//
//  StoryThumbnailView.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryThumbnailView.h"

@implementation StoryThumbnailView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __FUNCTION__);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __FUNCTION__);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __FUNCTION__);
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        self.image = nil;
        return;
    }
}*/
@end
