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

@interface UISocialButton : UIButton

- (void)setUpSocialIcon:(SocialNetwork)network;

@end
