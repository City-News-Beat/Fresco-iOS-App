//
//  FRSSettingsViewController
//  Fresco
//
//  Created by Omar Elfanek on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//


#import "FRSSettingsViewController.h"

/* Categories */
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

/* UI Subclasses */
#import "FRSTableViewCell.h"
#import "FRSAlertView.h"

/* View Controllers */
#import "FRSUsernameViewController.h"
#import "FRSPromoCodeViewController.h"
#import "FRSEmailViewController.h"
#import "FRSPasswordChangeViewController.h"
#import "FRSTaxInformationViewController.h"
#import "FRSDisableAccountViewController.h"
#import "FRSRadiusViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSAboutFrescoViewController.h"

/* Cocoa Pods */
#import <MessageUI/MessageUI.h>

/* API */
#import "FRSAPIClient.h"
#import "FRSSocial.h"


@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *twitterHandle;
@property (strong, nonatomic) FRSTableViewCell *twitterCell;
@property (strong, nonatomic) FRSTableViewCell *facebookCell;
@property (strong, nonatomic) UISwitch *twitterSwitch;
@property (strong, nonatomic) UISwitch *facebookSwitch;

@end

@implementation FRSSettingsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkNotificationStatus];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    
    [self configureBackButtonAnimated:NO];

    [self.navigationItem setTitle:@"SETTINGS"];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)popViewController {
    [super popViewController];
    [self showTabBarAnimated:YES];
}

-(void)configureTableView {
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
    [self configureKenny];
}


#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 12;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
            return 1;
            break;
        case 9:
            return 1;
            break;
        case 10:
            return 3;
            break;
        case 11:
            return 1;
            break;
        case 12:
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
        case 11:
            return 13;
            break;
        default:
            return 44;
            break;
    }
}


#pragma mark - UITableViewDataSource

-(FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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


-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell configureCellWithUsername:[NSString stringWithFormat:@"@%@", [[FRSAPIClient sharedClient] authenticatedUser].username]];
                    break;
                case 1:
                    [cell configureDefaultCellWithTitle:[[FRSAPIClient sharedClient] authenticatedUser].email andCarret:YES andRightAlignedTitle:@""];
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
                    [self checkNotificationStatus];
                    [cell configureAssignmentCellEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"notifications-enabled"]];
                    
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
                    [cell configureFindFriendsCell];
                    break;
                case 1:
                    self.twitterCell = cell;
                    if (self.twitterCell.twitterHandle) {
                        [self.twitterCell configureSocialCellWithTitle:self.twitterHandle andTag:1 enabled:YES];
                        self.twitterCell.twitterSwitch.on = YES;
                    } else {
                        self.twitterCell.twitterSwitch.on = NO;
                        self.twitterHandle = nil;
                        [self.twitterCell configureSocialCellWithTitle:@"Connect Twitter" andTag:1 enabled:NO];
                    }
                    break;
                case 2:
                    self.facebookCell = cell;
                    [cell configureSocialCellWithTitle:@"Connect Facebook" andTag:2 enabled:NO];
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
            [cell configureDefaultCellWithTitle:@"About Fresco" andCarret:YES andRightAlignedTitle:nil];
            break;
        
        case 9:
            [cell configureEmptyCellSpace:NO];
            break;
            
        case 10:
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
        case 11:
            [cell configureEmptyCellSpace:YES];
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
                    FRSEmailViewController *emailViewController = [[FRSEmailViewController alloc] init];
                    [self.navigationController pushViewController:emailViewController animated:YES];
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
                {
                    FRSRadiusViewController *radius = [[FRSRadiusViewController alloc] init];
                    [self.navigationController pushViewController:radius animated:YES];
                    self.navigationItem.title = @"";
                    break;
                }
                case 2:
                {
                    FRSDebitCardViewController *card = [[FRSDebitCardViewController alloc] init];
                    [self.navigationController pushViewController:card animated:YES];
                    self.navigationItem.title = @"";
                }
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
                case 0:{
                    NSLog(@"find friends");
                    FRSAlertView *alert = [[FRSAlertView alloc] initFindFriendsAlert];
                    [alert show];
                }
                    break;
                case 1: {
                    
                    //Twitter
                    //[self.twitterCell twitterToggle];
                    
                } break;
                case 2: {
                    
                    //Facebook
                    //[self.facebookCell facebookToggle];
                    
                } break;
                default:
                    break;
            }
            break;
        case 5:
            //Empty
            break;
        case 6:
        {
            FRSPromoCodeViewController *promo = [[FRSPromoCodeViewController alloc] init];
            [self.navigationController pushViewController:promo animated:YES];
            self.navigationItem.title = @"";
        }
            
            break;
        case 7:
            //Empty
            break;
        case 8: {
            FRSAboutFrescoViewController *about = [[FRSAboutFrescoViewController alloc] init];
            [self.navigationController pushViewController:about animated:YES];
            self.navigationItem.title = @"";
        } break;
        case 9:
            //Empty
            break;
        case 10:
            switch (indexPath.row) {
                case 0: {
                    FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"LOG OUT?" message:@"We'll miss you!" actionTitle:@"CANCEL" cancelTitle:@"LOG OUT" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                    
                    [alert show];
                    
                } break;
                case 1:
                    [self presentModalMailComposerViewController:YES];
                    break;
                case 2:{
//                    FRSAlertView *alert = [[FRSAlertView alloc] initPermissionsAlert];
//                    [alert show];
                    FRSDisableAccountViewController *disableVC = [[FRSDisableAccountViewController alloc] init];
                    [self.navigationController pushViewController:disableVC animated:YES];
                }
                    
                    break;
            }
            break;
        case 11:
            //Empty
            break;
        default:
            break;
    }
}

-(void)configureKenny {
    UILabel *kenny = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -12, self.tableView.frame.size.height*1.9, 24, 24)];
    kenny.text = @"🎷";
    [self.tableView addSubview:kenny];
    [self rotate:kenny];
    
    UILabel *music = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -20, self.tableView.frame.size.height*1.9 -5, 24, 24)];
    music.text = @"🎶";
    music.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self.tableView addSubview:music];
    [self configureTheSongsOfKennyG:music];
}

-(void)rotate:(UILabel *)kenny {
    [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        kenny.transform = CGAffineTransformMakeRotation(M_PI/15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            kenny.transform = CGAffineTransformMakeRotation(-M_PI/15);
        } completion:^(BOOL finished) {
            [self rotate:kenny];
        }];
    }];
}

-(void)configureTheSongsOfKennyG:(UILabel *)music {
    music.alpha = 0;
    music.frame = CGRectMake(self.view.frame.size.width/2 -15, self.tableView.frame.size.height*1.9 -5, 24, 24);
    music.transform = CGAffineTransformMakeScale(0.5, 0.5);

    [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        music.frame = CGRectMake(self.view.frame.size.width/2 -20, self.tableView.frame.size.height*1.9 -15, 24, 24);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            music.alpha = 0;
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        music.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            music.alpha = 0;
        } completion:^(BOOL finished) {
            [self configureTheSongsOfKennyG:music];
        }];
    }];
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)presentModalMailComposerViewController:(BOOL)animated {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        
        [composeViewController setSubject:@"Help!"];
        [composeViewController setMessageBody:@"I've fallen and I can't get up!!!" isHTML:YES];
        [composeViewController setToRecipients:@[@"support@fresconews.com"]];
        
        [self presentViewController:composeViewController animated:animated completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - Notifications

-(void)checkNotificationStatus {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notifications-enabled"];
        } else {
            //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications-enabled"];
        }
    }
}




@end

