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
#import "FRSAlertView.h"
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
#import "FRSSocial.h"
#import "SAMKeychain.h"
#import "NSDate+ISO.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSModerationManager.h"
#import "FRSNotificationManager.h"
#import "FRSSettingsTextTableViewCell.h"
#import "FRSSocialToggleTableViewCell.h"
#import "FRSLogOutTableViewCell.h"
#import "FRSAssignmentNotificationsSwitchTableViewCell.h"

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

@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource, FRSAlertViewDelegate, FRSAssignmentNotificationsSwitchTableViewCellDelegate, FRSSocialToggleTableViewCellDelegate>

//@property (strong, nonatomic) NSString *twitterHandle;
//@property (strong, nonatomic) FRSTableViewCell *twitterCell;
//@property (strong, nonatomic) FRSTableViewCell *facebookCell;
//@property (strong, nonatomic) UISwitch *twitterSwitch;
//@property (strong, nonatomic) UISwitch *facebookSwitch;
@property (strong, nonatomic) FRSTableViewCell *notifCell;

@end

@implementation FRSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self configureKenny];

    [self.tableView registerNib:[UINib nibWithNibName:@"FRSSettingsTextTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:settingsTextCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSSocialToggleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:socialToggleCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLogOutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:logOutCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAssignmentNotificationsSwitchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:assignmentNotficationsSwitchCellIdentifier];
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

    [[FRSUserManager sharedInstance] reloadUser:^(id responseObject, NSError *error) {
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

    FRSUser *currentUser = [[FRSUserManager sharedInstance] authenticatedUser];

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const emptyCellIdentifier = @"empty-cell";
    switch (indexPath.section) {
    case Me:
        switch (indexPath.row) {
        case ChangeUsername: {
            NSString *username = [NSString stringWithFormat:@"@%@", [[FRSUserManager sharedInstance] authenticatedUser].username];
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            [cell loadText:username withSecondary:nil withDisclosureIndicator:YES andFont:[UIFont notaMediumWithSize:17]];
            return cell;
        }
        case ChangeEmail: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            [cell loadText:[[FRSUserManager sharedInstance] authenticatedUser].email];
            return cell;
        }
        case ChangePassword: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            [cell loadText:@"Update Password"];
            return cell;
        }
        default:
            break;
        }
        break;
    case AssignmentsPayments:
        switch (indexPath.row) {
        case AssignmentNotifications: {
            FRSAssignmentNotificationsSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:assignmentNotficationsSwitchCellIdentifier];
            cell.delegate = self;
            [cell notificationsEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"notifications-enabled"]];
            return cell;
        }
        case NotificationRadius: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:settingsUserNotificationRadius]) {
                [cell loadText:@"Notification radius" withSecondary:[NSString stringWithFormat:@"%@ mi", [[[FRSUserManager sharedInstance] authenticatedUser] notificationRadius]] withDisclosureIndicator:YES andFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
            } else {
                [cell loadText:@"Notification radius"];
            }
            return cell;
        }
        case PaymentMethod: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            [cell loadText:@"Payment Method"];
            return cell;
        }
        case TaxInfo: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            NSString *dueBy = [[FRSUserManager sharedInstance] authenticatedUser].dueBy;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
            dateFormat.dateStyle = NSDateFormatterMediumStyle;
            NSDate *date = [dateFormat dateFromString:dueBy];
            NSString *dateString = [NSString stringWithFormat:@"Add by %@", date];
            if (dueBy) {
                [cell loadText:@"ID Info" withSecondary:dateString withSecondaryColor:[UIColor frescoBlueColor]];
            } else {
                if ([[FRSUserManager sharedInstance] authenticatedUser].fieldsNeeded.count == 0) {
                    [cell loadText:@"ID Info" withSecondary:@"Verified" withSecondaryColor:[UIColor frescoMediumTextColor]];
                } else {
                    [cell loadText:@"ID Info"];
                }
            }
            return cell;
        }
        default:
            break;
        }
        break;
        case Social:
            switch (indexPath.row) {
                case ConnectTwitter:
                {
                    FRSSocialToggleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:socialToggleCellIdentifier];
                    cell.delegate = self;
                    [cell setupText:@"Connect Twitter" withImage:[UIImage imageNamed:@"social-twitter"] andSwitchColor:[UIColor twitterBlueColor]];
                    return cell;
                }
                case ConnectFacebook: {
                    FRSSocialToggleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:socialToggleCellIdentifier];
                    cell.delegate = self;
                    [cell setupText:@"Connect Facebook" withImage:[UIImage imageNamed:@"social-facebook"] andSwitchColor:[UIColor twitterBlueColor]];
                    return cell;
                }
                default:
                    break;
            }
            break;
        case About: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            [cell loadText:@"About Fresco"];
            return cell;
        }
        case Misc:
            switch (indexPath.row) {
                case LogOut:{
                    FRSLogOutTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:logOutCellIdentifier];
                    return cell;
                }
                case Support: {
                    FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
                    [cell loadText:@"Ask us anything"];
                    return cell;
                }
                case DisableAccount: {
                    FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
                    [cell loadText:@"Disable my account"];
                    return cell;
                }
                default:
                    break;
            }
            break;
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:emptyCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellIdentifier];
        cell.alpha = 0;
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//    case Me:
//        switch (indexPath.row) {
//        case ChangeUsername:
//            if ([[FRSUserManager sharedInstance] authenticatedUser].username && ![[[FRSUserManager sharedInstance] authenticatedUser].username isEqual:[NSNull null]]) {
//                [cell configureCellWithUsername:[NSString stringWithFormat:@"@%@", [[FRSUserManager sharedInstance] authenticatedUser].username]];
//            } else {
//                [cell configureCellWithUsername:@"@username"];
//            }
//            break;
//        case ChangeEmail:
//            if ([[FRSUserManager sharedInstance] authenticatedUser].email && ![[[FRSUserManager sharedInstance] authenticatedUser].email isEqual:[NSNull null]]) {
//                [cell configureDefaultCellWithTitle:[[FRSUserManager sharedInstance] authenticatedUser].email andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            } else {
//                [cell configureDefaultCellWithTitle:@"Email" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            }
//            break;
//        case ChangePassword:
//            [cell configureDefaultCellWithTitle:@"Update Password" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            break;
//        default:
//            break;
//        }
//        break;
//
//    case AssignmentsPayments:
//        switch (indexPath.row) {
//        case AssignmentNotifications:
//            [self checkNotificationStatus];
//
//            [cell configureAssignmentCellEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"notifications-enabled"]];
//
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            break;
//        case NotificationRadius:
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:settingsUserNotificationRadius] != nil) {
//                [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:[NSString stringWithFormat:@"%@ mi", [[[FRSUserManager sharedInstance] authenticatedUser] notificationRadius]] rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            } else {
//                [cell configureDefaultCellWithTitle:@"Notification radius" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            }
//            break;
//        case PaymentMethod: {
//            NSString *card = [[NSUserDefaults standardUserDefaults] objectForKey:settingsPaymentLastFour];
//            if (!card) {
//                card = @"";
//            }
//
//            [cell configureDefaultCellWithTitle:@"Payment method" andCarret:YES andRightAlignedTitle:(card) ? card : @"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            break;
//        }
//        case TaxInfo: {
//            NSString *dueBy = [[FRSUserManager sharedInstance] authenticatedUser].dueBy;
//            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//            dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
//            dateFormat.dateStyle = NSDateFormatterMediumStyle;
//            NSDate *date = [dateFormat dateFromString:dueBy];
//            NSString *dateString = [NSString stringWithFormat:@"Add by %@", date];
//
//            if (dueBy != nil) {
//                [cell configureDefaultCellWithTitle:@"ID Info" andCarret:YES andRightAlignedTitle:dateString rightAlignedTitleColor:[UIColor frescoBlueColor]];
//
//            } else {
//                if ([[FRSUserManager sharedInstance] authenticatedUser].fieldsNeeded.count == 0) {
//                    [cell configureDefaultCellWithTitle:@"ID Info" andCarret:YES andRightAlignedTitle:@"Verified" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//                } else {
//                    [cell configureDefaultCellWithTitle:@"ID Info" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//                }
//            }
//            break;
//        }
//        default:
//            break;
//        }
//        break;
//
//    case Social:
//        switch (indexPath.row) {
//        case ConnectTwitter:
//            self.twitterCell = cell;
//            self.twitterCell.parentTableView = tableView;
//            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"twitter-handle"]) {
//                [self.twitterCell configureSocialCellWithTitle:self.twitterHandle andTag:1 enabled:YES];
//                self.twitterCell.twitterSwitch.on = YES;
//            } else {
//                self.twitterCell.twitterSwitch.on = NO;
//                self.twitterHandle = nil;
//                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"twitter-connected"]) {
//                    [self.twitterCell configureSocialCellWithTitle:@"Twitter Connected" andTag:1 enabled:YES];
//                } else {
//                    [self.twitterCell configureSocialCellWithTitle:@"Connect Twitter" andTag:1 enabled:NO];
//                }
//            }
//            break;
//        case ConnectFacebook:
//            self.facebookCell = cell;
//            self.facebookCell.parentTableView = tableView;
//
//            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"facebook-name"]) {
//                [cell configureSocialCellWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"facebook-name"] andTag:2 enabled:[[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-enabled"]];
//            } else {
//                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-connected"]) {
//                    [cell configureSocialCellWithTitle:@"Facebook Connected" andTag:2 enabled:YES];
//                } else {
//                    [cell configureSocialCellWithTitle:@"Connect Facebook" andTag:2 enabled:NO];
//                }
//            }
//            break;
//
//        default:
//            break;
//        }
//        break;
//
//    case About:
//        [cell configureDefaultCellWithTitle:@"About Fresco" andCarret:YES andRightAlignedTitle:nil rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//        break;
//
//    case Misc:
//        switch (indexPath.row) {
//        case LogOut:
//            [cell configureLogOut];
//            break;
//        case Support:
//            [cell configureDefaultCellWithTitle:@"Ask us anything" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            break;
//        case DisableAccount:
//            [cell configureDefaultCellWithTitle:@"Disable my account" andCarret:YES andRightAlignedTitle:@"" rightAlignedTitleColor:[UIColor frescoMediumTextColor]];
//            break;
//        }
//        break;
//
//    case Divider1:
//    case Divider2:
//    case Divider3:
//    case Divider4:
//        [cell configureEmptyCellSpace:NO];
//        break;
//
//    default:
//        break;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
            [[FRSModerationManager sharedInstance] presentSmooch];
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
    UILabel *kenny = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 + 5, self.tableView.frame.size.height * 1.6 + 8, 24, 24)];
    kenny.text = @"🎷";
    [self.tableView addSubview:kenny];
    [self rotate:kenny];

    UILabel *music = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 - 20, self.tableView.frame.size.height * 1.6 - 5, 24, 24)];
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

- (void)checkNotificationStatus {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];

        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:settingsUserNotificationToggle];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:settingsUserNotificationToggle];
        }
    }
}

- (void)checkLocationStatus {
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:locationEnabled];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:locationEnabled];
    }
}

- (void)didToggleNotifications:(id)sender {
    [self checkNotificationStatus];
    [self checkLocationStatus];

    if ([sender isOn]) {
        FRSUser *user = [[FRSUserManager sharedInstance] authenticatedUser];
        float radius = 10;

        if ([user.notificationRadius floatValue] > 0) {
            radius = [user.notificationRadius floatValue];
        }

        [[FRSNotificationManager sharedInstance] setPushNotificationWithBool:YES
                                                                  completion:^(id responseObject, NSError *error) {
                                                                    if (responseObject && !error) {
                                                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications-enabled"];
                                                                        [[NSUserDefaults standardUserDefaults] synchronize];

                                                                    } else {
                                                                        [sender setOn:NO];
                                                                        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"We could not connect to Fresco News. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                                        [alert show];
                                                                    }
                                                                  }];
    } else {
        [[FRSNotificationManager sharedInstance] setPushNotificationWithBool:NO
                                                                  completion:^(id responseObject, NSError *error) {
                                                                    if (responseObject && !error) {
                                                                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notifications-enabled"];
                                                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                                                    } else {
                                                                        [sender setOn:YES];
                                                                        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"We could not connect to Fresco News. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                                        [alert show];
                                                                    }
                                                                  }];
    }
}

- (void)didToggleTwitter:(id)sender withLabel:(UILabel *)label {

//    self.didToggleTwitter = YES;
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"twitter-handle"]) {
        
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"DISCONNECT TWITTER?" message:@"You’ll be unable to use your Twitter account for logging in and sharing galleries." actionTitle:@"CANCEL" cancelTitle:@"DISCONNECT" cancelTitleColor:[UIColor frescoRedColor] delegate:self];
        alert.delegate = self;
        [alert show];
        
        [[FRSAuthManager sharedInstance] unlinkTwitter:^(id responseObject, NSError *error) {
            NSLog(@"Disconnect Twitter Error: %@", error);
        }];
        
    } else {
        [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token, NSDictionary *user) {
        
            [sender setUserInteractionEnabled:YES];
            
            if (session) {
                [[FRSAuthManager sharedInstance] linkTwitter:session.authToken
                                                      secret:session.authTokenSecret
                                                  completion:^(id responseObject, NSError *error) {
                                                      if (responseObject && !error) {
                                                          [sender setOn:YES animated:YES];
                                                          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"twitter-connected"];
                                                          label.text = session.userName;
                                                          [[NSUserDefaults standardUserDefaults] setValue:label.text forKey:@"twitter-handle"];
                                                      } else {
                                                          NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                          NSInteger responseCode = response.statusCode;
                                                          
                                                          if (responseCode == 412) {
                                                              [sender setOn:NO animated:YES];
                                                              [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];
                                                              
                                                              NSString *ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                              NSError *jsonError;
                                                              
                                                              NSDictionary *jsonErrorResponse = [NSJSONSerialization JSONObjectWithData:[ErrorResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
                                                              NSString *errorMessage = jsonErrorResponse[@"error"][@"msg"];
                                                              
                                                              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                              [alert show];
                                                              return;
                                                          } else {
                                                              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"We could not connect to Twitter. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                              [alert show];
                                                              return;
                                                          }
                                                      }
                                                  }];
                
            } else if (error) {
                FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to connect Twitter. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                [alert show];
            }
        }];
    }
}

- (void)didToggleFacebook:(id)sender withLabel:(UILabel *)label {
    
//    self.didToggleFacebook = YES;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-connected"]) {
        
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"DISCONNECT FACEBOOK?" message:@"You’ll be unable to use your Facebook account for logging in and sharing galleries." actionTitle:@"CANCEL" cancelTitle:@"DISCONNECT" cancelTitleColor:[UIColor frescoRedColor] delegate:self];
        alert.delegate = self;
        [alert show];
        
        [sender setOn:NO];
//        sender.
//        self.facebookSwitch.on = NO;
//        self.facebookSwitch.enabled = NO;
        [[FRSAuthManager sharedInstance] unlinkFacebook:^(id responseObject, NSError *error) {
            NSLog(@"Disconnect Facebook Error: %@", error);
//            self.facebookSwitch.enabled = YES;
            if (error) {
                [sender setOn:YES];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebook-connected"];
                [[NSUserDefaults standardUserDefaults] setValue:Nil forKey:@"facebook-name"];
                  [sender setOn:YES];
            }
            [self.tableView reloadData];
        }];
        
    } else {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
         [sender setOn:YES];
//        self.facebookSwitch.enabled = NO;
//        self.facebookSwitch.on = YES;
        [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                     fromViewController:self.inputViewController
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    
                                    if (error) {
                                         [sender setOn:NO];
//                                        self.facebookSwitch.on = NO;
//                                        self.facebookSwitch.enabled = YES;
                                    }
                                    
                                    if (result && !error) {
                                        
                                        [[FRSAuthManager sharedInstance] linkFacebook:[FBSDKAccessToken currentAccessToken].tokenString
                                                                           completion:^(id responseObject, NSError *error) {
                                                                               [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"facebook-connected"];
                                                                                [sender setOn:NO animated:YES];
//                                                                               [self.facebookSwitch setOn:YES animated:YES];
//                                                                               self.facebookSwitch.alpha = 0;
                                                                               
//                                                                               self.facebookSwitch.enabled = YES;
                                                                               
                                                                               if (error) {
                                                                                    [sender setOn:NO];
//                                                                                   self.facebookSwitch.on = NO;
//                                                                                   self.facebookSwitch.enabled = YES;
                                                                               } else {
                                                                                    [sender setOn:YES];
//                                                                                   self.facebookSwitch.on = YES;
                                                                               }
                                                                               
                                                                               if (responseObject && !error) {
                                                                                   [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"name" }] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                                                       if (!error) {
                                                                                           label.text = [result valueForKey:@"name"];
                                                                                           [[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"name"] forKey:@"facebook-name"];
                                                                                           [sender setOn:YES];
                                                                                           [self.tableView reloadData];
                                                                                       }
                                                                                   }];
                                                                               } else if (error) {
                                                                                   [sender setOn:NO];
//                                                                                   self.facebookSwitch.on = NO;
//                                                                                   self.facebookSwitch.enabled = YES;
                                                                                   NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                                                   NSInteger responseCode = response.statusCode;
                                                                                   
                                                                                   if (responseCode == 412) {
                                                                                       [sender setOn:NO animated:YES];
//                                                                                       [self.facebookSwitch setOn:FALSE animated:YES];
                                                                                       [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"facebook-connected"];
                                                                                       
                                                                                       NSString *ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                                                       NSError *jsonError;
                                                                                       
                                                                                       NSDictionary *jsonErrorResponse = [NSJSONSerialization JSONObjectWithData:[ErrorResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
                                                                                       NSString *errorMessage = jsonErrorResponse[@"error"][@"msg"];
                                                                                       
                                                                                       FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                                                       [alert show];
                                                                                       return;
                                                                                   } else {
                                                                                       FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"We could not connect to Facebook. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                                                       [alert show];
                                                                                       return;
                                                                                   }
                                                                               }
                                                                               if (self.tableView) {
                                                                                   [self.tableView reloadData];
                                                                               }
                                                                           }];
                                    }
                                    if (self.tableView) {
                                        [self.tableView reloadData];
                                    }
                                }];
    }
}

#pragma mark - FRSAlertView Delegate
- (void)didPressButtonAtIndex:(NSInteger)index {
    //for logout alert
    if (index == 0) {
    } else if (index == 1) {
        [self logoutWithPop:YES];
    }
}

@end
