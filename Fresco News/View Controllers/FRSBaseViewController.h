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

/* Spinner */

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

/**
 *  View controller index, for uses in a UIPageViewController
 */
@property (assign, nonatomic) NSInteger index;

/*
** Navigation Methods
*/

- (void)navigateToMainApp;

- (void)navigateToFirstRun;

- (void)navigateToCamera;

/**
 *  Method to send us out of view controller after logging in
 */

- (void)transferUser;

/**
 *  Login Method, takes a LoginType to perform repsective login i.e. facebook, twitter, regular login (fresco)
 *
 *  @param login  Type of login
 *  @param button The button eing selected
 *  @param info   The email/pass dictionairy if Fresco login
 */
- (void)performLogin:(LoginType)login button:(UIButton *)button withLoginInfo:(NSDictionary *)info;

@end
