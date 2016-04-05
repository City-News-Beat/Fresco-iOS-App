//
//  FRSCheckBox.m
//  fresco
//
//  Created by Philip Bernstein on 2/28/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSCheckBox.h"

@implementation FRSCheckBox
@synthesize selected = _selected;

-(void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_selected) {
        imageView.image = [UIImage imageNamed:@"picker-checkmark"];
    }
    else {
        imageView.image = [UIImage imageNamed:@"checkboxBlankCircleOutline24W2"];
    }
}

-(id)init {
    self = [super init];
    
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

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    imageView.image = [UIImage imageNamed:@"checkboxBlankCircleOutline24W2"];
    [self addSubview:imageView];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

@end
