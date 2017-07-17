//
//  FRSUsernameTableViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAssignmentTitleViewController.h"
#import "UIColor+Fresco.h"
#import "FRSAssignmentTypeViewController.h"

@interface FRSAssignmentTitleViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) NSTimer *usernameTimer;
@property (nonatomic) BOOL usernameTaken;

@end

@implementation FRSAssignmentTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.usernameTextField.delegate = self;
    
    [self.usernameTextField becomeFirstResponder];
}


- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"TITLE";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setTitleView:label];
    
    self.usernameTextField.text = self.assignment[@"title"];
}



#pragma mark - Actions

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *title = self.usernameTextField.text;
    
    
    NSMutableDictionary *mutableDict = [self.assignment mutableCopy];
    [mutableDict setObject:title forKey:@"title"];
    self.assignment = [mutableDict mutableCopy];
    
    FRSAssignmentTypeViewController *assignmentType = [FRSAssignmentTypeViewController new];
    assignmentType.assignment = self.assignment;
    [self.navigationController pushViewController:assignmentType animated:YES];
    
    return YES;
}

@end
