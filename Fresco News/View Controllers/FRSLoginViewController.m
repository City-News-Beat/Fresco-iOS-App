//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLoginViewController.h"

@interface FRSLoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backArrowButton;

@end

@implementation FRSLoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.twitterButton.tintColor = [UIColor colorWithRed:0 green:0.675 blue:0.929 alpha:1]; /*Twitter Blue*/
    self.facebookButton.tintColor = [UIColor colorWithRed:0.231 green:0.349 blue:0.596 alpha:1]; /*Facebook Blue*/
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
