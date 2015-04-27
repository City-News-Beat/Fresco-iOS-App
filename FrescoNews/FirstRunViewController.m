//
//  FirstRunViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunViewController.h"

@interface FirstRunViewController ()

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation FirstRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self styleButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)styleButtons {
    self.twitterButton.layer.cornerRadius = 8;
    self.twitterButton.clipsToBounds = YES;
    
    self.facebookButton.layer.cornerRadius = 8;
    self.facebookButton.clipsToBounds = YES;
    
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    
    self.signUpButton.layer.cornerRadius = 8;
    self.signUpButton.clipsToBounds = YES;
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
