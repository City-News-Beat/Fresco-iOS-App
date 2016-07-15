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
    [self addSubview:frog];
    
    UILabel *awkwardLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -121/2, 72, 121, 33)];
    awkwardLabel.text = @"Awkward.";
    awkwardLabel.font = [UIFont karminaBoldWithSize:28];
    awkwardLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:awkwardLabel];
    
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 175/2, 106, 175, 20)];
    self.messageLabel.text = @"There’s nothing here yet.";
    self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.messageLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:self.messageLabel];
}














@end
