//
//  FRSSignUpViewController.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "FRSAPIClient.h"

@interface FRSSignUpViewController : FRSBaseViewController
@property TWTRSession *twitterSession;
@property FBSDKAccessToken *facebookToken;
@property (nonatomic, retain) UIButton *facebookButton;
@property (nonatomic, retain) UIButton *twitterButton;
@end
