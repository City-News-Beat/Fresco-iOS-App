//
//  FRSBaseViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/7/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
#import "FRSBackButton.h"

typedef enum : NSUInteger {
    LoginFresco,
    LoginFacebook,
    LoginTwitter
} LoginType;

@interface FRSBaseViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *galleries;

/* Spinner */

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

/*
** Navigation Methods
*/

- (void)navigateToMainApp;

- (void)navigateToFirstRun;

- (void)navigateToCamera;

- (void)transferUser;

- (void)performLogin:(LoginType)login button:(UIButton *)button withLoginInfo:(NSDictionary *)info;

@end
