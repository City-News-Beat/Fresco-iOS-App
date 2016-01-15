//
//  FRSDebitCardViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDebitCardViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"

@interface FRSDebitCardViewController() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSDebitCardViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureView];
    
}


-(void)configureView{
    
    UIView *cardViewport = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - 44)];
    cardViewport.backgroundColor = [UIColor redColor];
    cardViewport.alpha = 0.2;
    [self.view addSubview:cardViewport];
    
    [cardViewport addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, cardViewport.frame.size.height, self.view.frame.size.width, 88)];
    container.backgroundColor = [UIColor colorWithWhite:1 alpha:.92];
    [self.view addSubview:container];
    
    UITextField *cardNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    cardNumberTextField  = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - (32), 44)];
    cardNumberTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    cardNumberTextField.placeholder =  @"0000 0000 0000 0000";
    cardNumberTextField.textColor = [UIColor frescoDarkTextColor];
    cardNumberTextField.tintColor = [UIColor frescoBlueColor];
    [container addSubview:cardNumberTextField];
    
    cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    [cardNumberTextField setSecureTextEntry: YES];
    
    
    UITextField *expirationDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    expirationDateTextField  = [[UITextField alloc] initWithFrame:CGRectMake(16, 44, [UIScreen mainScreen].bounds.size.width/2, 44)];
    expirationDateTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    expirationDateTextField.placeholder =  @"00 / 00";
    expirationDateTextField.textColor = [UIColor frescoDarkTextColor];
    expirationDateTextField.tintColor = [UIColor frescoBlueColor];
    [container addSubview:expirationDateTextField];
    
    expirationDateTextField.keyboardType = UIKeyboardTypeNumberPad;

    
    UITextField *securityCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    securityCodeTextField  = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 , 44, [UIScreen mainScreen].bounds.size.width/2, 44)];
    securityCodeTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    securityCodeTextField.placeholder =  @"CVV";
    securityCodeTextField.textColor = [UIColor frescoDarkTextColor];
    securityCodeTextField.tintColor = [UIColor frescoBlueColor];
    [container addSubview:securityCodeTextField];
    
    securityCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    
    
    UIImageView *cardNumberCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptedNot"]];
    cardNumberCheckIV.frame = CGRectMake(self.view.frame.size.width - 30, 10, 24, 24);
    [container addSubview:cardNumberCheckIV];
    
    UIImageView *expirationDateCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptedNot"]];
    expirationDateCheckIV.frame = CGRectMake(self.view.frame.size.width/2 - 24 - 16, 54, 24, 24);
    [container addSubview:expirationDateCheckIV];
    
    UIImageView *CVVcheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptedNot"]];
    CVVcheckIV.frame = CGRectMake(self.view.frame.size.width - 30, 54, 24, 24);
    [container addSubview:CVVcheckIV];
    
    
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    top.alpha = 1;
    top.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:top];
    
    UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 0.5)];
    middle.alpha = 1;
    middle.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:middle];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 88, self.view.bounds.size.width, 0.5)];
    bottom.alpha = 1;
    bottom.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:bottom];
    
    UIButton *rightAlignedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightAlignedButton.frame =CGRectMake(self.view.frame.size.width - 105, cardViewport.frame.size.height + 88, 105, 44);
    [rightAlignedButton setTitle:@"SAVE CARD" forState:UIControlStateNormal];
    [rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    
    [self.view addSubview:rightAlignedButton];
    
}


@end