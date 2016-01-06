//
//  SettingsViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "FRSSettingsTableViewCell.h"

@interface SettingsViewController ()

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SettingsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureNavBar];
    
}

-(void)configureNavBar{
    
    self.title = @"SETTINGS";
    
}

-(void)configureTableView{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self.view addSubview:self.tableView];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 4;
            break;
            
        case 2:
            return 3;
            break;
            
        case 3:
            return 1;
            break;
            
        case 4:
            return 3;
            break;
            
        default:
            return 0;
            break;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    CGFloat height = 13;
    
    UIView *view =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];//Height is set in heightForFooterInSection
    view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    UIView *topLine =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    topLine.backgroundColor = [UIColor frescoShadowColor];
    [view addSubview:topLine];
    
    UIView *bottomLine =  [[UIView alloc] initWithFrame:CGRectMake(0, height, self.tableView.frame.size.width, 1)];
    bottomLine.backgroundColor = [UIColor frescoShadowColor];
    [view addSubview:bottomLine];
    
    
    //        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, height)];
    //    //    view.backgroundColor = [UIColor redColor];
    //        self.tableView.tableFooterView = view;
    //        self.tableView.contentInset = UIEdgeInsetsMake(-height, 0, 0, 0);
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //    if (section == 4){
    //        return 0;
    //    }
    return 13;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
            
        case 0:
            
            if (indexPath.row == 0) {
                return 56;
            } else {
                return 44;
            }
            break;
            
        case 1:
            
            if (indexPath.row == 0) {
                return 56;
            } else {
                return 44;
            }
            break;
            
        case 2:
            return 44;
            break;
            
        case 3:
            return 44;
            break;
            
        case 4:
            return 44;
            break;
            
        default:
            return 44;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FRSSettingsTableViewCell *cell = [[FRSSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"h"];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    cell.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    
    if (indexPath.section == 0) { // Profile
        if (indexPath.row == 0){
            cell.textLabel.text = @"@omar";
            cell.textLabel.font = [UIFont notaMediumWithSize:17];
        } else {
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        }
        if (indexPath.row == 1){
            cell.textLabel.text = @"omar@fresconews.com";
        }
        if (indexPath.row == 2){
            cell.textLabel.text = @"Update password";
        }
        
    } else if(indexPath.section == 1){ //Notifications and billing
        if(indexPath.row == 0){
            cell.textLabel.text = @"ASSIGNMENT NOTIFICATIONS";
            cell.textLabel.font = [UIFont notaBoldWithSize:15];
            
            cell.detailTextLabel.text = @"We’ll tell you about paid photo ops nearby";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
            cell.detailTextLabel.frame = CGRectMake(16, 500, self.view.bounds.size.width, 14);
            cell.detailTextLabel.textColor = [UIColor frescoMediumTextColor];
            
            UISwitch *notificationSwitch = [[UISwitch alloc] init];
            notificationSwitch.center = cell.center;
            notificationSwitch.center = CGPointMake([UIScreen mainScreen].bounds.size.width - notificationSwitch.bounds.size.width/2 - 13.5, notificationSwitch.bounds.size.height/2 + 14);
            [cell addSubview:notificationSwitch];
        } else if (indexPath.row == 1){
            cell.textLabel.text = @"Notification radius";
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        } else if (indexPath.row == 2){
            cell.textLabel.text = @"Debit card";
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        } else if (indexPath.row == 3){
            cell.textLabel.text = @"Update tax info";
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        }
    } else if(indexPath.section == 2){ //Social
        if (indexPath.row == 0){
            UIImageView *socialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accepted"]];
            [cell addSubview:socialImage];
        } else if (indexPath.row == 1){
            
        } else if (indexPath.row == 2){
            
        }
        
    }
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}













@end
