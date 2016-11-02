//
//  FRSWobbleView.m
//  Fresco
//
//  Created by Philip Bernstein on 11/2/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSWobbleView.h"
#import "UIColor+Fresco.h"

@implementation FRSWobbleView
@synthesize handImage = _handImage, imageView = _imageView;

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
    self.backgroundColor = [UIColor whiteColor];
    [self setOpaque:TRUE];
    self.layer.masksToBounds = FALSE;
    self.layer.cornerRadius = 20;
    self.userInteractionEnabled = FALSE; // prevent stopping tap to focus
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 8, 24, 24)];
    [self addSubview:self.imageView];
    
    self.handImage = [UIImage imageNamed:@"fast"];
    self.imageView.image = self.handImage;
    
    self.warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 10, 85, 20)];
    self.warningLabel.textAlignment = NSTextAlignmentCenter;
    self.warningLabel.text = @"Pan slower";
    self.warningLabel.textColor = [UIColor frescoDarkTextColor];
    self.warningLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.warningLabel];
    self.frame = CGRectMake(0, 0, 148, 40);
    
    self.backingView = [[UIView alloc] initWithFrame:CGRectMake(-200, -200, 1000, 1000)];
    [self addSubview:self.backingView];
    [self sendSubviewToBack:self.backingView];
}

-(void)configureForWobble {
    self.handImage = [UIImage imageNamed:@"hold"];
    self.imageView.image = self.handImage;
    self.imageView.frame = CGRectMake(16, 0, 74, 38);
    
    self.warningLabel.frame = CGRectMake(87, 10, 167, 20);
    self.warningLabel.text = @"Hold your phone steady";
    self.frame = CGRectMake(0, 0, 281, 40);
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

@end
