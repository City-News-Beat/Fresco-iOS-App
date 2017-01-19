//
//  FRSIdentityViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSIdentityViewController.h"
#import "UIColor+Fresco.h"
#import "Fresco.h"
#import "FRSTableViewCell.h"
#import "FRSAPIClient.h"
#import "FRSAlertView.h"

@interface FRSIdentityViewController ()

@property (weak, nonatomic) IBOutlet UIView *mainInfoView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UIView *ssnView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *unitField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) IBOutlet UITextField *socialField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *documentIDButton;
@property (weak, nonatomic) IBOutlet UIButton *saveIDInfoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssnViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssnViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveIdTopSpaceConstraint;

@property (strong, nonatomic) FRSAlertView *alert;
@property BOOL savingInfo;

@end

@implementation FRSIdentityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //    [self configureTableView];
    [self configureBackButtonAnimated:NO];
    [self configureDismissKeyboardGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureSpinner];

    [FRSTracker screen:@"Identity"];

    [self.navigationItem setTitle:@"IDENTIFICATION"];
    self.automaticallyAdjustsScrollViewInsets = NO;

    FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
    NSArray *fieldsNeeded = authenticatedUser.fieldsNeeded;

    for (NSString *neededField in fieldsNeeded) {
        if ([self isNameArea:neededField]) {
            showsNameArea = YES;
        }
        if ([self isAddressArea:neededField]) {
            showsAddressArea = YES;
        }
        if ([self isSSNArea:neededField]) {
            showsSocialSecurityArea = YES;
        }
        if ([self isDocumentIDArea:neededField]) {
            showDocumentButton = YES;
        }
    }

    if (([authenticatedUser valueForKey:@"stripeFirst"] && ![[authenticatedUser valueForKey:@"stripeFirst"] isEqual:[NSNull null]]) || ([authenticatedUser valueForKey:@"dob_month"] && ![[authenticatedUser valueForKey:@"dob_month"] isEqual:[NSNull null]])) {
        showsNameArea = YES;
    }
    if (([authenticatedUser valueForKey:@"address_line1"] && ![[authenticatedUser valueForKey:@"address_line1"] isEqual:[NSNull null]])) {
        showsAddressArea = YES;
    }

    if (!showsAddressArea) {
        self.addressViewHeightConstraint.constant = 0;
        self.addressViewTopSpaceConstraint.constant = 0;
        self.addressView.hidden = YES;
    } else {
        self.addressView.hidden = NO;
    }
    if (!showsSocialSecurityArea) {
        self.ssnViewHeightConstraint.constant = 0;
        self.ssnViewTopSpaceConstraint.constant = 0;
        self.ssnView.hidden = YES;
    } else {
        self.ssnView.hidden = NO;
    }
    if (!showDocumentButton) {
        self.documentIDButton.hidden = YES;
        self.saveIdTopSpaceConstraint.constant = 12;
    } else {
        self.documentIDButton.hidden = NO;
        self.saveIdTopSpaceConstraint.constant = 12 + self.saveIDInfoButton.frame.size.height;
    }

    self.mainInfoView.hidden = !showsNameArea;

    if ([authenticatedUser valueForKey:@"stripeFirst"]) {
        self.firstNameField.text = [authenticatedUser valueForKey:@"stripeFirst"];
        self.firstNameField.enabled = FALSE;
        self.firstNameField.textColor = [UIColor frescoLightTextColor];
    }
    if ([authenticatedUser valueForKey:@"stripeLast"]) {
        self.lastNameField.text = [authenticatedUser valueForKey:@"stripeLast"];
        self.lastNameField.enabled = FALSE;
        self.lastNameField.textColor = [UIColor frescoLightTextColor];
    }
    if ([[authenticatedUser valueForKey:@"dob_day"] intValue] != 0 && [[authenticatedUser valueForKey:@"dob_month"] intValue] != 0 && [[authenticatedUser valueForKey:@"dob_year"] intValue] != 0) {
        int day = [[authenticatedUser valueForKey:@"dob_day"] intValue];
        int month = [[authenticatedUser valueForKey:@"dob_month"] intValue];
        int year = [[authenticatedUser valueForKey:@"dob_year"] intValue];

        NSString *birthday = [NSString stringWithFormat:@"%d/%d/%d", month, day, year];
        self.dateField.enabled = FALSE;
        self.dateField.text = birthday;
        self.dateField.textColor = [UIColor frescoLightTextColor];
    }

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 210, 320, 216)];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(startDateSelected:) forControlEvents:UIControlEventValueChanged];

    self.dateField.inputView = self.datePicker;

    if ([authenticatedUser valueForKey:@"address_line1"]) {
        self.addressField.text = [authenticatedUser valueForKey:@"address_line1"];
        self.addressField.enabled = FALSE;
        self.addressField.textColor = [UIColor frescoLightTextColor];
    }
    if ([authenticatedUser valueForKey:@"address_line2"]) {
        self.unitField.text = [authenticatedUser valueForKey:@"address_line2"];
        self.unitField.enabled = FALSE;
        self.unitField.textColor = [UIColor frescoLightTextColor];
    }
    if ([authenticatedUser valueForKey:@"address_city"]) {
        self.cityField.text = [authenticatedUser valueForKey:@"address_city"];
        self.cityField.enabled = FALSE;
        self.cityField.textColor = [UIColor frescoLightTextColor];
    }
    if ([authenticatedUser valueForKey:@"address_state"]) {
        self.stateField.text = [authenticatedUser valueForKey:@"address_state"];
        self.stateField.enabled = FALSE;
        self.stateField.textColor = [UIColor frescoLightTextColor];
    }
    if ([authenticatedUser valueForKey:@"address_zip"]) {
        self.zipField.text = [authenticatedUser valueForKey:@"address_zip"];
        self.zipField.enabled = FALSE;
        self.zipField.textColor = [UIColor frescoLightTextColor];
    }
    if ([authenticatedUser valueForKey:@"ssn"]) {
        self.socialField.text = [authenticatedUser valueForKey:@"ssn"];
        self.socialField.enabled = FALSE;
        self.socialField.textColor = [UIColor frescoLightTextColor];
    }
}

- (BOOL)isNameArea:(NSString *)field {
    if ([field isEqualToString:@"first_name"] || [field isEqualToString:@"last_name"] || [field isEqualToString:@"dob_month"] || [field isEqualToString:@"dob_day"] || [field isEqualToString:@"dob_year"]) {

        return TRUE;
    }

    return FALSE;
}

- (BOOL)isAddressArea:(NSString *)field {
    if ([field isEqualToString:@"address_line1"] || [field isEqualToString:@"address_line2"] || [field isEqualToString:@"address_city"] || [field isEqualToString:@"address_state"] || [field isEqualToString:@"address_zip"]) {
        return YES;
    }

    return NO;
}

- (BOOL)isSSNArea:(NSString *)field {
    if ([field isEqualToString:@"pid_last4"]) {
        self.socialField.placeholder = @"Last 4 Digits of Social Security Number";
        return YES;
    }
    if ([field isEqualToString:@"personal_id_number"]) {
        self.socialField.placeholder = @"Social Security Number";
        return YES;
    }
    return NO;
}

- (BOOL)isDocumentIDArea:(NSString *)field {
    if ([field isEqualToString:@"id_document"]) {
        return YES;
    }

    return NO;
}

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

- (void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 - 16, button.frame.size.height / 2 - 10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

- (void)stopSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [spinner removeFromSuperview];
    [spinner startAnimating];
}

//- (void)configureTableView {
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    self.tableView.showsVerticalScrollIndicator = NO;
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.bounces = NO;
//    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
//    [self.tableView setSeparatorColor:[UIColor clearColor]];
//    [self.view addSubview:self.tableView];
//}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    if (!showsAddressArea && !showsNameArea && !showsSocialSecurityArea) {
//        return 0;
//    }
//
//    int numSections = ((showsAddressArea + showsNameArea + showsSocialSecurityArea) * 2) - 1;
//
//    if (numSections < 0) {
//        numSections = 0;
//    }
//
//    return numSections; // adds seperator sections in between
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//    switch (section) {
//    case 0:
//        if (showsNameArea) {
//            if (showsAddressArea) {
//                return 3;
//            } else if (showsSocialSecurityArea) {
//                return 2;
//            } else {
//                sectionWithSendButton = (int)section;
//                return 4;
//            }
//        } else if (showsAddressArea) {
//            if (showsSocialSecurityArea) {
//                return 3;
//            } else {
//                sectionWithSendButton = (int)section;
//                return 4;
//            }
//        } else if (showsSocialSecurityArea) {
//            return 2;
//        }
//        break;
//
//    case 1:
//        return 1;
//        break;
//
//    case 2:
//        if (showsAddressArea && showsNameArea) {
//            if (showsSocialSecurityArea) {
//                return 3;
//            } else {
//                sectionWithSendButton = (int)section;
//                return 4;
//            }
//        } else if (!showsNameArea) {
//            if (showsSocialSecurityArea) {
//                return 2;
//            } else {
//                sectionWithSendButton = (int)section;
//                return 4;
//            }
//        } else if (showsSocialSecurityArea) {
//            sectionWithSendButton = (int)section;
//            return 2;
//        }
//        break;
//    case 3:
//        return 1;
//    case 4:
//        return 2;
//        break;
//    default:
//        break;
//    }
//
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    switch (indexPath.section) {
//    case 1:
//        return 12;
//        break;
//    case 3:
//        return 12;
//        break;
//    default:
//        return 44;
//        break;
//    }
//
//    return 44;
//}
//
//- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *cellIdentifier;
//    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//    return cell;
//}

//- (void)configureAddressCell:(FRSTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
//    FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
//
//    switch (indexPath.row) {
//    case 0:
//        [cell configureEditableCellWithDefaultText:@"Address" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        _addressField = cell.textField;
//        _addressField.returnKeyType = UIReturnKeyNext;
//
//        if ([authenticatedUser valueForKey:@"address_line1"]) {
//            _addressField.text = [authenticatedUser valueForKey:@"address_line1"];
//            _addressField.enabled = FALSE;
//            _addressField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        _addressField.tag = 1;
//        _addressField.delegate = self;
//        _addressField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        [_addressField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        cell.textField.delegate = self;
//        break;
//
//    case 1:
//        [cell configureEditableCellWithDefaultText:@"Unit # (optional)" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        _unitField = cell.textField;
//        [_unitField setKeyboardType:UIKeyboardTypeDefault];
//        [_unitField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        _unitField.tag = 2;
//        cell.textField.delegate = self;
//        _unitField.returnKeyType = UIReturnKeyNext;
//        break;
//
//    case 2:
//        [cell configureEditableCellWithDefaultTextWithMultipleFields:@[ @"City", @"State", @"ZIP" ] withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        _cityField = cell.textField;
//        _cityField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        _stateField = cell.secondaryField;
//        _cityField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        _zipField = cell.tertiaryField;
//
//        if ([authenticatedUser valueForKey:@"address_city"]) {
//            _cityField.text = [authenticatedUser valueForKey:@"address_city"];
//            _cityField.enabled = FALSE;
//            _cityField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        if ([authenticatedUser valueForKey:@"address_state"]) {
//            _stateField.text = [authenticatedUser valueForKey:@"address_state"];
//            _stateField.enabled = FALSE;
//            _stateField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        if ([authenticatedUser valueForKey:@"address_zip"]) {
//            _zipField.text = [authenticatedUser valueForKey:@"address_zip"];
//            _zipField.enabled = FALSE;
//            _zipField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        [_zipField setKeyboardType:UIKeyboardTypeNumberPad];
//        [_cityField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [_stateField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [_zipField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        _cityField.tag = 3;
//        _stateField.tag = 4;
//        _zipField.tag = 5;
//        cell.textField.delegate = self;
//        cell.secondaryField.delegate = self;
//        cell.tertiaryField.delegate = self;
//        _cityField.returnKeyType = UIReturnKeyNext;
//        _stateField.returnKeyType = UIReturnKeyNext;
//        _zipField.returnKeyType = UIReturnKeyDone;
//
//        break;
//    case 4:
//        [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.saveIDInfoButton = cell.rightAlignedButton;
//        [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
//        break;
//
//    case 3:
//        [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.saveIDInfoButton = cell.rightAlignedButton;
//        [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
//        break;
//
//    default:
//        break;
//    }
//}
//
//- (void)configureNameCell:(FRSTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
//    FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
//
//    switch (indexPath.row) {
//
//    case 0:
//        //Make custom editible cell
//        [cell configureEditableCellWithDefaultText:@"First name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        _firstNameField = cell.textField;
//        [_firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//
//        if ([authenticatedUser valueForKey:@"stripeFirst"]) {
//            _firstNameField.text = [authenticatedUser valueForKey:@"stripeFirst"];
//            _firstNameField.enabled = FALSE;
//            _firstNameField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        _firstNameField.tag = 1;
//        _firstNameField.returnKeyType = UIReturnKeyNext;
//        cell.textField.delegate = self;
//
//        break;
//
//    case 1:
//        [cell configureEditableCellWithDefaultText:@"Last name" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        _lastNameField = cell.textField;
//        _lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        [_lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//
//        if ([authenticatedUser valueForKey:@"stripeLast"]) {
//            _lastNameField.text = [authenticatedUser valueForKey:@"stripeLast"];
//            _lastNameField.enabled = FALSE;
//            _lastNameField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        _lastNameField.tag = 2;
//        _lastNameField.returnKeyType = UIReturnKeyNext;
//        cell.textField.delegate = self;
//
//        break;
//    case 3:
//        [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.saveIDInfoButton = cell.rightAlignedButton;
//        [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
//        break;
//    case 2:
//        [cell configureEditableCellWithDefaultText:@"Date of birth" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeNumberPad];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        _dateField = cell.textField;
//        _dateField.secureTextEntry = FALSE;
//
//        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 210, 320, 216)];
//        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
//        self.datePicker.backgroundColor = [UIColor whiteColor];
//        [self.datePicker addTarget:self action:@selector(startDateSelected:) forControlEvents:UIControlEventValueChanged];
//
//        if ([[authenticatedUser valueForKey:@"dob_day"] intValue] != 0 && [[authenticatedUser valueForKey:@"dob_month"] intValue] != 0 && [[authenticatedUser valueForKey:@"dob_year"] intValue] != 0) {
//            int day = [[authenticatedUser valueForKey:@"dob_day"] intValue];
//            int month = [[authenticatedUser valueForKey:@"dob_month"] intValue];
//            int year = [[authenticatedUser valueForKey:@"dob_year"] intValue];
//
//            NSString *birthday = [NSString stringWithFormat:@"%d/%d/%d", month, day, year];
//            _dateField.enabled = FALSE;
//            _dateField.text = birthday;
//            _dateField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        _dateField.inputView = self.datePicker;
//        [_dateField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        cell.textField.delegate = self;
//        cell.textField.tag = 3;
//        _dateField.returnKeyType = UIReturnKeyDone;
//        break;
//    }
//}
//
//- (void)configureSSNCell:(FRSTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
//    FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
//
//    switch (indexPath.row) {
//    case 0:
//        [cell configureEditableCellWithDefaultText:@"Last 4 Digits of Social Security Number" withTopSeperator:YES withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypePhonePad];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        //                    _addressField = cell.textField;
//        //                    _addressField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        _socialField = cell.textField;
//        [_socialField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//
//        if ([authenticatedUser valueForKey:@"ssn"]) {
//            _socialField.text = [authenticatedUser valueForKey:@"ssn"];
//            _socialField.enabled = FALSE;
//            _socialField.textColor = [UIColor frescoLightTextColor];
//        }
//
//        cell.textField.delegate = self;
//        cell.textField.tag = 4;
//
//        break;
//    case 1:
//        [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.saveIDInfoButton = cell.rightAlignedButton;
//        [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
//        break;
//    default:
//        break;
//    }
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//    case 0:
//        if (showsNameArea) {
//            [self configureNameCell:cell forIndexPath:indexPath];
//        } else if (showsAddressArea) {
//            [self configureAddressCell:cell forIndexPath:indexPath];
//        } else if (showsSocialSecurityArea) {
//            [self configureSSNCell:cell forIndexPath:indexPath];
//        }
//        break;
//
//    case 1:
//
//        [cell configureEmptyCellSpace:NO];
//        break;
//
//    case 2:
//        if (showsAddressArea && showsNameArea) {
//            [self configureAddressCell:cell forIndexPath:indexPath];
//        } else if (showsSocialSecurityArea) {
//            [self configureSSNCell:cell forIndexPath:indexPath];
//        }
//
//        break;
//    case 3:
//        [cell configureEmptyCellSpace:NO];
//        break;
//    case 4:
//        [self configureSSNCell:cell forIndexPath:indexPath];
//        break;
//
//    default:
//        break;
//    }
//}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField {
    //    if (IS_IPHONE_5) {
    //        if (textField == self.addressField || textField == self.unitField || textField == self.cityField || textField == self.stateField || textField == self.zipField) {
    //            [UIView animateWithDuration:0.3
    //                                  delay:0
    //                                options:UIViewAnimationOptionCurveEaseInOut
    //                             animations:^{
    //                               self.tableView.transform = CGAffineTransformMakeTranslation(0, -70);
    //                             }
    //                             completion:nil];
    //        }
    //    }
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField {
    //    if (IS_IPHONE_5) {
    //        if (textField == self.addressField || textField == self.unitField || textField == self.cityField || textField == self.stateField || textField == self.zipField) {
    //            [UIView animateWithDuration:0.3
    //                                  delay:0
    //                                options:UIViewAnimationOptionCurveEaseInOut
    //                             animations:^{
    //                               self.tableView.transform = CGAffineTransformMakeTranslation(0, 0);
    //                             }
    //                             completion:nil];
    //        }
    //    }
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    BOOL enableSaveButton = true;

    NSArray *mandatoryTextFieldArray = [[NSArray alloc] initWithObjects:_firstNameField, _lastNameField, _addressField, _cityField, _stateField, _zipField, _dateField, _socialField, nil];
    for (UITextField *textField in mandatoryTextFieldArray) {
        if ((textField.text.length == 0 || [textField.text isEqualToString:@""]) && textField.enabled) {
            enableSaveButton = false;
        }
    }

    self.saveIDInfoButton.enabled = enableSaveButton;
    if (enableSaveButton) {
        [self.saveIDInfoButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    } else {
        [self.saveIDInfoButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    }
}

- (IBAction)savedocumentIDInfo:(id)sender {
    UIAlertController *photoSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    FRSIdentityViewController *__weak weakSelf = self;
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take a New Photo"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                           [weakSelf showImagePickerControllerWithCamera:YES];
                                                         }];
    [photoSheet addAction:cameraAction];

    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Upload Photo"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                            [weakSelf showImagePickerControllerWithCamera:NO];
                                                          }];
    [photoSheet addAction:libraryAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action){
                                                         }];
    [photoSheet addAction:cancelAction];

    [self presentViewController:photoSheet animated:YES completion:nil];
}

- (IBAction)saveIDInfo:(id)sender {
    [self startSpinner:self.loadingView onButton:self.saveIDInfoButton];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDate = [formatter dateFromString:_dateField.text];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:birthDate];

    NSMutableDictionary *addressInfo = [[NSMutableDictionary alloc] init];

    if (_addressField.enabled && ![_addressField.text isEqualToString:@""]) {
        [addressInfo setObject:_addressField.text forKey:@"address_line1"];
    }
    if (_unitField.enabled && ![_unitField.text isEqualToString:@""]) {
        [addressInfo setObject:_unitField.text forKey:@"address_line2"];
    }
    if (_cityField.enabled && ![_cityField.text isEqualToString:@""]) {
        [addressInfo setObject:_cityField.text forKey:@"address_city"];
    }
    if (_stateField.enabled && ![_stateField.text isEqualToString:@""]) {
        [addressInfo setObject:_stateField.text forKey:@"address_state"];
    }
    if (_zipField.enabled && ![_zipField.text isEqualToString:@""]) {
        [addressInfo setObject:_zipField.text forKey:@"address_zip"];
    }
    if (_dateField.enabled && ![_dateField.text isEqualToString:@""]) {
        [addressInfo setObject:[NSNumber numberWithInteger:[components day]] forKey:@"dob_day"];
        [addressInfo setObject:[NSNumber numberWithInteger:[components month]] forKey:@"dob_month"];
        [addressInfo setObject:[NSNumber numberWithInteger:[components year]] forKey:@"dob_year"];
    }
    if (_firstNameField.enabled && ![_firstNameField.text isEqualToString:@""]) {
        [addressInfo setObject:_firstNameField.text forKey:@"first_name"];
    }
    if (_lastNameField.enabled && ![_lastNameField.text isEqualToString:@""]) {
        [addressInfo setObject:_lastNameField.text forKey:@"last_name"];
    }
    if (_socialField.enabled && ![_socialField.text isEqualToString:@""]) {
        [addressInfo setObject:_socialField.text forKey:@"pid_last4"];
    }

    self.savingInfo = true;
    [[FRSAPIClient sharedClient] updateIdentityWithDigestion:addressInfo
                                                  completion:^(id responseObject, NSError *error) {
                                                    self.savingInfo = false;

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self stopSpinner:self.loadingView onButton:self.saveIDInfoButton];

                                                      if (error) {
                                                          [self presentGenericError];
                                                      } else {
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }
                                                    });
                                                  }];
}

- (void)startDateSelected:(UIDatePicker *)sender {
    NSDate *currentDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];

    NSString *stringFromDate = [formatter stringFromDate:currentDate];
    _dateField.text = stringFromDate;

    self.saveIDInfoButton.userInteractionEnabled = true;
    self.saveIDInfoButton.enabled = true;
    [self.saveIDInfoButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    if (indexPath.row == 3 && indexPath.section == 2) {
//        // save
//
//        if (!self.saveIDInfoButton.userInteractionEnabled) {
//            [self.view endEditing:YES];
//            return;
//        }
//        if (self.saveIDInfoButton.enabled && !self.savingInfo) {
//            [self saveIDInfo];
//        }
//    }
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //
    //    FRSTableViewCell *currentCell = (FRSTableViewCell *)textField.superview.superview;
    //    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
    //
    //    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
    //    FRSTableViewCell *nextCell = (FRSTableViewCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];

    //    [nextCell.textField becomeFirstResponder];

    if (textField == _lastNameField) {
        [textField resignFirstResponder];
        [self startDateSelected:self.datePicker];
        [_dateField becomeFirstResponder];
    } else if (textField == _addressField) {
        [textField resignFirstResponder];
        [_unitField becomeFirstResponder];
    } else if (textField == _unitField) {
        [textField resignFirstResponder];
        [_cityField becomeFirstResponder];
    } else if (textField == _cityField) {
        [textField resignFirstResponder];
        [_stateField becomeFirstResponder];
    } else if (textField == _stateField) {
        [textField resignFirstResponder];
        [_zipField becomeFirstResponder];
    } else if (textField == _zipField) {
        [self.view resignFirstResponder];
    }

    return NO;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                 NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
                                 UIImage *editedImage;

                                 // Handle a still image capture
                                 if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
                                     editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];

                                     if (!editedImage)
                                         return;

                                     NSData *imageData = UIImageJPEGRepresentation(editedImage, 1.0);
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       [[FRSAPIClient sharedClient] uploadStateID:setStateIDEndpoint
                                           withParameters:@{ @"file" : imageData }
                                           completion:^(id responseObject, NSError *error) {
                                             if (error) {

                                             } else {
                                                 if ([[responseObject class] isSubclassOfClass:[NSDictionary class]]) {
                                                     NSMutableDictionary *responseObjects = [[NSMutableDictionary alloc] init];
                                                     NSArray *keys = [responseObject allKeys];
                                                     NSString *fileID = [responseObjects valueForKey:@"id"];
                                                     [[FRSAPIClient sharedClient] updateTaxInfoWithFileID:fileID
                                                                                               completion:^(id responseObject, NSError *error){
                                                                                                   NSLog(@"%@", responseObject);
                                                                                               }];
                                                 }
                                             }
                                           }];
                                     });
                                 }
                               }];
}

- (void)showImagePickerControllerWithCamera:(BOOL)withCamera {

    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.delegate = self;
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    cameraUI.allowsEditing = true;
    if (withCamera) {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:cameraUI animated:YES completion:nil];
}

@end
