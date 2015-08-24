//
//  UISocialButton.m
//  Fresco
//
//  Created by Elmir Kouliev on 8/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "UISocialButton.h"

@implementation UISocialButton

- (void)setUpSocialIcon:(SocialNetwork)network{
    
    self.layer.cornerRadius = 4;
    
    if(network == SocialNetworkFacebook){
    
        [self setImage: [UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        
    }
    else if(network == SocialNetworkTwitter){
    
        [self setImage: [UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        
    }
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

@end
