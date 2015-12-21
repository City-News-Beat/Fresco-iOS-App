//
//  FRSSignUpViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSignUpViewController.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

@interface FRSSignUpViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *usernameTF;
@property (strong, nonatomic) UITextField *emailTF;
@property (strong, nonatomic) UITextField *passwordTF;

@end

@implementation FRSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    
    // Do any additional setup after loading the view.
}

#pragma mark - UI 

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureScrollView];
    [self configureTextFields];
    
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] init
WithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 44)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.scrollView];
}

-(void)configureTextFields{
    [self configureUserNameField];
    [self configureEmailAddressField];
    [self configurePasswordField];
}

-(void)configureUserNameField{
    self.usernameTF = [[UITextField alloc] initWithFrame:CGRectMake(48, 24, self.scrollView.frame.size.width - 2 * 48, 44)];
    self.usernameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"@username" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont notaMediumWithSize:17]}];
    self.usernameTF.
}

-(void)configureEmailAddressField{
    
}

-(void)configurePasswordField{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
