//
//  FirstRunAccountViewController.h
//  FrescoNews
//
//  Created by Fresco News on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@interface FirstRunAccountViewController : FRSBaseViewController

@property (nonatomic) NSString *email;

@property (nonatomic) NSString *password;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@end
