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
#import "FRSTableViewCell.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

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
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self.view addSubview:self.tableView];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 10;
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
            
        case 3:
            return 1;
            break;
            
        case 4:
            return 3;
            break;
            
        case 5:
            return 1;
            break;
            
        case 6:
            return 1;
            break;
            
        case 7:
            return 1;
            break;
            
        case 8:
            return 3;
            break;
            
        case 9:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
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
            return 13;
            break;
            
        case 2:
            if (indexPath.row == 0) {
                return 62;
            } else {
                return 44;
            }
            break;
            
        case 3:
            return 13;
            break;
            
        case 5:
            return 13;
            break;
            
        case 7:
            return 13;
            break;
            
        case 9:
            return 13;
            break;
            
            
            
            
            
        default:
            return 44;
            break;
    }
}

- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cellIdentifier = @"profile-cell";
                    break;
                    
                default:
                    cellIdentifier = @"default-cell";
                    break;
            }
            
            break;
        case 1:
            break;
            
        case 2:
            break;
        default:
            break;
    }
    
    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    
    return cell;
    
    //    FRSSettingsTableViewCell *cell = [[FRSSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"h"];
    //
    //
    //    // Remove seperator inset
    //    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
    //        [cell setSeparatorInset:UIEdgeInsetsZero];
    //    }
    //    // Prevent the cell from inheriting the Table View's margin settings
    //    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
    //        [cell setPreservesSuperviewLayoutMargins:NO];
    //    }
    //    // Explictly set your cell's layout margins
    //    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    //        [cell setLayoutMargins:UIEdgeInsetsZero];
    //    }
    //
    //
    //    UIView *bgColorView = [[UIView alloc] init];
    //    bgColorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.06];
    //    [cell setSelectedBackgroundView:bgColorView];
    //
    //    self.tableView.showsVerticalScrollIndicator = NO;
    //    cell.textLabel.text = @"";
    //    cell.detailTextLabel.text = @"";
    //
    //    cell.backgroundColor = [UIColor frescoBackgroundColorLight];
    //
    //    if (indexPath.section == 0) { // Profile
    //        if (indexPath.row == 0){
    //            cell.textLabel.text = @"@frog";
    //            cell.textLabel.font = [UIFont notaMediumWithSize:17];
    //        } else {
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        }
    //        if (indexPath.row == 1){
    //            cell.textLabel.text = @"frog@fresconews.frog";
    //        }
    //        if (indexPath.row == 2){
    //            cell.textLabel.text = @"Update password";
    //        }
    //
    //
    //    } else if(indexPath.section == 2){ //Notifications and billing
    //        if(indexPath.row == 0){
    //
    //            cell.tintColor = [UIColor clearColor];
    //            cell.textLabel.text = @"ASSIGNMENT NOTIFICATIONS";
    //            cell.textLabel.font = [UIFont notaBoldWithSize:15];
    //            cell.detailTextLabel.text = @"We’ll tell you about paid photo ops nearby";
    //            cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    //            cell.detailTextLabel.frame = CGRectMake(16, 500, self.view.bounds.size.width, 14);
    //            cell.detailTextLabel.textColor = [UIColor frescoMediumTextColor];
    //
    //            UISwitch *notificationSwitch = [[UISwitch alloc] init];
    //            notificationSwitch.center = cell.center;
    //            notificationSwitch.center = CGPointMake([UIScreen mainScreen].bounds.size.width - notificationSwitch.bounds.size.width/2 - 13.5, notificationSwitch.bounds.size.height/2 + 14);
    //            [cell addSubview:notificationSwitch];
    //        } else if (indexPath.row == 1){
    //
    //            cell.textLabel.text = @"Notification radius";
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        } else if (indexPath.row == 2){
    //            cell.textLabel.text = @"Debit card";
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        } else if (indexPath.row == 3){
    //            cell.textLabel.text = @"Update tax info";
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        }
    //    } else if(indexPath.section == 4){ //Social
    //        if (indexPath.row == 0){
    //            UIImageView *socialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-icon"]];
    //            socialImage.frame = CGRectMake(16, 10, 24, 24);
    //            [cell addSubview:socialImage];
    //
    //            cell.textLabel.text = @"Connect Twitter";
    //            cell.textLabel.frame = CGRectMake(56, 11, 110, 20);
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //
    //        } else if (indexPath.row == 1){
    //            UIImageView *socialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook-icon"]];
    //            socialImage.frame = CGRectMake(16, 10, 24, 24);
    //            [cell addSubview:socialImage];
    //
    //            cell.textLabel.text = @"Connect Facebook";
    //            cell.textLabel.frame = CGRectMake(56, 11, 110, 20);
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //
    //        } else if (indexPath.row == 2){
    //            UIImageView *socialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"google-icon"]];
    //            socialImage.frame = CGRectMake(16, 10, 24, 24);
    //            [cell addSubview:socialImage];
    //
    //            cell.textLabel.text = @"Connect Google";
    //            cell.textLabel.frame = CGRectMake(56, 11, 110, 20);
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        }
    //
    //    } else if (indexPath.section == 6){
    //
    //        cell.textLabel.text = @"Promo codes";
    //        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //
    //    } else if (indexPath.section == 8){
    //
    //        if (indexPath.row == 0){
    //
    //            UILabel *logOut = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width/2, cell.bounds.size.height/2 - 6, 54, 17)];
    //            logOut.text = @"LOG OUT";
    //            logOut.textColor = [UIColor frescoRedHeartColor];
    //            logOut.font = [UIFont notaBoldWithSize:15];
    //            [cell addSubview:logOut];
    //        }
    //
    //        if (indexPath.row == 1){
    //            cell.textLabel.text = @"Email support";
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        } else if (indexPath.row == 2){
    //            cell.textLabel.text = @"Disable my account";
    //            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    //        }
    //
    //    }
    //
    //
    //    if (indexPath.section == 1) {
    //        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    }
    //    if (indexPath.section == 3) {
    //        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    }
    //    if (indexPath.section == 5) {
    //        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    }
    //    if (indexPath.section == 7) {
    //        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    }
    //    if (indexPath.section == 9) {
    //        cell.backgroundColor = [UIColor frescoBackgroundColorDark];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    }
    
    
    //    return cell;
    
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell configureCellWithUsername:@"@username"];
                    break;
                    
                case 1:
                    [cell configureDefaultCellWithTitle:@"omar@fresconews.com" andCarret:YES];
                    break;
                    
                case 2:
                    [cell configureDefaultCellWithTitle:@"Update Password" andCarret:YES];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 1:
            [cell configureEmptyCellSpace];
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell configureAssignmentCell];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    [cell configureDefaultCellWithTitle:@"Notification radius" withSecondTitle:@"2 mi"];
                    break;
                case 2:
                    [cell configureDefaultCellWithTitle:@"Add a debit card" withSecondTitle:@"VISA (3189)"];
                    break;
                case 3:
                    [cell configureDefaultCellWithTitle:@"Add tax info" andCarret:YES];
                    break;
                default:
                    break;
            }
            break;
            
        case 3:
            [cell configureEmptyCellSpace];
            break;
            
        case 4:
            switch (indexPath.row) {
                case 0:
                    [cell configureSocialCellWithTitle:@"Connect Twitter" andTag:1];
                    break;
                case 1:
                    [cell configureSocialCellWithTitle:@"Connect Facebook" andTag:2];
                    break;
                case 2:
                    [cell configureSocialCellWithTitle:@"Connect Google" andTag:3];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 5:
            [cell configureEmptyCellSpace];
            break;
            
        case 6:
            [cell configureDefaultCellWithTitle:@"Promo codes" andCarret:YES];
            break;
            
        case 7:
            [cell configureEmptyCellSpace];
            break;
            
        case 8:
            switch (indexPath.row) {
                case 0:
                    [cell configureLogOut];
                    break;
                case 1:
                    [cell configureDefaultCellWithTitle:@"Email support" andCarret:NO];
                    break;
                case 2:
                    [cell configureDefaultCellWithTitle:@"Disable my account" andCarret:YES];
                    break;
            }
        
            break;
        
        case 9:
            [cell configureEmptyCellSpace];
            break;
            
            
        default:
            break;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



@end
