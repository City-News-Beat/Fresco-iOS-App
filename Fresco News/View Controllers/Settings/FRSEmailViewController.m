//
//  FRSEmailViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSEmailViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "FRSAPIClient.h"
#import "FRSAlertView.h"

@interface FRSEmailViewController()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) FRSTableViewCell *cell;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property BOOL emailIsValid;
@property BOOL passwordIsValid;

@property (strong, nonatomic) FRSAlertView *alert;

@end

@implementation FRSEmailViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}

-(void)configureTableView{
    self.title = @"EMAIL ADDRESS";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;
    self.cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (self.cell == nil) {
        self.cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([self.cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self.cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([self.cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return self.cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell = self.cell;
    
    switch (indexPath.row) {
        case 0:
            [cell configureEditableCellWithDefaultText:@"New email" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeEmailAddress];
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.returnKeyType = UIReturnKeyNext;
            break;
            
        case 1:
            [cell configureEditableCellWithDefaultText:@"Password" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeDefault];
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.returnKeyType = UIReturnKeyDone;
            break;
        
        case 2:
            [cell configureCellWithRightAlignedButtonTitle:@"SAVE EMAIL" withWidth:109 withColor:[UIColor frescoLightTextColor]];
            [cell.rightAlignedButton addTarget:self action:@selector(saveEmail) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        default:
            break;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

-(void)saveEmail {
    [[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"email":self.email} completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate reloadUser];
        
        if (!error && responseObject) {
            FRSUser *userToUpdate = [[FRSAPIClient sharedClient] authenticatedUser];
            userToUpdate.email = self.email;
            [[[FRSAPIClient sharedClient] managedObjectContext] save:Nil];
            
            [self popViewController];
        } else if (error.code == -1009) {
            if (!self.alert) {
                self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to connect to the internet." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:self];
                [self.alert show];
            }
        } else if (error){
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Email is already taken." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:self];
            [alert show];
        }
    }];
}

#pragma mark - TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    
    if (textField.isSecureTextEntry) {
        //User is editing password textField
        self.password = textField.text;
        if ([self isValidPassword:self.password]) {
            NSLog(@"PASSWORD IS VALID");
            self.passwordIsValid = YES;
        } else {
            NSLog(@"PASSWORD IS INVALID");
            self.passwordIsValid = NO;
        }
        
    } else {
        //User is editing email textField
        self.email = textField.text;
        if ([self isValidEmail:self.email]) {
            NSLog(@"EMAIL IS VALID");
            self.emailIsValid = YES;
        } else {
            NSLog(@"EMAIL IS INVALID");
            self.emailIsValid = NO;
        }
    }
    
    if (self.emailIsValid && self.passwordIsValid) {
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = YES;
    } else {
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField.isSecureTextEntry) {
        [textField resignFirstResponder];
        [self saveEmail];
    }
    
    return YES;
}


#pragma mark - Validators

-(BOOL)isValidEmail:(NSString *)emailString {
    
    if([emailString length] == 0) {
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)isValidPassword:(NSString *)password {
    
    if (password.length < 8) {
        return NO;
    }
    
    return YES;
}


@end
