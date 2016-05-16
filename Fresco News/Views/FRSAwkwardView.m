//
//  FRSAwkwardView.m
//  Fresco
//
//  Created by Omar Elfanek on 5/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAwkwardView.h"
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"

@implementation FRSAwkwardView


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self configureView];
    }
    return self;
}

-(void)configureView {

    UIImageView *frog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frog"]];
    frog.frame = CGRectMake(self.frame.size.width/2 -72/2, 0, 72, 72);
    frog.backgroundColor = [UIColor frescoShadowColor];
    [self addSubview:frog];
    
    UILabel *awkwardLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -121/2, 72, 121, 33)];
    awkwardLabel.text = @"Awkward.";
    awkwardLabel.font = [UIFont karminaBoldWithSize:28];
    awkwardLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:awkwardLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 175/2, 106, 175, 20)];
    subLabel.text = @"There’s nothing here yet.";
    subLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    subLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:subLabel];
}















@end
