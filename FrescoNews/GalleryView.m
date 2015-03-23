//
//  GalleryView.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryView.h"
#import "UIView+Additions.h"

@interface GalleryView ()
@property (nonatomic, assign) BOOL nibIsLoaded;
@end
@implementation GalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithFrame:CGRectZero];
    return self;
    
    //if (self.nibIsLoaded) return self;
    //Class class = [self class];
    //NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"GalleryView" owner:self options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    //self = [super initWithCoder:aDecoder];
  //  self.nibIsLoaded = YES;
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

@end
