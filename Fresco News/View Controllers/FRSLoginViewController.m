//
//  FRSLoginViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSLoginViewController.h"

@interface FRSLoginViewController ()

@end

@implementation FRSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)init {
    self = [super initWithNibName:@"FRSLoginViewController" bundle:[NSBundle mainBundle]];
    
    if (self) {
        
    }
    
    return self;
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
