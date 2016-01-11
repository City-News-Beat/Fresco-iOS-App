//
//  FRSSettingsViewController
//  Fresco
//
//  Created by Omar Elfanek on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSettingsViewController.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "FRSTableViewCell.h"

@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSSettingsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureTableView];
}

-(void)configureNavigationBar{
    [super configureNavigationBar];
    [self configureBackButton];
    self.navigationItem.title = @"SETTINGS";
}

-(void)popViewController{
    [super popViewController];
    [self showTabBarAnimated:YES];
}

-(void)configureTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
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
                    [cell configureCellWithUsername:@"@username"];
                    break;
                case 1:
                    [cell configureDefaultCellWithTitle:@"omar@fresconews.com" andCarret:YES];
                    break;
                case 2:
                    [cell configureDefaultCellWithTitle:@"Update Password" andCarret:YES];
                    break;
                
                default:
                    return;
            }
            break;
        case 1:
            [cell configureEmptyCellSpace:NO];
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
                    [cell configureDefaultCellWithTitle:@"Debit card" withSecondTitle:@"VISA (3189)"];
                    break;
                case 3:
                    [cell configureDefaultCellWithTitle:@"Add tax info" andCarret:YES];
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
            [cell configureEmptyCellSpace:NO];
            break;
        case 6:
            [cell configureDefaultCellWithTitle:@"Promo codes" andCarret:YES];
            break;
        case 7:
            [cell configureEmptyCellSpace:NO];
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
            [cell configureEmptyCellSpace:YES];
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
