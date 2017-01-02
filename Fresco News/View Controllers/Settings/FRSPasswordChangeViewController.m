 
//
//  FRSPasswordChangeViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPasswordChangeViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "FRSAPIClient.h"
#import "FRSAlertView.h"
#import "FRSAppDelegate.h"

@interface FRSPasswordChangeViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) FRSTableViewCell *currentPasswordCell;
@property (strong, nonatomic) FRSTableViewCell *updatedPasswordCell;
@property (strong, nonatomic) FRSTableViewCell *updatedPasswordVerifyCell;
@property (strong, nonatomic) FRSTableViewCell *buttonCell;

@property (strong, nonatomic) NSString *currentPassword;
@property (strong, nonatomic) NSString *updatedPassword;
@property (strong, nonatomic) NSString *updatedPasswordVerify;

@property (strong, nonatomic) FRSAlertView *alert;

@property (strong, nonatomic) UIImageView *errorImageView;

@property BOOL currentPasswordIsValid;
@property BOOL updatedPasswordIsValid;
@property BOOL updatedPasswordVerifyIsValid;

@property (strong, nonatomic) UITextField *passwordVerifyTextField;
@property (strong, nonatomic) UITextField *passwordTwoTextField;

@end

@implementation FRSPasswordChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTableView];
    [self configureBackButtonAnimated:NO];

    self.currentPasswordIsValid = NO;
    self.updatedPasswordIsValid = NO;
    self.updatedPasswordVerifyIsValid = NO;
}

- (void)configureTableView {
    self.title = @"PASSWORD";

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
    case 0:
        self.currentPasswordCell = cell;
        cell.textField.delegate = self;
        [cell configureEditableCellWithDefaultText:@"Current password" withTopSeperator:YES withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeDefault];
        [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
        cell.textField.tag = 1;
        cell.textField.delegate = self;
        cell.textField.returnKeyType = UIReturnKeyNext;
        break;

    case 1:
        self.updatedPasswordCell = cell;
        cell.textField.delegate = self;
        [cell configureEditableCellWithDefaultText:@"New password" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeDefault];
        [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
        cell.textField.tag = 2;
        cell.textField.delegate = self;
        cell.textField.returnKeyType = UIReturnKeyNext;
        self.passwordTwoTextField = cell.textField;

        break;

    case 2:
        self.updatedPasswordVerifyCell = cell;
        cell.textField.delegate = self;
        [cell configureEditableCellWithDefaultText:@"Confirm new password" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeDefault];
        [cell.textField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
        cell.textField.tag = 3;
        cell.textField.delegate = self;
        cell.textField.returnKeyType = UIReturnKeyDone;
        self.passwordVerifyTextField = cell.textField;

        break;

    case 3:
        self.buttonCell = cell;
        [cell configureCellWithRightAlignedButtonTitle:@"SAVE PASSWORD" withWidth:143 withColor:[UIColor frescoLightTextColor]];
        [cell.rightAlignedButton addTarget:self action:@selector(savePassword) forControlEvents:UIControlEventTouchUpInside];
        break;

    default:
        break;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {

    //Match strings to proper textfield.text
    if (textField.tag == 1) {
        self.currentPassword = textField.text;
    } else if (textField.tag == 2) {
        self.updatedPassword = textField.text;
    } else if (textField.tag == 3) {
        self.updatedPasswordVerify = textField.text;
    }

    //If passwords are invalid, do not continue
    if (![self isValidPassword:self.currentPassword] || ![self isValidPassword:self.updatedPassword] || ![self isValidPassword:self.updatedPasswordVerify]) {
        [self.buttonCell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.buttonCell.rightAlignedButton.userInteractionEnabled = NO;
        return YES;
    }

    [self.buttonCell.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    self.buttonCell.rightAlignedButton.userInteractionEnabled = YES;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    FRSTableViewCell *currentCell = (FRSTableViewCell *)textField.superview.superview;
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];

    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
    FRSTableViewCell *nextCell = (FRSTableViewCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];

    [nextCell.textField becomeFirstResponder];

    if (textField == self.passwordTwoTextField) {
        [self.passwordVerifyTextField becomeFirstResponder];
    } else if (textField == self.passwordVerifyTextField) {
        [self.passwordVerifyTextField resignFirstResponder];
        [self.view endEditing:YES];
        [self updatedPassword];
    }

    return NO;
}

#pragma mark - Validators

- (BOOL)isValidPassword:(NSString *)password {
    if (password.length < 7) {
        return NO;
    }

    return YES;
}

#pragma mark - Actions

- (void)savePassword {

    [self.view endEditing:YES];

    if ((![self.updatedPassword isEqualToString:self.updatedPasswordVerify])) {
        //        if (!self.alert) {
        self.alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"New passwords do not match." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
        [self.alert show];
        //        }
        return;
    }

    NSDictionary *digestion = @{ @"verify_password" : self.currentPassword,
                                 @"password" : self.updatedPassword };

    [[FRSAPIClient sharedClient] updateUserWithDigestion:digestion
                                              completion:^(id responseObject, NSError *error) {
                                                FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                [delegate reloadUser];

                                                if (!error) {
                                                    [self popViewController];
                                                    return;
                                                }

                                                if (error) {
                                                    if (error.code == -1009) {
                                                        self.alert = [[FRSAlertView alloc] initNoConnectionAlert];
                                                        [self.alert show];
                                                        return;
                                                    }

                                                    NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                    NSInteger responseCode = response.statusCode;

                                                    if (responseCode == 403 || responseCode == 401) {
                                                        if (!self.errorImageView) {
                                                            [self addErrorToView];
                                                            return;
                                                        }
                                                    } else if (responseCode >= 300 && responseCode < 600) {
                                                        // 500 level, server
                                                        if (!self.alert) {
                                                            [self presentGenericError];
                                                        }

                                                        return;
                                                    }
                                                }
                                              }];

    FRSUser *userToUpdate = [[FRSAPIClient sharedClient] authenticatedUser];
    userToUpdate.password = self.updatedPassword;
    [[[FRSAPIClient sharedClient] managedObjectContext] save:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.isSecureTextEntry) {
        if (self.errorImageView) {
            textField.text = 0;
            self.errorImageView.alpha = 0;
            self.errorImageView = nil;
            [self.errorImageView removeFromSuperview];
        }
    }
}

- (void)addErrorToView {
    if (!self.errorImageView) {
        self.errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.errorImageView.frame = CGRectMake(self.view.frame.size.width - 34, 10, 24, 24);
        self.errorImageView.alpha = 1; // 0 when animating
        [self.view addSubview:self.errorImageView];

        [self.buttonCell.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.buttonCell.rightAlignedButton.userInteractionEnabled = NO;
    }
}

#pragma mark - FRSAlertView Delegate

- (void)didPressButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    self.alert = nil;
}

@end
