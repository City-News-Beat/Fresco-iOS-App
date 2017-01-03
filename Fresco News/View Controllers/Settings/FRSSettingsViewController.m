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
#import "FRSAppDelegate.h"

/* View Controllers */
#import "FRSUsernameViewController.h"
#import "FRSPromoCodeViewController.h"
#import "FRSEmailViewController.h"
#import "FRSPasswordChangeViewController.h"
#import "FRSDisableAccountViewController.h"
#import "FRSRadiusViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSPaymentViewController.h"
#import "FRSAboutFrescoViewController.h"
#import "FRSIdentityViewController.h"

#import <MessageUI/MessageUI.h>
#import <Smooch/Smooch.h>

/* API */
#import "FRSAPIClient.h"
#import "FRSSocial.h"

#import "SAMKeychain.h"

#import "NSDate+ISO.h"

typedef NS_ENUM(NSInteger, SettingsSection) {
    Me,
    Divider1,
    AssignmentsPayments,
    Divider2,
    Social,
    Divider3,
    About,
    Divider4,
    Misc,
    Divider5
};

typedef NS_ENUM(NSInteger, SectionMeRowIndex) {
    ChangeUsername,
    ChangeEmail,
    ChangePassword
};

typedef NS_ENUM(NSInteger, SectionAssignmentsPaymentsRowIndex) {
    AssignmentNotifications,
    NotificationRadius,
    PaymentMethod,
    TaxInfo
};

typedef NS_ENUM(NSInteger, SectionSocialRowIndex) {
    ConnectTwitter,
    ConnectFacebook,
};

typedef NS_ENUM(NSInteger, SectionMiscRowIndex) {
    LogOut,
    Support,
    DisableAccount
};

@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource, FRSAlertViewDelegate>

@property (strong, nonatomic) NSString *twitterHandle;
@property (strong, nonatomic) FRSTableViewCell *twitterCell;
@property (strong, nonatomic) FRSTableViewCell *facebookCell;
@property (strong, nonatomic) UISwitch *twitterSwitch;
@property (strong, nonatomic) UISwitch *facebookSwitch;
@property (strong, nonatomic) FRSTableViewCell *notifCell;

@end

@implementation FRSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self configureKenny];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [FRSTracker screen:@"Settings"];
    
    [self checkNotificationStatus];

    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17] }];

    [self configureBackButtonAnimated:NO];

    [self.navigationItem setTitle:@"SETTINGS"];
    [self.tableView reloadData];

    [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] reloadUser:^(id responseObject, NSError *error) {
      [self.tableView reloadData];

    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)popViewController {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    FRSUser *currentUser = [[FRSAPIClient sharedClient] authenticatedUser];
    int sectionTwo = 4;

    if (currentUser.fieldsNeeded.count == 0) {
        sectionTwo = 3;
    }

    switch (section) {
    case Me:
        return 3;
        break;
    case AssignmentsPayments:
        return sectionTwo;
        break;
    case Social:
        return 2;
        break;
    case About:
        return 1;
        break;
    case Misc:
        return 3;
        break;
    case Divider1:
    case Divider2:
    case Divider3:
    case Divider4:
        return 1;
        break;
    default:
        return 0;
        break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (FRSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
    case Me:
        switch (indexPath.row) {
        case ChangeUsername:
            if ([[FRSAPIClient sharedClient] authenticatedUser].username && ![[[FRSAPIClient sharedClient] authenticatedUser].username isEqual:[NSNull null]]) {
                [cell configureCellWithUsername:[NSString stringWithFormat:@"@%@", [[FRSAPIClient sharedClient] authenticatedUser].username]];
            } else {
                [cell configureCellWithUsername:@"@username"];
            }
            break;
        case ChangeEmail:
            if ([[FRSAPIClient sharedClient] authenticatedUser].email && ![[[FRSAPIClient sharedClient] authenticatedUser].email isEqual:[NSNull null]]) {
                [cell configureDefaultCellWithTitle:[[FRSAPIClient sharedClient] authenticatedUser].email andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            } else {
                [cell configureDefaultCellWithTitle:@"Email" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            }
            break;
        case ChangePassword:
            [cell configureDefaultCellWithTitle:@"Update Password" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            break;
        default:
            break;
        }
        break;

    case AssignmentsPayments:
        switch (indexPath.row) {
        case AssignmentNotifications:
            [self checkNotificationStatus];
            [cell configureAssignmentCellEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:settingsUserNotificationToggle]];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case NotificationRadius:
            if ([[NSUserDefaults standardUserDefaults] objectForKey:settingsUserNotificationRadius] != nil) {
                [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:[NSString stringWithFormat:@"%@ mi", [[[FRSAPIClient sharedClient] authenticatedUser] notificationRadius]] rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            } else {
                [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            }
            break;
        case PaymentMethod: {
            NSString *card = [[NSUserDefaults standardUserDefaults] objectForKey:settingsPaymentLastFour];
            if (!card) {
                card = @"";
            }

            [cell configureDefaultCellWithTitle:@"Payment method" andCarret:YES andRightAlignedTitle:(card) ? card : @"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            break;
        }
        case TaxInfo: {
            NSString *dueBy = [[FRSAPIClient sharedClient] authenticatedUser].dueBy;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
            dateFormat.dateStyle = NSDateFormatterMediumStyle;
            NSDate *date = [dateFormat dateFromString:dueBy];
            NSString *dateString = [NSString stringWithFormat:@"Add by %@", date];

            if (dueBy != nil) {
                [cell configureDefaultCellWithTitle:@"ID Info" andCarret:YES andRightAlignedTitle:dateString rightAlignedTitleColor:[UIColor frescoBlueColor]];

            } else {
                if ([[FRSAPIClient sharedClient] authenticatedUser].fieldsNeeded.count == 0) {
                    [cell configureDefaultCellWithTitle:@"ID Info" andCarret:YES andRightAlignedTitle:@"Verified" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
                } else {
                    [cell configureDefaultCellWithTitle:@"ID Info" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
                }
            }
            break;
        }
        default:
            break;
        }
        break;

    case Social:
        switch (indexPath.row) {
        case ConnectTwitter:
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
        case ConnectFacebook:
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

    case About:
        [cell configureDefaultCellWithTitle:@"About Fresco" andCarret:YES andRightAlignedTitle:nil rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
        break;

    case Misc:
        switch (indexPath.row) {
        case LogOut:
            [cell configureLogOut];
            break;
        case Support:
            [cell configureDefaultCellWithTitle:@"Ask us anything" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            break;
        case DisableAccount:
            [cell configureDefaultCellWithTitle:@"Disable my account" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
            break;
        }
        break;

    case Divider1:
    case Divider2:
    case Divider3:
    case Divider4:
        [cell configureEmptyCellSpace:NO];
        break;

    default:
        break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
    case Me:
        switch (indexPath.row) {
        case ChangeUsername: {
            FRSUsernameViewController *username = [[FRSUsernameViewController alloc] init];
            [self.navigationController pushViewController:username animated:YES];
            break;
        }
        case ChangeEmail: {
            FRSEmailViewController *emailViewController = [[FRSEmailViewController alloc] init];
            [self.navigationController pushViewController:emailViewController animated:YES];
            break;
        }
        case ChangePassword: {
            FRSPasswordChangeViewController *password = [[FRSPasswordChangeViewController alloc] init];
            [self.navigationController pushViewController:password animated:YES];
            break;
        }
        }
        break;

    case AssignmentsPayments:
        switch (indexPath.row) {
        case AssignmentNotifications:
            break;
        case NotificationRadius: {
            FRSRadiusViewController *radius = [[FRSRadiusViewController alloc] init];
            [self.navigationController pushViewController:radius animated:YES];
            break;
        }
        case PaymentMethod: {
            FRSPaymentViewController *card = [[FRSPaymentViewController alloc] init];
            [self.navigationController pushViewController:card animated:YES];
            break;
        }
        case TaxInfo: {
            FRSIdentityViewController *identity = [[FRSIdentityViewController alloc] init];
            [self.navigationController pushViewController:identity animated:YES];
            break;
        }
        }
        break;

    case About: {
        FRSAboutFrescoViewController *about = [[FRSAboutFrescoViewController alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    } break;

    case Misc:
        switch (indexPath.row) {
        case LogOut: {
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"LOG OUT?" message:@"We'll miss you!" actionTitle:@"CANCEL" cancelTitle:@"LOG OUT" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
            [alert show];
            break;
        }
        case Support:
            [self presentSmooch];
            break;
        case DisableAccount: {
            FRSDisableAccountViewController *disableVC = [[FRSDisableAccountViewController alloc] init];
            [self.navigationController pushViewController:disableVC animated:YES];
            break;
        }
        }
        break;

    default:
        break;
    }
}

- (void)configureKenny {
    UILabel *kenny = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 12, self.tableView.frame.size.height * 1.6, 24, 24)];
    kenny.text = @"🎷";
    [self.tableView addSubview:kenny];
    [self rotate:kenny];

    UILabel *music = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 20, self.tableView.frame.size.height * 1.6 - 5, 24, 24)];
    music.text = @"🎶";
    music.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self.tableView addSubview:music];
    [self configureTheSongsOfKennyG:music];
}

- (void)rotate:(UILabel *)kenny {
    [UIView animateWithDuration:1.0
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          kenny.transform = CGAffineTransformMakeRotation(M_PI / 15);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:1.0
              delay:0.0
              options:UIViewAnimationOptionCurveEaseInOut
              animations:^{
                kenny.transform = CGAffineTransformMakeRotation(-M_PI / 15);
              }
              completion:^(BOOL finished) {
                [self rotate:kenny];
              }];
        }];
}

- (void)configureTheSongsOfKennyG:(UILabel *)music {
    music.alpha = 0;
    music.frame = CGRectMake(self.view.frame.size.width / 2 - 15, self.tableView.frame.size.height * 1.6 - 5, 24, 24);
    music.transform = CGAffineTransformMakeScale(0.5, 0.5);

    [UIView animateWithDuration:1.0
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          music.frame = CGRectMake(self.view.frame.size.width / 2 - 20, self.tableView.frame.size.height * 1.6 - 15, 24, 24);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:1.0
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             music.alpha = 0;
                           }
                           completion:nil];
        }];

    [UIView animateWithDuration:0.5
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          music.alpha = 1;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.5
              delay:0.0
              options:UIViewAnimationOptionCurveEaseInOut
              animations:^{
                music.alpha = 0;
              }
              completion:^(BOOL finished) {
                [self configureTheSongsOfKennyG:music];
              }];
        }];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)presentMail {
    [self presentModalMailComposerViewController:YES];
}

- (void)presentModalMailComposerViewController:(BOOL)animated {

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;

        [composeViewController setSubject:@"Help!"];
        [composeViewController setMessageBody:@"I've fallen and I can't get up!!!" isHTML:YES];
        [composeViewController setToRecipients:@[ @"support@fresconews.com" ]];

        [self presentViewController:composeViewController animated:animated completion:nil];
    } else {
        //cc:imogen
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Cannot Send Mail Message", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FRSAlertView Delegate
- (void)didPressButtonAtIndex:(NSInteger)index {
    //for logout alert
    if (index == 0) {
    } else if (index == 1) {
        [self logoutWithPop:YES];
    }
}

#pragma mark - Notifications

- (void)checkNotificationStatus {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];

        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:settingsUserNotificationToggle];
        } else {
            //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:settingsUserNotificationTogglet];
        }
    }
}

@end
