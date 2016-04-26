//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLoginViewController.h"

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
    
    self.passwordField.tintColor = [UIColor frescoOrangeColor];
    self.userField.tintColor = [UIColor frescoOrangeColor];
    
    self.userField.delegate = self;
    self.passwordField.delegate = self;
    
    
    UIView *emailLine = [[UIView alloc] initWithFrame:CGRectMake(self.userField.frame.origin.x, self.userField.frame.origin.y, self.userField.frame.size.width, 1)];
    emailLine.backgroundColor = [UIColor frescoOrangeColor];
    [self.userField addSubview:emailLine];
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
    
}

-(IBAction)facebook:(id)sender {
    
}

-(IBAction)next:(id)sender {
    [self.passwordField becomeFirstResponder];
}


#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.userField.editing) {
        NSLog(@"userfield");
        self.usernameHighlightLine.alpha = 1;
        self.passwordHighlightLine.alpha = 0;
    }
    
    if (self.passwordField.editing) {
        NSLog(@"passfield");
        self.passwordHighlightLine.alpha = 1;
        self.usernameHighlightLine.alpha = 0;
    }
}













@end
