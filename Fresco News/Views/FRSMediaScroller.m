//
//  FRSMediaScroller.m
//  Fresco
//
//  Created by Philip Bernstein on 4/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSMediaScroller.h"

@implementation FRSMediaScroller

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {

}
@end
