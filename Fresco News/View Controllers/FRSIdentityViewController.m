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

@interface FRSIdentityViewController()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonnull) UITextField *firstNameField;
@property (strong, nonnull) UITextField *lastNameField;
@property (strong, nonnull) UITextField *addressField;
@property (strong, nonnull) UITextField *unitField;
@property (strong, nonnull) UITextField *cityField;
@property (strong, nonnull) UITextField *stateField;
@property (strong, nonnull) UITextField *zipField;
@property (nonatomic, retain) UITextField *dateField;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIButton *saveIDInfoButton;
@property (strong, nonatomic) FRSAlertView *alert;
@property BOOL savingInfo;

@end


@implementation FRSIdentityViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureBackButtonAnimated:NO];
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationItem setTitle:@"IDENTIFICATION"];
    [self.tableView reloadData];
    
    FRSUser *currentUser = [[FRSAPIClient sharedClient] authenticatedUser];
    NSArray *fieldsNeeded = currentUser.fieldsNeeded;
    
    for (NSString *neededField in fieldsNeeded) {
        if ([self isNameArea:neededField]) {
            showsNameArea = TRUE;
        }
        if ([self isAddressArea:neededField]) {
            showsAddressArea = TRUE;
        }
        if ([self isSSNArea:neededField]) {
            showsSocialSecurityArea = TRUE;
        }
    }
}
            
-(BOOL)isNameArea:(NSString *)field {
    if ([field isEqualToString:@"first_name"] || [field isEqualToString:@"last_name"] ||  [field isEqualToString:@"dob_month"] ||  [field isEqualToString:@"dob_day"] ||  [field isEqualToString:@"dob_year"]) {
     
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL)isAddressArea:(NSString *)field {
    if ([field isEqualToString:@"address_line1"] || [field isEqualToString:@"address_line2"] ||  [field isEqualToString:@"address_city"] ||  [field isEqualToString:@"address_state"] ||  [field isEqualToString:@"address_zip"]) {
        
        return TRUE;
    }
    
    return FALSE;
}


-(BOOL)isSSNArea:(NSString *)field {
    if ([field isEqualToString:@"ssn"]) {
        
        return TRUE;
    }
    
    return FALSE;
}


-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

-(void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 -16, button.frame.size.height/2 -10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

-(void)stopSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [spinner removeFromSuperview];
    [spinner startAnimating];
}

-(NSInteger)rowForField:(NSString *)field {
    
    
    return -1;
}

-(void)configureTableView{
    
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
    return ((showsAddressArea + showsNameArea + showsSocialSecurityArea) * 2) - 1; // adds seperator sections in between
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            if (showsNameArea) {
                if (showsAddressArea || showsSocialSecurityArea) {
                    return 3;
                }
                else {
                    sectionWithSendButton = (int)section;
                    return 4;
                }
            }
            else if (showsAddressArea) {
                if (showsSocialSecurityArea) {
                    return 3;
                }
                else {
                    sectionWithSendButton = (int)section;
                    return 4;
                }
            }
            else if (showsSocialSecurityArea) {
                return 2;
            }
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            if (showsAddressArea) {
                if (showsSocialSecurityArea) {
                    return 3;
                }
                else {
                    sectionWithSendButton = (int)section;
                    return 4;
                }
            }
            else if (showsSocialSecurityArea) {
                sectionWithSendButton = (int)section;
                return 2;
            }
            break;
        case 3:
            return 1;
        case 4:
            return 2;
            break;
        default:
            break;
    }
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 1:
            return 12;
            break;
        case 3:
            return 12;
            break;
        default:
            return 44;
            break;
    }
    
    return 44;
}

- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
    
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                    
                case 0:
                    //Make custom editible cell
                    [cell configureEditableCellWithDefaultText:@"First name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _firstNameField = cell.textField;
                    [_firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    
                    if ([authenticatedUser valueForKey:@"stripeFirst"]) {
                        _firstNameField.text = [authenticatedUser valueForKey:@"stripeFirst"];
                        _firstNameField.enabled = FALSE;
                        _firstNameField.textColor = [UIColor frescoLightTextColor];

                    }

                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Last name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _lastNameField = cell.textField;
                    _lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    [_lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    
                    if ([authenticatedUser valueForKey:@"stripeLast"]) {
                        _lastNameField.text = [authenticatedUser valueForKey:@"stripeLast"];
                        _lastNameField.enabled = FALSE;
                        _lastNameField.textColor = [UIColor frescoLightTextColor];
                    }
                    
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultText:@"Date of birth" withTopSeperator:NO withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypeNumberPad];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _dateField = cell.textField;
                    _dateField.secureTextEntry = FALSE;
                    
                    UIDatePicker *picker1   = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 210, 320, 216)];
                    [picker1 setDatePickerMode:UIDatePickerModeDate];
                    picker1.backgroundColor = [UIColor whiteColor];
                    [picker1 addTarget:self action:@selector(startDateSelected:) forControlEvents:UIControlEventValueChanged];
                    
                    if ([[authenticatedUser valueForKey:@"dob_day"] intValue] != 0 && [[authenticatedUser valueForKey:@"dob_month"] intValue] != 0 && [[authenticatedUser valueForKey:@"dob_year"] intValue] != 0) {
                        int day = [[authenticatedUser valueForKey:@"dob_day"] intValue];
                        int month = [[authenticatedUser valueForKey:@"dob_month"] intValue];
                        int year = [[authenticatedUser valueForKey:@"dob_year"] intValue];
                        
                        NSString *birthday = [NSString stringWithFormat:@"%d/%d/%d", day, month, year];
                        _dateField.enabled = FALSE;
                        _dateField.text = birthday;
                        _dateField.textColor = [UIColor frescoLightTextColor];
                    }
                    
                    _dateField.inputView = picker1;
                    [_dateField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
            }
            break;
            
        case 1:
            
            [cell configureEmptyCellSpace:NO];
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell configureEditableCellWithDefaultText:@"Address" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _addressField = cell.textField;
                    
                    if ([authenticatedUser valueForKey:@"address_line1"]) {
                        _addressField.text = [authenticatedUser valueForKey:@"address_line1"];
                        _addressField.enabled = FALSE;
                        _addressField.textColor = [UIColor frescoLightTextColor];
                    }
                    
                    _addressField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    [_addressField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Unit # (optional)" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _unitField = cell.textField;
                    [_unitField setKeyboardType:UIKeyboardTypeNumberPad];
                    [_unitField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultTextWithMultipleFields:@[@"City", @"State", @"ZIP"] withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _cityField = cell.textField;
                    _cityField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    _stateField = cell.secondaryField;
                    _cityField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    _zipField = cell.tertiaryField;
                    
                    if ([authenticatedUser valueForKey:@"address_city"]) {
                        _cityField.text = [authenticatedUser valueForKey:@"address_city"];
                        _cityField.enabled = FALSE;
                        _cityField.textColor = [UIColor frescoLightTextColor];

                        
                    }
                    
                    if ([authenticatedUser valueForKey:@"address_state"]) {
                        _stateField.text = [authenticatedUser valueForKey:@"address_state"];
                        _stateField.enabled = FALSE;
                        _stateField.textColor = [UIColor frescoLightTextColor];

                    }
                    
                    if ([authenticatedUser valueForKey:@"address_zip"]) {
                        _zipField.text = [authenticatedUser valueForKey:@"address_zip"];
                        _zipField.enabled = FALSE;
                        _zipField.textColor = [UIColor frescoLightTextColor];

                    }
                    
                    [_zipField setKeyboardType:UIKeyboardTypeNumberPad];
                    [_cityField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    [_stateField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    [_zipField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
                    
                case 3:
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    self.saveIDInfoButton = cell.rightAlignedButton;
                    [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                    
                default:
                    break;
            }
            break;
        case 3:
            [cell configureEmptyCellSpace:NO];
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    [cell configureEditableCellWithDefaultText:@"Social Security number" withTopSeperator:YES withBottomSeperator:YES isSecure:YES withKeyboardType:UIKeyboardTypePhonePad];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                    _addressField = cell.textField;
//                    _addressField.autocapitalizationType = UITextAutocapitalizationTypeWords;
//                    [_addressField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
                case 1:
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    self.saveIDInfoButton = cell.rightAlignedButton;
                    [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
                    break;
                default:
                    break;
            }
            break;

        default:
            break;
    }
}

-(void)textFieldDidChange:(UITextField *)textField{
    BOOL enableSaveButton = true;
    NSArray *mandatoryTextFieldArray = [[NSArray alloc] initWithObjects:_firstNameField,_lastNameField, _addressField, _cityField, _stateField, _zipField, _dateField, nil];
    for(UITextField *textField in mandatoryTextFieldArray){
        if(textField.text.length == 0 || [textField.text isEqualToString:textField.placeholder]){
            enableSaveButton = false;
        }
    }
    if(enableSaveButton){
        self.saveIDInfoButton.userInteractionEnabled = true;
        self.saveIDInfoButton.enabled = true;
        [self.saveIDInfoButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    }else{
        self.saveIDInfoButton.userInteractionEnabled = false;
        self.saveIDInfoButton.enabled = false;
        [self.saveIDInfoButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    }
}

-(void)saveIDInfo{
   // NSString *country = @"US";//TODO BEWARE THIS IS HARDCODED!!!
    
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
    
    self.savingInfo = true;
    [[FRSAPIClient sharedClient] updateIdentityWithDigestion:addressInfo completion:^(id responseObject, NSError *error) {
        NSLog(@"IDENTITY: %@ %@", error, responseObject);
        if(error){
            //Failiure popup
            self.alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
            [self.alert show];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.savingInfo = false;
    }];
}

-(void)startDateSelected:(UIDatePicker *)sender {
    NSDate *currentDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:currentDate];
    _dateField.text = stringFromDate;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3 && indexPath.section == 2) {
        // save
        if(self.saveIDInfoButton.enabled && !self.savingInfo){
            [self saveIDInfo];
        }
        NSLog(@"SAVING INFO: %@ %@ %@ %@ %@ %@ %@", _firstNameField.text, _lastNameField.text, _addressField.text, _unitField.text, _stateField.text, _zipField.text, _dateField.text);
    }
    
}

@end
