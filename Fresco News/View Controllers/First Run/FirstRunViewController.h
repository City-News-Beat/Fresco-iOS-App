//
//  FirstRunViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@interface FirstRunViewController : FRSBaseViewController

/**
 *  Passed over the Account VC to display email field
 */

@property (nonatomic, strong) NSString *email;

/**
 *  Passed over to Account VC to display password field
 */

@property (nonatomic, strong) NSString *password;

@end
