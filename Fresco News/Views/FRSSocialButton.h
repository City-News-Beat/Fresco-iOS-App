//
//  UISocialButton.h
//  Fresco
//
//  Created by Elmir Kouliev on 8/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SocialNetworkFacebook,
    SocialNetworkTwitter
} SocialNetwork;

@interface FRSSocialButton : UIButton

//- (void)setUpSocialIcon:(SocialNetwork)network withRadius:(BOOL)radius;

+ (FRSSocialButton *)createSocialButton:(SocialNetwork)network;
- (void)setUpSocialIcon:(SocialNetwork)network withRadius:(BOOL)radius;
@end
