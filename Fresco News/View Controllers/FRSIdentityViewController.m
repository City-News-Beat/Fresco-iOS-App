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
                    
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Last name" withTopSeperator:YES withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _lastNameField = cell.textField;
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
                    break;
                    
                case 1:
                    [cell configureEditableCellWithDefaultText:@"Unit # (optional)" withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _unitField = cell.textField;
                    break;
                    
                case 2:
                    [cell configureEditableCellWithDefaultTextWithMultipleFields:@[@"City", @"State", @"ZIP"] withTopSeperator:NO withBottomSeperator:YES isSecure:NO withKeyboardType:UIKeyboardTypeDefault];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    _cityField = cell.textField;
                    _stateField = cell.secondaryField;
                    _zipField = cell.tertiaryField;
                    break;
                    
                case 3:
                    [cell configureCellWithRightAlignedButtonTitle:@"SAVE ID INFO" withWidth:143 withColor:[UIColor frescoLightTextColor]];
                    [cell.rightAlignedButton addTarget:self action:@selector(saveIDInfo) forControlEvents:UIControlEventTouchUpInside];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

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
        }
    }*/
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
        NSLog(@"SAVING INFO: %@ %@ %@ %@ %@ %@ %@", _firstNameField.text, _lastNameField.text, _addressField.text, _unitField.text, _stateField.text, _zipField.text, _dateField.text);
    }

}

@end
