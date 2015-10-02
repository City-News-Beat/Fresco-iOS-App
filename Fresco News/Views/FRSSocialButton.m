//
//  UISocialButton.m
//  Fresco
//
//  Created by Elmir Kouliev on 8/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSSocialButton.h"

@implementation FRSSocialButton

+ (FRSSocialButton *)createSocialButton:(SocialNetwork)network{
    
    FRSSocialButton *button = [FRSSocialButton buttonWithType:UIButtonTypeSystem];
    
    [button setUpSocialIcon:network withRadius:YES];
    
    return button;
    
}


- (void)setUpSocialIcon:(SocialNetwork)network withRadius:(BOOL)radius{
    
    if(radius)
        self.layer.cornerRadius = 4;
    
    self.clipsToBounds = YES;
    
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
