//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLoginViewController.h"
#import "FRSAPIClient.h"

@interface FRSLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *usernameHighlightLine;
@property (weak, nonatomic) IBOutlet UIView *passwordHighlightLine;

@property (weak, nonatomic) IBOutlet UIButton *backArrowButton;

@end

@implementation FRSLoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.twitterButton.tintColor = [UIColor colorWithRed:0 green:0.675 blue:0.929 alpha:1]; /*Twitter Blue*/
    self.facebookButton.tintColor = [UIColor colorWithRed:0.231 green:0.349 blue:0.596 alpha:1]; /*Facebook Blue*/
    
    self.passwordField.tintColor = [UIColor frescoShadowColor];
    self.userField.tintColor = [UIColor frescoShadowColor];
    
    self.userField.delegate = self;
    self.passwordField.delegate = self;
    
    UIView *emailLine = [[UIView alloc] initWithFrame:CGRectMake(self.userField.frame.origin.x, self.userField.frame.origin.y, self.userField.frame.size.width, 1)];
    emailLine.backgroundColor = [UIColor frescoOrangeColor];
    [self.userField addSubview:emailLine];
    
    self.userField.tintColor = [UIColor frescoOrangeColor];
    self.passwordField.tintColor = [UIColor frescoOrangeColor];
    
    [self.userField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    self.loginButton.enabled = NO;

}

-(instancetype)init {
    self = [super initWithNibName:@"FRSLoginViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        
    }
    
    return self;
}
- (IBAction)returnToPreviousViewController:(id)sender {
    
 [self.navigationController popViewControllerAnimated:YES];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(IBAction)login:(id)sender {

}

-(IBAction)twitter:(id)sender {

    [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error) {
    }];
    
}

-(IBAction)facebook:(id)sender {
    
}

-(IBAction)next:(id)sender {
    [self.passwordField becomeFirstResponder];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.userField.editing) {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 40;
    }
    
    return YES;
}



-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.userField.editing) {

        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.usernameHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:nil];
        
        [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.passwordHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 0.5);
            
        } completion:nil];
    }
    
    
    if (self.passwordField.editing) {

        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.passwordHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.passwordHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:nil];
        
        [UIView animateWithDuration:.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 0.5);
            
        } completion:nil];
    }
}


-(void)textFieldDidChange:(UITextField *)textField {
    
    if (self.userField.text && self.userField.text.length > 0) {
        if (self.passwordField.text && self.passwordField.text.length >= 8) {
            
            self.loginButton.enabled = YES;
            
            /* Fade title color */
            [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.loginButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
            } completion:nil];
            
        } else if (self.passwordField.text && self.passwordField.text.length < 8) {
            
            self.loginButton.enabled = NO;
            
            /* Fade title color */
            [UIView transitionWithView:self.loginButton  duration:0.2 options: UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.loginButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
            } completion:nil];
        }
    }
}









@end
