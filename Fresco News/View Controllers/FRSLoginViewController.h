//
//  FRSLoginViewController.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface FRSLoginViewController : FRSBaseViewController

@property (nonatomic, retain) IBOutlet UIImageView *logoView;
@property (nonatomic, retain) IBOutlet UIButton *backButton;

@property (nonatomic, retain) IBOutlet UITextField *userField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIView *usernameHighlightLine;
@property (weak, nonatomic) IBOutlet UIView *passwordHighlightLine;

@property (nonatomic, retain) IBOutlet UIButton *loginButton;

@property (nonatomic, retain) IBOutlet UIButton *twitterButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet UIButton *passwordHelpButton;

-(IBAction)login:(id)sender;
-(IBAction)twitter:(id)sender;
-(IBAction)facebook:(id)sender;
-(IBAction)next:(id)sender;

@end
