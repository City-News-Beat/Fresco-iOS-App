//
//  FRSReusableGalleryView.m
//  Fresco
//
//  Created by Philip Bernstein on 3/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSReusableGalleryView.h"
#import "FRSCarouselView.h"

@implementation FRSReusableGalleryView

-(id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {

}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // handle frame change
}

@end
