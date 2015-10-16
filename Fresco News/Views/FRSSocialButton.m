//
//  UISocialButton.m
//  Fresco
//
//  Created by Elmir Kouliev on 8/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSSocialButton.h"

@implementation FRSSocialButton

+ (UISocialButton *)createSocialButton{

    UISocialButton *button = [UISocialButton buttonWithType:UIButtonTypeSystem];

    return button;

}

- (void)setUpSocialIcon:(SocialNetwork)network withRadius:(BOOL)radius{
    
    if(radius)
        self.layer.cornerRadius = 4;
    
    self.clipsToBounds = YES;
    self.tintColor = [UIColor whiteColor];
    
    if(network == SocialNetworkFacebook){
    
        [self setImage: [UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        
    }
    else if(network == SocialNetworkTwitter){
    
        [self setImage: [UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        
    }
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [super setSelected:YES];
        self.alpha = 1.0;
    }
    else {
        [super setSelected:NO];
        self.alpha = 0.4;
    }
}


@end
