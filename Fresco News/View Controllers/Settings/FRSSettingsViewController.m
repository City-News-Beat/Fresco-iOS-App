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
#import "FRSAlertView.h"
#import "FRSUsernameViewController.h"
#import "FRSEmailViewController.h"
#import "FRSPasswordChangeViewController.h"
#import "FRSDisableAccountViewController.h"
#import "FRSRadiusViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSPaymentViewController.h"
#import "FRSAboutFrescoViewController.h"
#import "FRSIdentityViewController.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSModerationManager.h"
#import "FRSNotificationManager.h"
#import "FRSSettingsTextTableViewCell.h"
#import "FRSSocialToggleTableViewCell.h"
#import "FRSLogOutTableViewCell.h"
#import "FRSAssignmentNotificationsSwitchTableViewCell.h"
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskProviderSDK/ZendeskProviderSDK.h>

static NSInteger const fbAlertTag = 33;
static NSInteger const twAlertTag = 34;
static NSInteger const emptyCellHeight = 13;

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
    FAQ,
    Support,
    DisableAccount
};

@interface FRSSettingsViewController () <UITableViewDelegate, UITableViewDataSource, FRSAlertViewDelegate, FRSAssignmentNotificationsSwitchTableViewCellDelegate, FRSSocialToggleTableViewCellDelegate>

//@property (strong, nonatomic) NSString *twitterHandle;
@property (strong, nonatomic) FRSSocialToggleTableViewCell *twitterCell;
@property (strong, nonatomic) FRSSocialToggleTableViewCell *facebookCell;
//@property (strong, nonatomic) UISwitch *twitterSwitch;
//@property (strong, nonatomic) UISwitch *facebookSwitch;

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView reloadData];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationItem setTitle:@"Settings"];
    
    // Setting the alpha of the tabBar to 0 makes the transition into the Zendesk SDK detail views more appealing.
    self.tabBarController.tabBar.alpha = 0;
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
        return 4;
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
        case Me:
            switch (indexPath.row) {
                case ChangeUsername:
                    return settingsTextUsernameCellHeight;
                case ChangeEmail:
                case ChangePassword:
                    return settingsTextCellHeight;
            }
            break;
        case AssignmentsPayments:
            switch (indexPath.row) {
                case AssignmentNotifications:
                    return assignmentNotficationsSwitchCellHeight;
                case NotificationRadius:
                case PaymentMethod:
                case TaxInfo:
                    return settingsTextCellHeight;
            }
            break;
        case Social:
            switch (indexPath.row) {
                case ConnectTwitter:
                case ConnectFacebook:
                    return socialToggleCellHeight;
            }
            break;
        case About: {
            return settingsTextCellHeight;
        }
        case Misc:
            switch (indexPath.row) {
                case LogOut:
                    return logOutCellHeight;
                case Support:
                case FAQ:
                case DisableAccount:
                    return settingsTextCellHeight;
            }
            break;
    }
    return emptyCellHeight;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const emptyCellIdentifier = @"empty-cell";
    switch (indexPath.section) {
    case Me:
        switch (indexPath.row) {
        case ChangeUsername: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            if ([[FRSUserManager sharedInstance] authenticatedUser].username && ![[[FRSUserManager sharedInstance] authenticatedUser].username isEqual:[NSNull null]]) {
                NSString *username = [NSString stringWithFormat:@"@%@", [[FRSUserManager sharedInstance] authenticatedUser].username];
                [cell loadText:username withSecondary:nil withDisclosureIndicator:YES andFont:[UIFont notaMediumWithSize:17]];
            } else {
                [cell loadText:@"@username" withSecondary:nil withDisclosureIndicator:YES andFont:[UIFont notaMediumWithSize:17]];
            }
            return cell;
        }
        case ChangeEmail: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            if ([[FRSUserManager sharedInstance] authenticatedUser].email && ![[[FRSUserManager sharedInstance] authenticatedUser].email isEqual:[NSNull null]]) {
                [cell loadText:[[FRSUserManager sharedInstance] authenticatedUser].email];
            } else {
                [cell loadText:@"Email"];
            }
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
            [cell notificationsEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:settingsUserNotificationToggle]];
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
        case ConnectTwitter: {
            FRSSocialToggleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:socialToggleCellIdentifier];
            cell.delegate = self;
            [cell setupImage:[UIImage imageNamed:@"social-twitter"] andSwitchColor:[UIColor twitterBlueColor] type:TwitterType];
            self.twitterCell = cell;
            return cell;
        }
        case ConnectFacebook: {
            FRSSocialToggleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:socialToggleCellIdentifier];
            cell.delegate = self;
            [cell setupImage:[UIImage imageNamed:@"social-facebook"] andSwitchColor:[UIColor facebookBlueColor] type:FacebookType];
            self.facebookCell = cell;
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
        case LogOut: {
            FRSLogOutTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:logOutCellIdentifier];
            return cell;
        }
        case FAQ: {
            FRSSettingsTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:settingsTextCellIdentifier];
            [cell loadText:@"FAQ"];
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
            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"LOG OUT?" message:@"We'll miss you!" actionTitle:@"CANCEL" cancelTitle:@"LOG OUT" cancelTitleColor:nil delegate:self];
            [alert show];
            break;
        }
        case FAQ:
            [self presentHelpcenter];
            break;
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

#pragma mark - Zendesk

- (void)presentHelpcenter {
    // Create a Content Model to pass in
    ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
    // Disable requests
    [ZDKHelpCenter setNavBarConversationsUIType:ZDKNavBarConversationsUITypeNone];
    // Show Help Center
    [ZDKHelpCenter pushHelpCenterOverview:self.navigationController withContentModel:helpCenterContentModel];
    
    // Track event
    [FRSTracker track:FAQOpened];
}

#pragma mark - Easter Egg

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
                                                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:settingsUserNotificationToggle];
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
                                                                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:settingsUserNotificationToggle];
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
    if ([[NSUserDefaults standardUserDefaults] valueForKey:twitterHandle]) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"DISCONNECT TWITTER?" message:@"You’ll be unable to use your Twitter account for logging in and sharing galleries." actionTitle:@"CANCEL" cancelTitle:@"DISCONNECT" cancelTitleColor:[UIColor frescoRedColor] delegate:self];
        alert.tag = twAlertTag;
        alert.delegate = self;
        [alert show];

        [[FRSAuthManager sharedInstance] unlinkTwitter:^(id responseObject, NSError *error) {
            DDLogError(@"Disconnect Twitter Error: %@", error);
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
                                                      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:twitterConnected];
                                                      label.text = session.userName;
                                                      [[NSUserDefaults standardUserDefaults] setValue:label.text forKey:twitterHandle];
                                                  } else {
                                                      NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                      NSInteger responseCode = response.statusCode;
                                                      NSString *errorMessage;
                                                      if (responseCode == 412) {
                                                          [sender setOn:NO animated:YES];
                                                          [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];

                                                          NSString *ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                          NSError *jsonError;

                                                          NSDictionary *jsonErrorResponse = [NSJSONSerialization JSONObjectWithData:[ErrorResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
                                                          errorMessage = jsonErrorResponse[@"error"][@"msg"];
                                                      } else {
                                                          errorMessage = @"We could not connect to Twitter. Please try again later.";
                                                      }
                                                      FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                      [alert show];
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:facebookConnected]) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"DISCONNECT FACEBOOK?" message:@"You’ll be unable to use your Facebook account for logging in and sharing galleries." actionTitle:@"CANCEL" cancelTitle:@"DISCONNECT" cancelTitleColor:[UIColor frescoRedColor] delegate:self];
        alert.tag = fbAlertTag;
        alert.delegate = self;
        [alert show];
        
        [sender setOn:NO];
        self.facebookCell.connectedSwitch.enabled = NO;
        [[FRSAuthManager sharedInstance] unlinkFacebook:^(id responseObject, NSError *error) {
            
            self.facebookCell.connectedSwitch.enabled = YES;
            if (error) {
                DDLogError(@"Disconnect Facebook Error: %@", error);
                [sender setOn:YES];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];
                [[NSUserDefaults standardUserDefaults] setValue:Nil forKey:@"facebook-name"];
                [sender setOn:YES];
            }
            [self.tableView reloadData];
        }];

    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [sender setOn:YES];
        self.facebookCell.connectedSwitch.enabled = NO;
        [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                     fromViewController:self.inputViewController
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                  if (error) {
                                      [sender setOn:NO];
                                      self.facebookCell.connectedSwitch.enabled = YES;
                                  }

                                  if (result && !error) {
                                      [[FRSAuthManager sharedInstance] linkFacebook:[FBSDKAccessToken currentAccessToken].tokenString
                                                                         completion:^(id responseObject, NSError *error) {
                                                                           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:facebookConnected];
                                                                           [sender setOn:NO animated:YES];
                                                                           self.facebookCell.connectedSwitch.enabled = YES;
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
                                                                               NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                                               NSInteger responseCode = response.statusCode;
                                                                               NSString *errorMessage;
                                                                               if (responseCode == 412) {
                                                                                   [sender setOn:NO animated:YES];
                                                                                   [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:facebookConnected];

                                                                                   NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                                                   NSError *jsonError;

                                                                                   NSDictionary *jsonErrorResponse = [NSJSONSerialization JSONObjectWithData:[errorResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
                                                                                   errorMessage = jsonErrorResponse[@"error"][@"msg"];
                                                                               } else {
                                                                                   errorMessage = @"We could not connect to Facebook. Please try again later.";
                                                                               }
                                                                               
                                                                               FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                                               [alert show];
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

- (void)didPressButton:(FRSAlertView *)alertView atIndex:(NSInteger)index {
    if (alertView.tag == twAlertTag) {
        if (index == 0) {
            [self.twitterCell.connectedSwitch setOn:YES animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:twitterConnected];
        } else {
            [self.twitterCell.connectedSwitch setOn:NO animated:YES];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:twitterHandle];
            self.twitterCell.socialLabel.text = @"Connect Twitter";
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];
        }
    } else if (alertView.tag == fbAlertTag) {
        if (index == 0) {
            [self.facebookCell.connectedSwitch setOn:YES animated:YES];
        } else if (index == 1) {
            [self.facebookCell.connectedSwitch setOn:NO animated:YES];
            self.facebookCell.socialLabel.text = @"Connect Facebook";
        }
    } else {
        //for logout alert
        if (index == 0) {
        } else if (index == 1) {
            [self logoutWithPop:YES];
        }
    }
}

@end
