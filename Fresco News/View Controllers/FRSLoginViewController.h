//
//  FRSLoginViewController.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSLoginViewController : UIViewController
{
    
}

@property (nonatomic, retain) IBOutlet UITextField *userField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

@property (nonatomic, retain) IBOutlet UIImageView *logoView;

@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

@property (nonatomic, retain) IBOutlet UIButton *twitterButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UILabel *socialLabel;


@end

