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

#import <MessageUI/MessageUI.h>
#import <Smooch/Smooch.h>

/* API */
#import "FRSAPIClient.h"
#import "FRSSocial.h"

#import "SSKeychain.h"


@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource, FRSAlertViewDelegate>

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

-(void)smooch {
    FRSUser *currentUser = [[FRSAPIClient sharedClient] authenticatedUser];
    
    if (currentUser.firstName) {
        [SKTUser currentUser].firstName = currentUser.firstName;
    }
    
    if (currentUser.email) {
        [SKTUser currentUser].email = currentUser.email;
    }
    
    if (currentUser.uid) {
        [[SKTUser currentUser] addProperties:@{ @"Fresco ID" : currentUser.uid }];
    }
    
    [Smooch show];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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
    return 10;
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
            return 2;
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
        case 10:
            return 3;
            break;
//        case 11:
//            return 1;
//            break;
//        case 12:
//            return 1;
//            break;
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
                    
                     if ([[NSUserDefaults standardUserDefaults] objectForKey:@"notification-radius"] != nil) {
                         NSNumber *notifRadius = [[NSUserDefaults standardUserDefaults] objectForKey:@"notification-radius"];
                         
                         if ([notifRadius integerValue] <= 1) {
                             [cell configureAssignmentCellEnabled:NO];
                         } else {
                             [cell configureAssignmentCellEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"notifications-enabled"]];
                         }
                     } else {
                         [cell configureAssignmentCellEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"notifications-enabled"]];
                     }
                    
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"notification-radius"] != nil) {
                        NSString *miles = [[NSUserDefaults standardUserDefaults] objectForKey:@"notification-radius"];
                        CGFloat milesFloat = [miles floatValue];
                        [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:[NSString stringWithFormat:@"%.0f mi", milesFloat]];
                    } else {
                        [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:@""];
                    }
                break;
                case 2: {
                    NSString *card = (NSString *)[[[FRSAPIClient sharedClient] authenticatedUser] valueForKey:@"creditCardDigits"];
                    
                    
                    [cell configureDefaultCellWithTitle:@"Debit card" andCarret:YES andRightAlignedTitle:(card) ? card : @""];
                }
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
//                    [cell configureFindFriendsCell];
                    
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
                case 1:
                    self.facebookCell = cell;
                    
                    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"facebook-name"]) {
                        [cell configureSocialCellWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"facebook-name"] andTag:2 enabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-enabled"]];
                        
                    } else {
                        [cell configureSocialCellWithTitle:@"Connect Facebook" andTag:2 enabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-enabled"]];
                    }
                    break;

                default:
                    break;
            }
            break;
        case 5:
            [cell configureEmptyCellSpace:NO];
            break;
        case 6:
            [cell configureDefaultCellWithTitle:@"About Fresco" andCarret:YES andRightAlignedTitle:nil];
            //[cell configureDefaultCellWithTitle:@"Promo codes" andCarret:YES andRightAlignedTitle:@""];
            break;
            
        case 7:
            [cell configureEmptyCellSpace:NO];
            break;

//        case 8:
//            //[cell configureDefaultCellWithTitle:@"About Fresco" andCarret:YES andRightAlignedTitle:nil];
//            break;
//        
//        case 9:
//            //[cell configureEmptyCellSpace:NO];
//            break;
            
        case 8:
            switch (indexPath.row) {
                case 0:
                    [cell configureLogOut];
                    break;
                case 1:
                    [cell configureDefaultCellWithTitle:@"Ask us anything" andCarret:YES andRightAlignedTitle:@""];
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
//                    FRSAlertView *alert = [[FRSAlertView alloc] initFindFriendsAlert];
//                    [alert show];
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
//            FRSPromoCodeViewController *promo = [[FRSPromoCodeViewController alloc] init];
//            [self.navigationController pushViewController:promo animated:YES];
//            self.navigationItem.title = @"";
            
            FRSAboutFrescoViewController *about = [[FRSAboutFrescoViewController alloc] init];
            [self.navigationController pushViewController:about animated:YES];
            self.navigationItem.title = @"";
        }
            
            break;
        case 7:
            //Empty
            break;
//        case 8: {
//            FRSAboutFrescoViewController *about = [[FRSAboutFrescoViewController alloc] init];
//            [self.navigationController pushViewController:about animated:YES];
//            self.navigationItem.title = @"";
//        } break;
//        case 9:
//            //Empty
//            break;
        case 8:
            switch (indexPath.row) {
                case 0: {
                    FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"LOG OUT?" message:@"We'll miss you!" actionTitle:@"CANCEL" cancelTitle:@"LOG OUT" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                    
                    [alert show];
                    
                } break;
                case 1:
                    [self smooch];
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

-(void)presentMail {
    [self presentModalMailComposerViewController:YES];
}

-(void)presentModalMailComposerViewController:(BOOL)animated {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        
        [composeViewController setSubject:@"Help!"];
        [composeViewController setMessageBody:@"I've fallen and I can't get up!!!" isHTML:YES];
        [composeViewController setToRecipients:@[@"support@fresconews.com"]];
        
        [self presentViewController:composeViewController animated:animated completion:nil];
    } else {
        //cc:imogen
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Cannot Send Mail Message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - FRSAlertView Delegate
-(void)didPressButtonAtIndex:(NSInteger)index {
    //for logout alert
    if (index == 0) {
        NSLog(@"index 0");
    } else if (index == 1) {
        [self logout];
    }
}

-(void)logout {
    
    [[[FRSAPIClient sharedClient] managedObjectContext] deleteObject:[FRSAPIClient sharedClient].authenticatedUser];
    [[[FRSAPIClient sharedClient] managedObjectContext] save:nil];
    
    [SSKeychain deletePasswordForService:serviceName account:clientAuthorization];

    [NSUserDefaults resetStandardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"facebook-name"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebook-connected"];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"twitter-handle"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notification-radius"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notifications-enabled"];

    [self popViewController];
    
    [self.tabBarController setSelectedIndex:0];
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

