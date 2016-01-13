//
//  FRSSettingsViewController
//  Fresco
//
//  Created by Omar Elfanek on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "FRSSettingsViewController.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "FRSTableViewCell.h"
#import "FRSAlertView.h"

//view controllers
#import "FRSUsernameViewController.h"
#import "FRSPromoCodeViewController.h"
#import "FRSEmailViewController.h"
#import "FRSPasswordChangeViewController.h"
#import "FRSTaxInformationViewController.h"


@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSSettingsViewController

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
    
//    switch (indexPath.section) {
//        case 0:
//            switch (indexPath.row) {
//                case 0:
//                {
//                    cellIdentifier = @"username-cell";
//                    FRSUsernameViewController *username = [[FRSUsernameViewController alloc] init];
//                    [self.navigationController pushViewController:username animated:YES];
//                    self.navigationItem.title = @"";
//                }
//                    break;
//                case 1:
//                {
//                    cellIdentifier = @"email-cell";
//                    FRSEmailViewController *email = [[FRSEmailViewController alloc] init];
//                    [self.navigationController pushViewController:email animated:YES];
//                    self.navigationItem.title = @"";
//                }
//                    break;
//                case 2:
//                {
//                    cellIdentifier = @"update-password-cell";
//                    FRSPasswordChangeViewController *password = [[FRSPasswordChangeViewController alloc] init];
//                    [self.navigationController pushViewController:password animated:YES];
//                    self.navigationItem.title = @"";
//                }
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 1:
//            //Empty
//            break;
//        case 2:
//            switch (indexPath.row) {
//                case 1:
//                    cellIdentifier = @"assignment-notifications-cell";
//                    //assignment notif
//                    break;
//                case 2:{
//                    cellIdentifier = @"notification-radius-cell";
//                    //notif radius
//                }
//                    break;
//                case 3:{
//                    cellIdentifier = @"debit-card-cell";
//                    //debit card
//                }
//                    break;
//                case 4:{
//                    cellIdentifier = @"tax-cell";
//                    //tax info
//                }
//                default:
//                    break;
//            }
//            break;
//        case 3:
//            //Empty
//            break;
//        case 4:
//            switch (indexPath.row) {
//                case 0:{
//                    cellIdentifier = @"twitter-cell";
//                    //twitter
//                }
//                    break;
//                case 1:{
//                    cellIdentifier = @"facebook-cell";
//                    //facebook
//                }
//                    break;
//                case 2:{
//                    cellIdentifier = @"google-cell";
//                    //google
//                }
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 5:
//            //Empty
//            break;
//        case 6: {
//            cellIdentifier = @"promo-codes-cell";
//            //promo
//        }
//            break;
//        case 7:
//            //Empty
//            break;
//        case 8:
//            switch (indexPath.row) {
//                case 0: {
//                    cellIdentifier = @"logout-cell";
//                    //logout
//                }
//                    break;
//                case 1: {
//                    cellIdentifier = @"email-support-cell";
//                    //email support
//                }
//                    break;
//                case 2: {
//                    cellIdentifier = @"disable-account-cell";
//                    //disable account
//                }
//                    break;
//            }
//            break;
//        case 9:
//            //Empty
//            break;
//        default:
//            break;
    
//            }}
    
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
    
    //    [cell clearCell];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell configureCellWithUsername:@"@username"];
                    break;
                case 1:
                    [cell configureDefaultCellWithTitle:@"omar@fresconews.com" andCarret:YES andRightAlignedTitle:@""];
                    break;
                case 2:
                    [cell configureDefaultCellWithTitle:@"Update Password" andCarret:YES andRightAlignedTitle:@""];
                    break;
                default:
                    break;
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
                    [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:@"2 mi"];
                    break;
                case 2:
                    [cell configureDefaultCellWithTitle:@"Debit card" andCarret:YES andRightAlignedTitle:@"VISA (3189)"];
                    break;
                case 3:
                    [cell configureDefaultCellWithTitle:@"Add tax info" andCarret:YES andRightAlignedTitle:@""];
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
            [cell configureDefaultCellWithTitle:@"Promo codes" andCarret:YES andRightAlignedTitle:@""];
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
                    [cell configureDefaultCellWithTitle:@"Email support" andCarret:NO andRightAlignedTitle:@""];
                    break;
                case 2:
                    [cell configureDefaultCellWithTitle:@"Disable my account" andCarret:YES andRightAlignedTitle:@""];
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
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    FRSUsernameViewController *username = [[FRSUsernameViewController alloc] init];
                    [self.navigationController pushViewController:username animated:YES];
                    self.navigationItem.title = @"";
                }
                    break;
                case 1:
                {
                    FRSEmailViewController *email = [[FRSEmailViewController alloc] init];
                    [self.navigationController pushViewController:email animated:YES];
                    self.navigationItem.title = @"";
                }
                    break;
                case 2:
                {
                    FRSPasswordChangeViewController *password = [[FRSPasswordChangeViewController alloc] init];
                    [self.navigationController pushViewController:password animated:YES];
                    self.navigationItem.title = @"";
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            //Empty
            break;
        case 2:
            switch (indexPath.row) {
                case 1:
                    NSLog(@"notification radius");
                    break;
                case 2:
                    NSLog(@"debit card");
                    break;
                case 3:
                {
                    FRSTaxInformationViewController *tax = [[FRSTaxInformationViewController alloc] init];
                    [self.navigationController pushViewController:tax animated:YES];
                    self.navigationItem.title = @"";
                }
                    
                    break;
                default:
                    break;
            }
            break;
        case 3:
            //Empty
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    NSLog(@"twitter");
                    break;
                case 1:
                    NSLog(@"facebook");
                    break;
                case 2:
                    NSLog(@"google");
                    break;
                default:
                    break;
            }
            break;
        case 5:
            //Empty
            break;
        case 6:
            NSLog(@"promo");
            
        {
            FRSPromoCodeViewController *promo = [[FRSPromoCodeViewController alloc] init];
            [self.navigationController pushViewController:promo animated:YES];
            self.navigationItem.title = @"";
        }
            
            break;
        case 7:
            //Empty
            break;
        case 8:
            switch (indexPath.row) {
                case 0:
                {
                    FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"LOG OUT?" message:@"We’ll miss you!" actionTitle:@"CANCEL" cancelTitle:@"LOG OUT" delegate:self];
                    [alert show];
                }
                    break;
                case 1:
                    [self presentModalMailComposerViewController:YES];
                    NSLog(@"email support");
                    break;
                case 2:
                    NSLog(@"disable account");
                {
                    
                }
                    break;
            }
            break;
        case 9:
            //Empty
            break;
        default:
            break;
    }
}




- (void)presentModalMailComposerViewController:(BOOL)animated {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        
        [composeViewController setSubject:@"Help!"];
        [composeViewController setMessageBody:@"I've fallen and I can't get up!!!" isHTML:YES];
        [composeViewController setToRecipients:@[@"support@fresconews.com"]];
        
        [self presentViewController:composeViewController animated:animated completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"<#Cannot Send Mail Message#>", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
















@end
