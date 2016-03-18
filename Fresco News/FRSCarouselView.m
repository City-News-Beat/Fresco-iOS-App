//
//  FRSCarouselView.m
//  Fresco
//
//  Created by Philip Bernstein on 3/17/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSCarouselView.h"

@implementation FRSCarouselView

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
    imageViews = [[NSMutableArray alloc] init];
    videoPlayers = [[NSMutableArray alloc] init];
}

-(void)loadContent:(NSArray *)content {
    
}

-(UIImage *)fetchOrPullFromCache:(NSString *)fileURL { // move to haneke category?
    
    // pull from disk : nil == pull from network
    
    // return image
    return Nil;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // handle frame change
}

@end
