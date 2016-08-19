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


-(void)viewWillAppear:(BOOL)animated{    [self.navigationItem setTitle:@"IDENTIFICATION"];
    [self.tableView reloadData];
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
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return 4;
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
    
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                    
                case 0:
                    //Make custom editible cell
                    [cell configureEditableCellWithDefaultText:@"First name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _firstNameField = cell.textField;
                    [_firstNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Last name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _lastNameField = cell.textField;
                    _lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    [_lastNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
                    [_zipField setKeyboardType:UIKeyboardTypeNumberPad];
                    [_cityField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    [_stateField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    [_zipField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    break;
                    
                case 3:
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
<<<<<<< HEAD
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    self.saveIDInfoButton = cell.rightAlignedButton;
                    [self.saveIDInfoButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
=======
                    [cell.rightAlignedButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
>>>>>>> 3.0-phil
                    break;
                    
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

<<<<<<< HEAD
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
    NSString *country = @"US";//TODO BEWARE THIS IS HARDCODED!!!
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDate = [formatter dateFromString:_dateField.text];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:birthDate];
    
    NSDictionary *addressInfo = @{@"line1":_addressField.text,@"line2":_unitField.text,@"city":_cityField.text,@"state":_stateField.text,@"postal_code":_zipField.text,@"country":country};
    NSDictionary *dobInfo = @{@"day":[NSNumber numberWithInteger:[components day]],@"month":[NSNumber numberWithInteger:[components month]],@"year":[NSNumber numberWithInteger:[components year]]};
    NSDictionary *payload = @{@"address":addressInfo, @"dob":dobInfo, @"first_name":_firstNameField.text, @"last_name":_lastNameField.text};
    
    self.savingInfo = true;
    [[FRSAPIClient sharedClient] updateUserWithDigestion:payload completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", error, responseObject);
        if(error){
            //Failiure popup
            self.alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
            [self.alert show];
=======
-(void)saveIDInfo{/*
    NSString *firstName, *lastName;
    NSMutableDictionary *addressDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dobDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *idInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"address", addressDic, @"dob", dobDic, @"first_name", firstName,@"last_name", lastName, nil];
    for(int i = 0; i < self.tableView.visibleCells.count; i++){
        FRSTableViewCell *cell = [self.tableView.visibleCells objectAtIndex:i];
        NSIndexPath cellIndexPath = [self.tableView indexPathForCell:cell];
        if(!cell.rightAlignedButton && cell.textField){
            if(cellIndexPath.section == 0){
                if(cellIndexPath.row == 0){
                    firstName = cell.textField.text;
                }else if(cellIndexPath.row == 1){
                    lastName = cell.textField.text;
                }else if(cellIndexPath.row == 2){
                    [dobDic setValue:cell.textField.text forKey:@"day"];
                    [dobDic setValue:<#(nullable id)#> forKey:@"month"];
                    [dobDic setValue:<#(nullable id)#> forKey:@"year"];
                }
            }
>>>>>>> 3.0-phil
        }
        self.savingInfo = false;
    }];
}
<<<<<<< HEAD

=======
>>>>>>> 3.0-phil
-(void)startDateSelected:(UIDatePicker *)sender {
    NSDate *currentDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:currentDate];
    _dateField.text = stringFromDate;
}


<<<<<<< HEAD
=======

>>>>>>> 3.0-phil
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
