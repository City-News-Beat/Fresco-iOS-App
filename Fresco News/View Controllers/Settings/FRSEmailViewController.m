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

@interface FRSEmailViewController()

@property (strong, nonatomic) FRSTableViewCell *cell;
@property (strong, nonatomic) FRSAlertView *alert;
@property (strong, nonatomic) UIImageView *errorImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@property BOOL emailIsValid;
@property BOOL passwordIsValid;

@end


@implementation FRSEmailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}

-(void)configureTableView {
    
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


#pragma mark - UITableView

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
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
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



#pragma mark - Actions

-(void)saveEmail {
    
    [self.view endEditing:YES];
    
    [[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"email":self.email, @"verify_password" : self.password} completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate reloadUser];
        
        if (!error && responseObject) {
            FRSUser *userToUpdate = [[FRSAPIClient sharedClient] authenticatedUser];
            userToUpdate.email = self.email;
            [[[FRSAPIClient sharedClient] managedObjectContext] save:Nil];
            
            [self popViewController];
            return;
        }
        
        if (error.code == -1009) {
            NSLog(@"Unable to connect.");
            if (!self.alert) {
                NSString *title = @"";
                
                if (IS_IPHONE_5) {
                    title = @"UNABLE TO CONNECT";
                } else if (IS_IPHONE_6) {
                    title = @"UNABLE TO CONNECT. CHECK SIGNAL";
                } else if (IS_IPHONE_6_PLUS) {
                    title = @"UNABLE TO CONNECT. CHECK YOUR SIGNAL";
                }
                
                if (!self.alert) {
                    self.alert = [[FRSAlertView alloc] initBannerWithTitle:title backButton:YES];
                    [self.alert show];
                }
            }
            return;
        }
        
        NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
        NSInteger responseCode = response.statusCode;
        NSLog(@"ERROR: %ld", (long)responseCode);
        
        if (responseCode >= 400 && responseCode < 500) {
            // 400 level, client
            if (responseCode == 403) {
                if (!self.errorImageView) {
                    [self addErrorToView];
                }
            } else {
                self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"An account already exists with this username. Would you like to log in?" actionTitle:@"CANCEL" cancelTitle:@"LOGIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
                [self.alert show];
            }
            
            return;
        }
        else if (responseCode >= 500 && responseCode < 600) {
            // 500 level, server
            self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to reach server. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
            [self.alert show];
            return;
        }
        else {
            //generic error
        }
    }];
}



#pragma mark - TextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.isSecureTextEntry) {
        if (self.errorImageView) {
            textField.text = 0;
            self.errorImageView.alpha = 0;
            self.errorImageView = nil;
            [self.errorImageView removeFromSuperview];
        }
    }
}

-(void)addErrorToView {
    if (!self.errorImageView) {
        self.errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.errorImageView.frame = CGRectMake(self.view.frame.size.width - 34, 55, 24, 24);
        self.errorImageView.alpha = 1; // 0 when animating
        [self.view addSubview:self.errorImageView];
        
        [self.cell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cell.rightAlignedButton.userInteractionEnabled = NO;
    }
}

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



#pragma mark - FRSAlertView Delegate

-(void)didPressButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
