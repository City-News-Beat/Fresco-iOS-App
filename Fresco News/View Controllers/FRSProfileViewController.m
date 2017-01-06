#import "FRSProfileViewController.h"

//View Controllers
#import "FRSSettingsViewController.h"
#import "FRSFollowersViewController.h"
#import "FRSNavigationController.h"

#import "FRSGalleryCell.h"

#import "FRSBorderedImageView.h"
#import "DGElasticPullToRefresh.h"

#import "Fresco.h"

#import "FRSTrimTool.h"
#import "FRSAppDelegate.h"

#import "FRSUser.h"

#import "FRSAlertView.h"

#import "FRSAppDelegate.h"
#import "FRSAPIClient.h"
#import "FRSStoryCell.h"
#import "FRSSetupProfileViewController.h"

#import "FRSAPIClient.h"
#import "FRSAwkwardView.h"
#import "FRSGalleryExpandedViewController.h"
#import <Haneke/Haneke.h>
#import "FRSStoryDetailViewController.h"
#import "FRSUserNotificationViewController.h"

#import "FRSTabBarController.h"

#import "FRSSearchViewController.h"
#import "UITextView+Resize.h"

@interface FRSProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITabBarDelegate, FRSAlertViewDelegate>

//@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIView *profileContainer;

@property (strong, nonatomic) UIView *profileBG;

//@property (strong, nonatomic) UIImageView *profileIV;

@property (strong, nonatomic) UIView *sectionView;
@property (strong, nonatomic) UIButton *feedButton;
@property (strong, nonatomic) UIButton *likesButton;

@property (strong, nonatomic) NSArray *galleries;
@property (strong, nonatomic) NSArray *likes;

@property (strong, nonatomic) UIView *whiteOverlay;
@property (strong, nonatomic) UIView *socialButtonContainer;
@property (strong, nonatomic) UIView *profileMaskView;

@property (strong, nonatomic) UILabel *usernameLabel;

@property (nonatomic) BOOL overlayPresented;

@property (nonatomic) NSInteger count;

@property (nonatomic) BOOL presentingUser;
@property (nonatomic) BOOL feedAwkward;
@property (nonatomic) BOOL likesAwkward;

@property (strong, nonatomic) FRSAwkwardView *feedAwkwardView;
@property (strong, nonatomic) FRSAwkwardView *likesAwkwardView;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) UIBarButtonItem *followBarButtonItem;
@property (strong, nonatomic) UIButton *followersButton;
@property (strong, nonatomic) NSURL *profileImageURL;
@property BOOL didFollow;

@property (strong, nonatomic) UIImageView *placeholderUserIcon;

@property (strong, nonatomic) FRSAlertView *reportUserAlertView;

@property BOOL didDisplayReport;
@property BOOL didDisplayBlock;

@property (strong, nonatomic) UIView *blockedContainer;
@property (strong, nonatomic) UIView *suspendedContainer;
@property (strong, nonatomic) UIView *disabledContainer;

@property (strong, nonatomic) NSString *reportUserReasonString;
@property (strong, nonatomic) FBSDKLoginManager *fbLoginManager;
@end

@implementation FRSProfileViewController

@synthesize representedUser = _representedUser, authenticatedProfile = _authenticatedProfile;

- (void)loadAuthenticatedUser {
    _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
    self.authenticatedProfile = TRUE;
    [self configureWithUser:_representedUser];
    [self fetchGalleries];
}

- (instancetype)init {
    self = [super init];

    if (self) {
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    //
    //    [[appDelegate.tabBarController tabBar] setHidden:NO];
    //
    //    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height - [appDelegate.tabBarController tabBar].frame.size.height;
    //    self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, [appDelegate.tabBarController tabBar].frame.size.width, [appDelegate.tabBarController tabBar].frame.size.height);

    self.editedProfile = false;

    [self.navigationController.tabBarController.tabBar setHidden:FALSE];

    [self showTabBarAnimated:NO];

    if (isLoadingUser) {
        return;
    }

    if (FALSE) {
        _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
        self.authenticatedProfile = TRUE;
        [self configureWithUser:_representedUser];
    } else {
        [[FRSAPIClient sharedClient] getUserWithUID:_representedUser.uid
                                         completion:^(id responseObject, NSError *error) {
                                           if (error || !responseObject) {
                                               return;
                                           }

                                           _representedUser = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSAPIClient sharedClient] managedObjectContext]];
                                           [self configureWithUser:_representedUser];

                                         }];
    }

    [self setupUI];
    [self configureUI];
    // [self fetchGalleries];
    [super removeNavigationBarLine];

    if (self.shouldShowNotificationsOnLoad) {
        [self showNotificationsNotAnimated];
    }

    self.fbLoginManager = [[FBSDKLoginManager alloc] init];
}

- (void)didPressButtonAtIndex:(NSInteger)index {

    if (self.didDisplayReport) {
        self.didDisplayReport = NO;
        self.reportUserAlertView = nil;
        if (index == 1) {
            [self blockuserAction];
        }

    } else if (self.didDisplayBlock) {
        self.didDisplayBlock = NO;
        if (index == 0) {
            [self unblockUserAction];
        }
    }
}

- (void)reportUserAlertAction {

    [self reportUser:_representedUser.uid];
}

- (void)presentSheet {

    UIAlertController *view = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *follow = [UIAlertAction actionWithTitle:@"Follow"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                     [self followUser];
                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    UIAlertAction *unfollow = [UIAlertAction actionWithTitle:@"Unfollow"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                       [self unfollowUser];
                                                       [view dismissViewControllerAnimated:YES completion:nil];
                                                     }];

    UIAlertAction *block = [UIAlertAction actionWithTitle:@"Block"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                    [self blockuserAction];
                                                    [view dismissViewControllerAnimated:YES completion:nil];
                                                  }];

    UIAlertAction *sunblock = [UIAlertAction actionWithTitle:@"Unblock"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                       [self unblockUserAction];
                                                       [view dismissViewControllerAnimated:YES completion:nil];
                                                     }];

    UIAlertAction *report = [UIAlertAction actionWithTitle:@"Report"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {

                                                     if (([_representedUser.username class] != [NSNull null]) && (![_representedUser.username isEqualToString:@""])) {
                                                         self.reportUserAlertView = [[FRSAlertView alloc] initUserReportWithUsername:[NSString stringWithFormat:@"@%@", _representedUser.username] delegate:self];
                                                     } else if (([_representedUser.firstName class] != [NSNull null]) && (![_representedUser.firstName isEqualToString:@""])) {
                                                         self.reportUserAlertView = [[FRSAlertView alloc] initUserReportWithUsername:[NSString stringWithFormat:@"%@", _representedUser.firstName] delegate:self];
                                                     } else {
                                                         self.reportUserAlertView = [[FRSAlertView alloc] initUserReportWithUsername:@"" delegate:self];
                                                     }

                                                     self.didDisplayReport = YES;
                                                     self.reportUserAlertView.delegate = self;
                                                     [self.reportUserAlertView show];

                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {

                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    if (self.userIsBlocking) {
        [view addAction:report];
        [view addAction:sunblock];
        [view addAction:cancel];
    } else {

        if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
            [view addAction:unfollow];
        } else {
            [view addAction:follow];
        }

        [view addAction:report];
        [view addAction:block];
        [view addAction:cancel];
    }

    [self presentViewController:view animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isLoadingUser) {
        return;
    }

    [self showTabBarAnimated:YES];
    //    self.tableView.bounces = false;
    self.didFollow = NO;
    if (_representedUser.profileImage) {
        self.placeholderUserIcon.alpha = 0;
    }
}

//-(void)showTabBarAnimated:(BOOL)animated{
//
//    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
//
//    if (![appDelegate.tabBarController tabBar]) return;
//
//    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height - [appDelegate.tabBarController tabBar].frame.size.height;
//
//    if ([appDelegate.tabBarController tabBar].frame.origin.y == yOrigin) return;
//
//    self.hiddenTabBar = NO;
//
//    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        [appDelegate.tabBarController tabBar].frame = CGRectMake(0, yOrigin, [appDelegate.tabBarController tabBar].frame.size.width, [appDelegate.tabBarController tabBar].frame.size.height);
//    } completion:nil];
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dateOpened = [NSDate date];
    [FRSTracker screen:@"Profile"];

    [self.tabBarController.navigationController setNavigationBarHidden:YES];
    [self.navigationController.tabBarController.tabBar setHidden:FALSE];
    // Default tab bar in profile to visible
    //    [self.tabBarController.tabBar setHidden:NO];
    //

    //    [self showTabBarAnimated:YES];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (isLoadingUser) {
        return;
    }

    [self addStatusBarNotification];
    [self showNavBarForScrollView:self.tableView animated:NO];

    FRSTabBarController *tabBarController = (FRSTabBarController *)self.tabBarController;

    [[FRSAPIClient sharedClient] getNotificationsWithCompletion:^(id responseObject, NSError *error) {

      if ([[responseObject objectForKey:@"unseen_count"] integerValue] <= 0) {
          [tabBarController updateUserIcon];
      } else {
          [tabBarController updateBellIcon:NO];
      }
    }];

    //
    //    if(!self.editedProfile){
    //        if (!_representedUser) {
    //            _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
    //            self.authenticatedProfile = TRUE;
    //            [self configureWithUser:_representedUser];
    //        }else{
    //            [[FRSAPIClient sharedClient] getUserWithUID:_representedUser.uid completion:^(id responseObject, NSError *error) {
    //                _representedUser = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSAPIClient sharedClient] managedObjectContext]];
    //                [self configureWithUser:_representedUser];
    //
    //                NSInteger origin = self.profileBG.frame.origin.x + self.profileBG.frame.size.width + 16;
    //                self.bioLabel.frame = CGRectMake(origin-4, 65, 150, self.profileContainer.frame.size.width - (origin-4) - 16);
    //                [self.bioLabel sizeToFit];
    //            }];
    //        }
    //    }else{
    //        self.editedProfile = false;
    //    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeStatusBarNotification];
    [self trackSession];

    if (!self.didFollow) {
        [self shouldRefresh:NO]; //Reset the bool. Used when the current user is browsing profiles in search, and when following/unfollowing in followersVC
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSPlayerPlay" object:self];
    [self expandNavBar:nil animated:NO];
}

- (void)trackSession {
    NSString *userID = @"";

    if (self.representedUser.uid && [[self.representedUser.uid class] isSubclassOfClass:[NSString class]]) {
        userID = self.representedUser.uid;
    }

    galleriesScrolledPast = currentProfileCount + currentLikesCount;

    NSInteger secondsInProfile = -1 * [dateOpened timeIntervalSinceNow];

    [FRSTracker track:profileSession
           parameters:@{ @"activity_duration" : @(secondsInProfile),
                         @"user_id" : userID,
                         @"galleries_scrolled_past" : @(galleriesScrolledPast) }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //This logic should be happen once the notif view is dismissed.
    //We should see the tab bar in the notification view with the notification icon.
    //    UITabBarItem *item4 = [self.tabBarController.tabBar.items objectAtIndex:4];
    //    item4.image = [[UIImage imageNamed:@"tab-bar-profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    item4.selectedImage = [[UIImage imageNamed:@"tab-bar-profile-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    FRSTabBarController *frsTabBar = (FRSTabBarController *)self.tabBarController;
    //    frsTabBar.dot.alpha = 0;
}

- (instancetype)initWithUser:(FRSUser *)user {

    if (self) {

        _representedUser = user; // obviously save for future
        _authenticatedProfile = [_representedUser.isLoggedIn boolValue]; // signifies profile view is current authed user

        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [self fetchGalleries];
    }
    return self;
}

- (instancetype)initWithUserID:(NSString *)userName {
    self = [super init];

    if (self) {
        isLoadingUser = TRUE;
        userId = userName;
        [self setupUI];
        [self configureUI];

        [[FRSAPIClient sharedClient] getUserWithUID:userName
                                         completion:^(id responseObject, NSError *error) {
                                           [self addStatusBarNotification];
                                           [self showNavBarForScrollView:self.tableView animated:NO];
                                           FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

                                           FRSUser *user = [FRSUser nonSavedUserWithProperties:responseObject context:[delegate managedObjectContext]];
                                           _representedUser = user;

                                           [self configureWithUser:user];
                                           [self fetchGalleries];
                                           [super removeNavigationBarLine];

                                           if (self.shouldShowNotificationsOnLoad) {
                                               [self showNotificationsNotAnimated];
                                           }

                                           [self showTabBarAnimated:YES];
                                           self.tableView.bounces = false;
                                         }];
    }

    return self;
}
- (void)setupUI {

    self.presentingUser = YES;
    [self configureBackButtonAnimated:YES];

    [super removeNavigationBarLine];

    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.usernameLabel.text = @"";
    self.usernameLabel.textColor = [UIColor whiteColor];
    [self.usernameLabel setFont:[UIFont notaBoldWithSize:17]];
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = self.usernameLabel;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);

    /* TABLE VIEW */
    [self configureTableView];
    //[self fetchGalleries];
    [self configureSpinner];

    [super removeNavigationBarLine];
    [self configureSectionView];
}

- (void)configureBlockedUserWithButton:(BOOL)button {

    if (self.blockedContainer) {
        return;
    }
    self.tableView.scrollEnabled = NO;

    self.userIsBlocking = YES;

    self.blockedContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 207 / 2, (self.view.frame.size.height - self.profileContainer.frame.size.height) / 2 + 181 / 2, 207, 181)];
    [self.view addSubview:self.blockedContainer];

    UIImageView *blocked = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blocked"]];
    blocked.frame = CGRectMake(self.blockedContainer.frame.size.width / 2 - 56 / 2, 0, 56, 56);
    [self.blockedContainer addSubview:blocked];

    UILabel *awkwardLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.blockedContainer.frame.size.width / 2 - 129 / 2, 72, 129, 33)];
    awkwardLabel.text = @"Blocked 🙅";
    awkwardLabel.font = [UIFont karminaBoldWithSize:28];
    awkwardLabel.textColor = [UIColor frescoDarkTextColor];
    [self.blockedContainer addSubview:awkwardLabel];

    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.blockedContainer.frame.size.width / 2 - 208 / 2, 106, 208, 40)];
    bodyLabel.text = @"You can’t see each other’s\ngalleries or comments.";
    bodyLabel.textAlignment = NSTextAlignmentCenter;
    bodyLabel.numberOfLines = 2;
    bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    bodyLabel.textColor = [UIColor frescoMediumTextColor];
    [self.blockedContainer addSubview:bodyLabel];

    self.navigationItem.rightBarButtonItems = nil;

    if (button) {
        UIButton *unblockButton = [UIButton buttonWithType:UIButtonTypeSystem];
        unblockButton.frame = CGRectMake(self.blockedContainer.frame.size.width / 2 - 94 / 2, blocked.frame.size.height + awkwardLabel.frame.size.height + bodyLabel.frame.size.height + 15, 94, 44);
        [unblockButton setTitle:@"UNBLOCK" forState:UIControlStateNormal];
        [unblockButton addTarget:self action:@selector(unblockUserAction) forControlEvents:UIControlEventTouchUpInside];
        [unblockButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        unblockButton.tintColor = [UIColor frescoBlueColor];
        [self.blockedContainer addSubview:unblockButton];
    }
}

- (void)configureSuspendedUser {

    if (self.suspendedContainer) {
        return;
    }

    self.tableView.scrollEnabled = NO;
    self.tableView.alpha = 0;

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 220 - 64)];
    container.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:container];

    self.profileBG = [[UIView alloc] initWithFrame:CGRectMake(container.frame.size.width / 2 - 96 / 2, 12, 96, 96)];
    [self.profileContainer addSubview:self.profileBG];
    [self.profileBG addShadowWithColor:[UIColor frescoShadowColor] radius:3 offset:CGSizeMake(0, 2)];

    self.profileIV = [[FRSBorderedImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileBG.frame.size.width, self.profileBG.frame.size.height) borderColor:[UIColor whiteColor] borderWidth:4];
    self.profileIV.image = [UIImage imageNamed:@""];
    self.profileIV.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
    self.profileIV.layer.cornerRadius = self.profileIV.frame.size.width / 2;
    self.profileIV.clipsToBounds = YES;
    [self.profileBG addSubview:self.profileIV];

    if (_representedUser.profileImage != [NSNull null]) {
        self.profileImageURL = [NSURL URLWithString:_representedUser.profileImage];
        [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:_representedUser.profileImage]];

        if (!_representedUser.profileImage) {
            self.placeholderUserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileIV.frame.size.width / 2 - 40 / 2, self.profileIV.frame.size.height / 2 - 40 / 2, 40, 40)];
            self.placeholderUserIcon.image = [UIImage imageNamed:@"user-40"];
            [self.profileIV addSubview:self.placeholderUserIcon];
        }
    }

    self.placeholderUserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileIV.frame.size.width / 2 - 40 / 2, self.profileIV.frame.size.height / 2 - 40 / 2, 40, 40)];
    self.placeholderUserIcon.image = [UIImage imageNamed:@"user-40"];
    self.placeholderUserIcon.alpha = 0;
    [self.profileIV addSubview:self.placeholderUserIcon];

    [container addSubview:self.profileBG];

    float paddingFromProfileIV = 12.0;
    float center = self.view.frame.size.width / 2;
    float titleInset = 5.0;
    float characterLength = 4.25;

    self.followersButton = [[UIButton alloc] init];
    [self.followersButton setImage:[UIImage imageNamed:@"followers-icon"] forState:UIControlStateNormal];
    [self.followersButton setTitle:@"0" forState:UIControlStateNormal];
    [self.followersButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    self.followersButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, titleInset, 0.0f, 0.0f);
    [self.followersButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.profileContainer addSubview:self.followersButton];
    //Make the center of the button to be the same center as the profile bg with title length versatility
    float titleLength = self.followersButton.currentTitle.length * characterLength;
    [self.followersButton setFrame:CGRectMake(center - titleInset - titleLength * 2, (self.profileBG.frame.size.height) + paddingFromProfileIV, 100, 50)];

    [self.followersButton addTarget:self action:@selector(showFollowers) forControlEvents:UIControlEventTouchUpInside];

    [container addSubview:self.followersButton];

    self.suspendedContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 207 / 2, (self.view.frame.size.height - self.profileContainer.frame.size.height) / 2 + 125 / 2, 207, 125)];
    [self.view addSubview:self.suspendedContainer];

    UIImageView *frog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suspended"]];
    frog.frame = CGRectMake(self.suspendedContainer.frame.size.width / 2 - 56 / 2, 0, 56, 56);
    [self.suspendedContainer addSubview:frog];

    UILabel *awkwardLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.suspendedContainer.frame.size.width / 2 - 165 / 2, 72, 165, 33)];
    awkwardLabel.text = @"Suspended 🙅";
    awkwardLabel.font = [UIFont karminaBoldWithSize:28];
    awkwardLabel.textColor = [UIColor frescoDarkTextColor];
    [self.suspendedContainer addSubview:awkwardLabel];

    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.suspendedContainer.frame.size.width / 2 - 288 / 2, 106, 288, 20)];
    bodyLabel.text = @"This user is in time-out for a while.";
    bodyLabel.textAlignment = NSTextAlignmentCenter;
    bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    bodyLabel.textColor = [UIColor frescoMediumTextColor];
    [self.suspendedContainer addSubview:bodyLabel];

    self.navigationItem.rightBarButtonItems = nil;
    self.sectionView.alpha = 0;
}

- (void)configureDisabledUser {

    if (self.disabledContainer) {
        return;
    }

    self.tableView.scrollEnabled = NO;

    self.profileContainer.alpha = 0;
    self.sectionView.alpha = 0;
    self.tableView.alpha = 0;
    self.navigationItem.rightBarButtonItems = nil;

    self.disabledContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 207 / 2, self.view.frame.size.height / 2 - 125 / 2 - 64, 207, 125)];
    [self.view addSubview:self.disabledContainer];

    UIImageView *frog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frog"]];
    frog.frame = CGRectMake(self.disabledContainer.frame.size.width / 2 - 72 / 2, 0, 72, 72);
    [self.disabledContainer addSubview:frog];

    UILabel *awkwardLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.disabledContainer.frame.size.width / 2 - 121 / 2, 72, 121, 33)];
    awkwardLabel.text = @"Awkward.";
    awkwardLabel.font = [UIFont karminaBoldWithSize:28];
    awkwardLabel.textColor = [UIColor frescoDarkTextColor];
    [self.disabledContainer addSubview:awkwardLabel];

    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.disabledContainer.frame.size.width / 2 - 207 / 2, 106, 207, 20)];
    bodyLabel.text = @"This user’s profile is disabled.";
    bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    bodyLabel.textColor = [UIColor frescoMediumTextColor];
    [self.disabledContainer addSubview:bodyLabel];
}

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width / 2 - 10, (self.view.frame.size.height - self.profileContainer.frame.size.height) / 2 + 20 / 2, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
}

#pragma mark - Fetch Methods

- (void)fetchGalleries {
    BOOL reload = FALSE;

    if (self.currentFeed == self.galleries) {
        reload = TRUE;
    }

    [[FRSAPIClient sharedClient] fetchGalleriesForUser:self.representedUser
                                            completion:^(id responseObject, NSError *error) {

                                              [self.loadingView stopLoading];
                                              [self.loadingView removeFromSuperview];

                                              if (self.userIsBlocked) {
                                                  [self configureBlockedUserWithButton:NO];
                                                  self.likesButton.userInteractionEnabled = NO;
                                                  return;
                                              }

                                              if (self.userIsBlocking || _representedUser.blocking) {
                                                  [self configureBlockedUserWithButton:YES];
                                                  return;
                                              } else if ((self.userIsSuspended || _representedUser.suspended) && ![_representedUser.uid isEqual:[[FRSAPIClient sharedClient] authenticatedUser].uid]) {
                                                  [self configureSuspendedUser];
                                                  return;
                                              } else if (self.userIsDisabled || _representedUser.disabled) {
                                                  [self configureDisabledUser];
                                                  return;
                                              }

                                              self.galleries = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE];

                                              [self.tableView reloadData];

                                              if (reload) {
                                                  self.currentFeed = self.galleries;
                                                  [self.tableView reloadData];

                                                  if (self.galleries.count <= 0) {
                                                      [self configureFrogForFeed:self.tableView];
                                                      self.feedAwkwardView.alpha = 1;
                                                  } else {
                                                      self.feedAwkwardView.alpha = 0;
                                                  }
                                              }
                                            }];

    [self fetchLikes];
}

- (void)fetchLikes {

    BOOL reload = FALSE;

    if (self.currentFeed == self.likes && self.likes != Nil) {
        reload = TRUE;
    }

    [[FRSAPIClient sharedClient] fetchLikesFeedForUser:self.representedUser
                                            completion:^(id responseObject, NSError *error) {
                                              self.likes = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE];

                                              if (reload) {
                                                  self.currentFeed = self.likes;
                                                  [self.tableView reloadData];

                                                  if (self.likes.count <= 0) {
                                                      [self configureFrogForFeed:self.tableView];
                                                      self.feedAwkwardView.alpha = 1;
                                                  } else {
                                                      self.feedAwkwardView.alpha = 0;
                                                  }
                                              }
                                            }];
}

#pragma mark - UI Elements
- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    [self configureNavigationBar];
    //    [self configureTableView];
    [self configurePullToRefresh];
    [self configureProfileSocialOverlay];
}

- (void)configureFrogForFeed:(UITableView *)feed {

    if (self.feedAwkwardView) {
        if (self.feedAwkwardView.superview != feed) {
            [feed addSubview:self.feedAwkwardView];
        }
        return;
    }

    NSInteger profileContainerTabBarHeight = 44;

    self.feedAwkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(0, ((self.profileContainer.frame.size.height + profileContainerTabBarHeight) + (self.view.frame.size.height)) / 2, self.view.frame.size.width, self.view.frame.size.height)];

    [feed addSubview:self.feedAwkwardView];
}

- (void)configurePullToRefresh {

    [super removeNavigationBarLine];

    DGElasticPullToRefreshLoadingViewCircle *loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;

    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0
                                         minOffsetToPull:80
                                     loadingContentInset:44
                                         loadingViewSize:20
                                                velocity:0
                                           actionHandler:^{

                                             [weakSelf fetchGalleries];
                                             [weakSelf.tableView dg_stopLoading];

                                           }
                                             loadingView:loadingView
                                                    yPos:-64];

    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:[UIColor frescoOrangeColor]];
}

- (void)dealloc {
    [self.tableView dg_removePullToRefresh];
}

- (void)configureNavigationBar {
    //  [super configureNavigationBar];
    [super removeNavigationBarLine];

    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"";
    titleLabel.font = [UIFont fontWithName:@"Nota-Bold" size:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    // titleLabel.text = [NSString stringWithFormat:@"@%@", self.representedUser.username];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    
    if (self.representedUser.isLoggedIn && [self.navigationController.childViewControllers objectAtIndex:0] == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bell-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showNotificationsAnimated)];
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pen-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showEditProfile)];
        UIBarButtonItem *gearItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
        editItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30);

        gearItem.tintColor = [UIColor whiteColor];
        editItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

        self.navigationItem.rightBarButtonItems = @[ gearItem, editItem ];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //?

    } else {

        if (![self.representedUser.uid isEqualToString:[[FRSAPIClient sharedClient] authenticatedUser].uid]) {

            self.followBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(followUser)];
            self.followBarButtonItem.tintColor = [UIColor whiteColor];

            dispatch_async(dispatch_get_main_queue(), ^{

              if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
                  [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];
              } else {
                  [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
              }

              if (!self.userIsDisabled || !self.userIsSuspended) {

                  if ([[FRSAPIClient sharedClient] isAuthenticated]) {
                      UIBarButtonItem *dotIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dots"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSheet)];
                      dotIcon.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30);

                      dotIcon.tintColor = [UIColor whiteColor];
                      self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

                      self.navigationItem.rightBarButtonItems = @[ self.followBarButtonItem, dotIcon ];
                  } else {
                      self.navigationItem.rightBarButtonItems = @[ self.followBarButtonItem ];
                  }
              }

              if (self.userIsBlocking) {
                  [self.followBarButtonItem setImage:[UIImage imageNamed:@"dots"]];
                  [self.followBarButtonItem setAction:@selector(presentSheet)];
                  [self.followBarButtonItem setTarget:self];
              }
            });
        }
        [self configureBackButtonAnimated:true];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

- (void)configureTableView {

    [self createProfileSection];

    self.automaticallyAdjustsScrollViewInsets = NO;
    if (isLoadingUser) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height - 44)];
    }

    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:self.tableView];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        [(FRSGalleryCell *)cell pause];
    }
}

- (void)createProfileSection {
    self.profileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 0)];
    self.profileContainer.backgroundColor = [UIColor frescoOrangeColor];
    self.profileContainer.clipsToBounds = YES;

    [self configureProfileImage];
    [self configureLabels];
    [self resizeProfileContainer];
}

- (void)configureProfileImage {
    self.profileBG = [[UIView alloc] initWithFrame:CGRectMake(16, 12, 96, 96)];
    [self.profileContainer addSubview:self.profileBG];
    [self.profileBG addShadowWithColor:[UIColor frescoShadowColor] radius:3 offset:CGSizeMake(0, 2)];

    self.profileIV = [[FRSBorderedImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileBG.frame.size.width, self.profileBG.frame.size.height) borderColor:[UIColor whiteColor] borderWidth:4];
    self.profileIV.image = [UIImage imageNamed:@""];
    self.profileIV.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
    self.profileIV.layer.cornerRadius = self.profileIV.frame.size.width / 2;
    self.profileIV.clipsToBounds = YES;
    [self.profileBG addSubview:self.profileIV];

    self.placeholderUserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileIV.frame.size.width / 2 - 40 / 2, self.profileIV.frame.size.height / 2 - 40 / 2, 40, 40)];
    self.placeholderUserIcon.image = [UIImage imageNamed:@"user-40"];
    self.placeholderUserIcon.alpha = 0;
    [self.profileIV addSubview:self.placeholderUserIcon];

    float paddingFromProfileIV = 20.0;
    float center = 50.0;
    float titleInset = 5.0;
    float characterLength = 4.25;

    self.followersButton = [[UIButton alloc] init];
    [self.followersButton setImage:[UIImage imageNamed:@"followers-icon"] forState:UIControlStateNormal];
    [self.followersButton setTitle:@"0" forState:UIControlStateNormal];
    [self.followersButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    self.followersButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, titleInset, 0.0f, 0.0f);
    [self.followersButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.profileContainer addSubview:self.followersButton];
    //Make the center of the button to be the same center as the profile bg with title length versatility
    float titleLength = self.followersButton.currentTitle.length * characterLength;
    [self.followersButton setFrame:CGRectMake(center - titleInset - titleLength, (self.profileBG.frame.size.height) + paddingFromProfileIV, 100, 50)];

    [self.followersButton addTarget:self action:@selector(showFollowers) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureProfileSocialOverlay {

    self.whiteOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
    self.whiteOverlay.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [self.profileIV addSubview:self.whiteOverlay];

    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.socialButtonContainer.bounds;
    [self.profileIV addSubview:visualEffectView];

    UIButton *socialOverlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [socialOverlayButton addTarget:self action:@selector(presentSocialOverlay) forControlEvents:UIControlEventTouchUpInside];
    socialOverlayButton.frame = CGRectMake(16, 12, 96, 96);
    socialOverlayButton.layer.cornerRadius = 48;
    [self.profileContainer addSubview:socialOverlayButton];

    self.socialButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(16, 36, 64.5, 24)];
    self.socialButtonContainer.alpha = 1;

    [self.whiteOverlay addSubview:self.socialButtonContainer];
    //    [self.whiteOverlay insertSubview:self.socialButtonContainer aboveSubview:self.view];

    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [twitterButton addTarget:self action:@selector(twitterTapped) forControlEvents:UIControlEventTouchDown];
    UIImage *twitter = [[UIImage imageNamed:@"social-twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [twitterButton setImage:twitter forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(0, 0, 24, 24);
    twitterButton.alpha = 1;
    [self.socialButtonContainer addSubview:twitterButton];

    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [facebookButton addTarget:self action:@selector(facebookTapped) forControlEvents:UIControlEventTouchDown];
    UIImage *facebook = [[UIImage imageNamed:@"social-facebook"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [facebookButton setImage:facebook forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(40, 0, 24, 24);
    facebookButton.alpha = 1;
    [self.socialButtonContainer addSubview:facebookButton];

    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gr];

    self.profileMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
    self.profileMaskView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    self.profileMaskView.layer.cornerRadius = 48;
    [self.view addSubview:self.profileMaskView];
    self.whiteOverlay.layer.mask = self.profileMaskView.layer;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (!CGRectContainsPoint(self.profileIV.frame, point)) {
        [self dismissSocialOverlay];
    }
}

- (void)presentSocialOverlay {

    if (!self.overlayPresented) {

        //Set overlay presented state to prevent animating if double tapped
        self.overlayPresented = YES;

        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{

                           self.profileMaskView.transform = CGAffineTransformMakeScale(1, 1);

                         }
                         completion:nil];

        //Set default transform
        //        self.socialButtonContainer.transform = CGAffineTransformMakeScale(0.0001, 0.0001);

        //        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        //            self.socialButtonContainer.transform = CGAffineTransformMakeScale(1.05, 1.05);
        //            self.socialButtonContainer.alpha = 1;
        //            self.whiteOverlay.alpha = 1;
        //
        //        } completion:^(BOOL finished) {
        //            [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        //                self.socialButtonContainer.transform = CGAffineTransformMakeScale(1, 1);
        //
        //            } completion:nil];
        //        }];
    }
}

- (void)dismissSocialOverlay {

    //Set overlay presented state to prevent animating if double tapped
    self.overlayPresented = NO;

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.profileMaskView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);

                     }
                     completion:nil];

    //    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
    //
    //        self.socialButtonContainer.alpha = 0;
    //        self.socialButtonContainer.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    //        self.whiteOverlay.alpha = 0;
    //
    //    } completion:nil];
}

- (void)configureLabels {
    NSInteger origin = self.profileBG.frame.origin.x + self.profileBG.frame.size.width + 16;

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.profileBG.frame.origin.y, self.view.frame.size.width - origin - 16, 22)];
    //self.nameLabel.text = @"";
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont notaMediumWithSize:17];
    [self.profileContainer addSubview:self.nameLabel];

    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, self.nameLabel.frame.size.width, 14)];
    self.locationLabel.textColor = [UIColor whiteColor];
    self.locationLabel.font = [UIFont systemFontOfSize:12 weight:-1];
    [self.profileContainer addSubview:self.locationLabel];

    //    self.bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, self.locationLabel.frame.origin.y + self.locationLabel.frame.size.height + 6, self.nameLabel.frame.size.width, 0)];

    CGFloat width = 0;
    if (IS_IPHONE_5) {
        width = 176;
    } else if (IS_IPHONE_6) {
        width = 231;
    } else { //6+
        width = 270;
    }

    self.bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(origin - 4, 65, width, 1)];
    [self.profileContainer addSubview:self.bioTextView];
    [self.bioTextView setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
    self.bioTextView.backgroundColor = [UIColor clearColor];
    self.bioTextView.userInteractionEnabled = NO;
    self.bioTextView.textColor = [UIColor whiteColor];

    //    self.bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, 65, width, self.profileContainer.frame.size.width - (origin-4) - 16)];
    //
    //    self.bioLabel.text = @""; //temp fix, need to make frame larger because of sizeToFit, disabling sizeToFit causes other issues.
    //    self.bioLabel.backgroundColor = [UIColor redColor];
    //    self.bioLabel.textColor = [UIColor whiteColor];
    //    self.bioLabel.font = [UIFont systemFontOfSize:15 weight:-300];
    //    //    [self.bioLabel sizeToFit];
    //    [self.profileContainer addSubview:self.bioLabel];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text) {
        /*[[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"bio":textView.text} completion:^(id responseObject, NSError *error) {
         NSLog(@"%@ %@", responseObject, error);
         }];*/
        [textView resignFirstResponder];
    }
}

- (void)resizeProfileContainer {

    CGFloat height = MAX(self.bioTextView.frame.origin.y + self.bioTextView.frame.size.height + 6, 160);

    CGFloat maxHeight = 0;
    if (IS_IPHONE_5) {
        maxHeight = 304;
    } else if ((IS_IPHONE_6) || (IS_IPHONE_6_PLUS)) {
        maxHeight = 270;
    }

    if (height >= maxHeight) {
        [self.profileContainer setSizeWithSize:CGSizeMake(self.profileContainer.frame.size.width, maxHeight)];
    } else {
        [self.profileContainer setSizeWithSize:CGSizeMake(self.profileContainer.frame.size.width, height)];
    }

    [self.sectionView setFrame:CGRectMake(0, self.profileContainer.frame.size.height, self.view.frame.size.width, 44)];
}

- (void)configureSectionView {

    self.sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.profileContainer.frame.size.height, self.view.frame.size.width, 44)];
    self.sectionView.backgroundColor = [UIColor frescoOrangeColor];

    self.feedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.sectionView.frame.size.width / 2, self.sectionView.frame.size.height)];
    [self.feedButton setTitle:@"FEED" forState:UIControlStateNormal];
    [self.feedButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.feedButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.feedButton addTarget:self action:@selector(handleFeedbackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.sectionView addSubview:self.feedButton];

    self.likesButton = [[UIButton alloc] initWithFrame:CGRectOffset(self.feedButton.frame, self.feedButton.frame.size.width, 0)];
    [self.likesButton setTitle:@"LIKES" forState:UIControlStateNormal];
    [self.likesButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    self.likesButton.alpha = 0.7;
    [self.likesButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.likesButton addTarget:self action:@selector(handleLikesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.sectionView addSubview:self.likesButton];
    [self.view addSubview:self.sectionView];
}

- (void)handleFeedbackButtonTapped {
    if (self.feedButton.alpha > 0.7)
        return; //The button is already selected

    self.feedButton.alpha = 1.0;
    self.likesButton.alpha = 0.7;

    if (self.galleries.count == 0 || (!self.galleries)) {
        [self configureFrogForFeed:self.tableView];
        self.feedAwkwardView.alpha = 1;
    } else {
        self.feedAwkwardView.alpha = 0;
    }

    if (self.currentFeed != self.galleries) {
        self.currentFeed = self.galleries;

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)handleLikesButtonTapped {
    if (self.likesButton.alpha > 0.7)
        return; //The button is already selected

    self.likesButton.alpha = 1.0;
    self.feedButton.alpha = 0.7;

    if (self.likes.count == 0 || (!self.likes)) {
        [self configureFrogForFeed:self.tableView];
        self.feedAwkwardView.alpha = 1;
    } else {
        self.feedAwkwardView.alpha = 0;
    }

    if (self.currentFeed != self.likes) {
        self.currentFeed = self.likes;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
    NSString *url = content[0];
    url = [[url componentsSeparatedByString:@"/"] lastObject];
    [FRSTracker track:galleryShared
           parameters:@{ @"gallery_id" : url,
                         @"shared_from" : @"profile" }];
}

- (void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)notification {

    FRSGallery *gallery = Nil;

    if (self.likesButton.alpha == 1) {
        gallery = self.likes[notification.row];
    } else {
        gallery = self.galleries[notification.row];
    }

    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    vc.shouldHaveBackButton = YES;
    vc.openedFrom = @"Profile";

    [super showNavBarForScrollView:self.tableView animated:NO];

    self.navigationItem.title = @"";

    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];

    [FRSTracker track:galleryOpenedFromProfile
           parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"",
                         @"opened_from" : @"profile" }];
}

- (void)readMoreStory:(NSIndexPath *)indexPath {
    FRSStoryCell *storyCell = [self.tableView cellForRowAtIndexPath:indexPath];
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:storyCell.story];
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;

    //We have two sections for our tableview. The first section holds the profile container and has a header height of 0.
    //The second section holds the feed/likes, and the header has the segmented tab and has a height of 44.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    } else {
        if (!self.currentFeed) {
            self.currentFeed = self.galleries;
        }

        //        //Awkward View
        //        if(tableView == self.tableView){
        //            if(self.currentFeed.count == 0){
        //                [self displayAwkwardView:true feedTable:false];
        //            }else{
        //                [self displayAwkwardView:false feedTable:false];
        //            }
        //        }else if(tableView == self.contentTable){
        //            if(self.currentFeed.count == 0){
        //                [self displayAwkwardView:true feedTable:true];
        //            }else{
        //                [self displayAwkwardView:false feedTable:true];
        //            }
        //        }

        if (self.currentFeed.count == 0) {
            return 1;
        } else {
            return self.currentFeed.count;
        }

        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.profileContainer.frame.size.height + 64;
    } else {
        if (!self.currentFeed.count)
            return 60;
        if ([[self.currentFeed[indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
            FRSGallery *gallery = self.currentFeed[indexPath.row];
            return [gallery heightForGallery];
        } else {
            FRSStory *story = self.currentFeed[indexPath.row];
            return [story heightForStory];
        }
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.currentFeed == self.likes) {
        if (indexPath.row > currentLikesCount) {
            currentLikesCount = indexPath.row;
        }
    } else {
        if (indexPath.row > currentProfileCount) {
            currentProfileCount = indexPath.row;
        }
    }
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profile-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        if (self.currentFeed.count == 0) {
            cell = [[UITableViewCell alloc] init];
            CGRect newFrame = tableView.frame;
            newFrame.size.height = 40;
            newFrame.origin.y = tableView.frame.size.height / 6;
            //            [cell.contentView addSubview:[[FRSAwkwardView alloc] initWithFrame:newFrame]];
            [cell.contentView setBackgroundColor:[UIColor frescoBackgroundColorDark]];
            [cell setBackgroundColor:[UIColor frescoBackgroundColorDark]];
        } else if ([[[self.currentFeed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];

            if (!cell) {
                cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
            }
        } else if ([[[self.currentFeed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSStory class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];

            if (!cell) {
                cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
            }
        }

        if (indexPath.row > self.currentFeed.count - 5) {
            [self loadMoreInCurrentFeed];
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)loadMoreInCurrentFeed {
    if (self.currentFeed == self.likes) {

        if (isReloading || isFinishedLikes) {
            return;
        }

        isReloading = TRUE;
        FRSGallery *gallery = [self.likes lastObject];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        NSString *timeStamp = [dateFormat stringFromDate:gallery.editedDate];

        FRSUser *authUser = self.representedUser;
        NSString *userID = authUser.uid;

        NSString *endpoint = [NSString stringWithFormat:likeFeed, userID];

        endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, timeStamp];

        [[FRSAPIClient sharedClient] get:endpoint
                          withParameters:nil
                              completion:^(id responseObject, NSError *error) {
                                isReloading = FALSE;

                                NSArray *response = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE]];

                                if (response.count == 0) {
                                    isFinishedLikes = TRUE;
                                }

                                NSMutableArray *newGalleries = [self.likes mutableCopy];
                                [newGalleries addObjectsFromArray:response];
                                self.likes = newGalleries;
                                [self.tableView reloadData];
                              }];

    } else if (self.currentFeed == self.galleries) {

        if (isReloading || isFinishedUser) {
            return;
        }

        isReloading = TRUE;
        FRSGallery *gallery = [self.galleries lastObject];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        NSString *timeStamp = [dateFormat stringFromDate:gallery.editedDate];

        FRSUser *authUser = self.representedUser;
        NSString *userID = authUser.uid;

        NSString *endpoint = [NSString stringWithFormat:userFeed, userID];

        endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, timeStamp];

        [[FRSAPIClient sharedClient] get:endpoint
                          withParameters:nil
                              completion:^(id responseObject, NSError *error) {
                                isReloading = FALSE;

                                NSArray *response = [NSArray arrayWithArray:[[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE]];

                                if (response.count == 0) {
                                    isFinishedUser = TRUE;
                                }

                                NSMutableArray *newGalleries = [self.galleries mutableCopy];
                                [newGalleries addObjectsFromArray:response];
                                self.galleries = newGalleries;
                                [self.tableView reloadData];
                              }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [cell addSubview:self.profileContainer];
    } else {
        __weak typeof(self) weakSelf = self;

        if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
            FRSGalleryCell *galCell = (FRSGalleryCell *)cell;
            galCell.galleryView.delegate.navigationController = self.navigationController;
            [galCell clearCell];

            galCell.shareBlock = ^void(NSArray *sharedContent) {
              [weakSelf showShareSheetWithContent:sharedContent];
            };

            galCell.readMoreBlock = ^(NSArray *array) {
              [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
            };

            galCell.gallery = self.currentFeed[indexPath.row];
            [galCell configureCell];
        } else if (self.currentFeed.count == 0) {

        } else {
            FRSStoryCell *storyCell = (FRSStoryCell *)cell;
            storyCell.storyView.navigationController = self.navigationController;
            storyCell.storyView.delegate.navigationController = self.navigationController;
            [storyCell clearCell];

            storyCell.shareBlock = ^void(NSArray *sharedContent) {
              [weakSelf showShareSheetWithContent:sharedContent];
            };

            storyCell.readMoreBlock = ^(NSArray *bullshit) {
              [weakSelf readMoreStory:indexPath];
            };

            storyCell.story = self.currentFeed[indexPath.row];
            [storyCell configureCell];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *view;

    view.backgroundColor = [UIColor clearColor];
    topView.backgroundColor = [UIColor clearColor];

    if (section == 0) {
        view = [UIView new];
    } else if (section == 1) {
        //[self configureSectionView];

        if (topView) {
            return topView;
        }
        //[self configureSectionView];

        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [self.sectionView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];

        topView = view;
        return topView;
    }

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    //Bounce only at the bottom of the tableview
    //    scrollView.bounces = (scrollView.contentOffset.y > 10);

    CGRect newFrame = self.sectionView.frame;

    newFrame.origin.y = (self.navBarYValue / self.navBarHeight) * (self.sectionView.frame.size.height) - self.sectionView.frame.size.height;

    //Prevent it from over extending (going past the bottom of the nav bar)
    if (newFrame.origin.y > 0) {
        newFrame.origin.y = 0;
    }

    //If it goes over the profile height, attach it to the bot of the profile container view
    CGPoint localPoint = newFrame.origin;
    CGPoint basePoint = [self.view convertPoint:localPoint toView:self.tableView];
    if (basePoint.y < self.profileContainer.frame.size.height + (_sectionView.frame.size.height * 1.5)) {
        newFrame.origin.y = self.profileContainer.frame.size.height - scrollView.contentOffset.y;
    }

    [self.sectionView setFrame:newFrame];

    //if (scrollView.contentOffset.y > self.view.frame.size.height) {
    //    scrollView.bounces = NO;
    //} else {
    //    scrollView.bounces = YES;
    //}

    NSArray *visibleCells = [self.tableView visibleCells];

    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];

    NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
    if (timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - lastScrollOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond

        CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
        if (scrollSpeed > maxScrollVelocity) {
            isScrollingFast = YES;
        } else {
            isScrollingFast = NO;
        }

        lastScrollOffset = currentOffset;
        lastOffsetCapture = currentTime;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      BOOL taken = FALSE;

      for (FRSGalleryCell *cell in visibleCells) {
          if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
              if (cell.frame.origin.y - self.tableView.contentOffset.y < 300 && cell.frame.origin.y - self.tableView.contentOffset.y > 0) {
                  if (!taken && !isScrollingFast) {
                      [cell play];
                      taken = TRUE;
                  } else {
                      [cell pause];
                  }
              } else {
                  [cell pause];
              }
          }
      }
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

#pragma mark - Navigation

- (void)showNotificationsAnimated {
    FRSUserNotificationViewController *notifVC = [[FRSUserNotificationViewController alloc] init];
    [self.navigationController pushViewController:notifVC animated:YES];
}

- (void)showNotificationsNotAnimated {
    FRSUserNotificationViewController *notifVC = [[FRSUserNotificationViewController alloc] init];
    [self.navigationController pushViewController:notifVC animated:NO];
}

- (void)showSettings {
    self.navigationController.hidesBottomBarWhenPushed = YES;
    FRSSettingsViewController *settingsVC = [[FRSSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
    self.navigationItem.title = @"";
    [self hideTabBarAnimated:YES];
}

- (void)followUser {

    self.didFollow = YES;
    [self shouldRefresh:YES];

    [[FRSAPIClient sharedClient] followUser:self.representedUser
                                 completion:^(id responseObject, NSError *error) {
                                   if (error) {
                                       return;
                                   }

                                   if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
                                       [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];

                                   } else {
                                       [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
                                       [self unfollowUser];
                                   }
                                 }];
}

- (void)unfollowUser {
    [[FRSAPIClient sharedClient] unfollowUser:self.representedUser
                                   completion:^(id responseObject, NSError *error) {
                                     if (error) {
                                         return;
                                     }

                                     if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
                                         [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];
                                     } else {
                                         [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
                                     }

                                   }];
}

- (void)shouldRefresh:(BOOL)refresh {

    if ([self.navigationController.viewControllers count] < 2) {
        return;
    }

    UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    FRSSearchViewController *searchVC = (FRSSearchViewController *)previousController;
    FRSFollowersViewController *followersVC = (FRSFollowersViewController *)previousController;

    if (refresh) {
        if ([previousController isKindOfClass:[FRSSearchViewController class]]) {
            searchVC.shouldUpdateOnReturn = YES;
        } else if ([previousController isKindOfClass:[FRSFollowersViewController class]]) {
            followersVC.shouldUpdateOnReturn = YES;
        }

    } else {
        if ([previousController isKindOfClass:[FRSSearchViewController class]]) {
            searchVC.shouldUpdateOnReturn = NO;
        } else if ([previousController isKindOfClass:[FRSFollowersViewController class]]) {
            followersVC.shouldUpdateOnReturn = NO;
        }
    }
}

- (void)showEditProfile {
    [self segueToSetup];
}

- (void)segueToSetup {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate reloadUser];

    FRSSetupProfileViewController *setupProfileVC = [[FRSSetupProfileViewController alloc] init];
    setupProfileVC.nameStr = self.nameLabel.text;
    setupProfileVC.locStr = self.locationLabel.text;
    setupProfileVC.bioStr = self.bioTextView.text;
    setupProfileVC.profileImageURL = self.profileImageURL;
    setupProfileVC.isEditingProfile = true;
    [self.navigationController pushViewController:setupProfileVC animated:YES];
}

- (void)showFollowers {
    FRSFollowersViewController *vc = [[FRSFollowersViewController alloc] init];
    vc.representedUser = _representedUser;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Social Overlay Actions

- (void)twitterTapped {
    /*[FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token, NSDictionary *user) {
     
     }];*/
}

- (void)facebookTapped {
    [FRSSocial loginWithFacebook:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token, id responseObject) {

    }
                          parent:self
                         manager:self.fbLoginManager]; // presenting view controller
}

#pragma mark - User

- (void)configureWithUser:(FRSUser *)user {

    dispatch_async(dispatch_get_main_queue(), ^{
      // self.profileIV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.profileImage]]];
      self.nameLabel.text = user.username;
      if (user.profileImage != [NSNull null]) {
          self.profileImageURL = [NSURL URLWithString:user.profileImage];
          [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:user.profileImage]];

          if (self.profileImageURL == nil) {
              self.placeholderUserIcon.alpha = 1;
          }
      } else {
          self.profileIV.image = Nil;
      }

      self.bioTextView.text = user.bio;

      [self.bioTextView frs_setTextWithResize:user.bio];

      self.userIsBlocking = user.blocking;
      self.userIsBlocked = user.blocked;
      self.userIsSuspended = user.suspended;
      self.userIsDisabled = user.disabled;

      if (_authenticatedProfile) {
          [self resizeProfileContainer];
      } else {
          [UIView animateWithDuration:0.15
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseInOut
                           animations:^{
                             [self resizeProfileContainer];
                           }
                           completion:nil];
      }

      if ([[user valueForKey:@"following"] boolValue] == TRUE) {
          [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];
      } else {
          [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
      }

      self.nameLabel.text = user.firstName;
      [self.followersButton setTitle:[NSString stringWithFormat:@"%@", [user valueForKey:@"followedCount"]] forState:UIControlStateNormal];
      self.locationLabel.text = [user valueForKey:@"location"];
      self.usernameLabel.text = user.username;
      titleLabel.text = [NSString stringWithFormat:@"@%@", user.username];

      if ([user.username isEqualToString:@""] || !user.username || [user.username isEqual:[NSNull null]]) {
          if (![user.firstName isEqualToString:@""]) {
              titleLabel.adjustsFontSizeToFitWidth = YES;
              titleLabel.text = user.firstName;
          } else {
              titleLabel.text = @"";
          }
      }

      [self configureNavigationBar];
    });
}

#pragma mark - Moderation

- (void)didPressRadioButtonAtIndex:(NSInteger)index {
    switch (index) {
    case 0:
        self.reportUserReasonString = @"abuse";
        break;
    case 1:
        self.reportUserReasonString = @"spam";
        break;
    case 2:
        self.reportUserReasonString = @"stolen";
        break;
    case 3:
        self.reportUserReasonString = @"graphic";
        break;
    default:
        break;
    }
}

- (void)blockUser:(FRSUser *)user {
    [[FRSAPIClient sharedClient] blockUser:user.uid
                            withCompletion:^(id responseObject, NSError *error) {

                              if (responseObject) {

                                  NSString *username;

                                  if ([_representedUser.username class] != [NSNull null] && (![_representedUser.username isEqualToString:@""])) {
                                      username = [NSString stringWithFormat:@"@%@", _representedUser.username];
                                  } else if ([_representedUser.firstName class] != [NSNull null] && (![_representedUser.firstName isEqualToString:@""])) {
                                      username = _representedUser.firstName;
                                  } else {
                                      username = @"them";
                                  }

                                  FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"BLOCKED" message:[NSString stringWithFormat:@"You won’t see posts from %@ anymore.", username] actionTitle:@"UNDO" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                  self.didDisplayBlock = YES;
                                  [alert show];

                                  //////
                                  [self configureBlockedUserWithButton:YES];
                                  self.blockedContainer.alpha = 1;
                                  self.likes = nil;
                                  self.galleries = nil;
                                  [self.tableView reloadData];
                                  if (!self.profileIV.image) {
                                      self.placeholderUserIcon.alpha = 1;
                                  }
                                  self.userIsBlocking = YES;
                                  self.tableView.scrollEnabled = NO;
                                  UIBarButtonItem *dotIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dots"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSheet)];
                                  dotIcon.tintColor = [UIColor whiteColor];
                                  self.navigationItem.rightBarButtonItems = @[ dotIcon ];
                                  /////

                              } else {
                                  [self presentGenericError];
                              }

                            }];
}

- (void)unblockUser:(FRSUser *)user {

    [self configureSpinner];

    [[FRSAPIClient sharedClient] unblockUser:user.uid
                              withCompletion:^(id responseObject, NSError *error) {
                                if (responseObject) {

                                    /////
                                    self.userIsBlocking = NO;
                                    self.tableView.scrollEnabled = YES;
                                    [self configureWithUser:_representedUser];
                                    [self fetchGalleries];
                                    self.tableView.alpha = 1;
                                    if (self.profileImageURL) {
                                        self.placeholderUserIcon.alpha = 0;
                                    }
                                    self.blockedContainer.alpha = 0;
                                    UIBarButtonItem *dotIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dots"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSheet)];
                                    dotIcon.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30);
                                    dotIcon.tintColor = [UIColor whiteColor];
                                    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
                                    self.navigationItem.rightBarButtonItems = @[ self.followBarButtonItem, dotIcon ];
                                    ////

                                } else {
                                    [self presentGenericError];
                                }
                              }];
}

- (void)blockuserAction {
    [self blockUser:_representedUser];
}

- (void)unblockUserAction {
    [self unblockUser:_representedUser];
}

- (void)reportUser:(NSString *)userID {

    [[FRSAPIClient sharedClient] reportUser:userID
        params:@{ @"reason" : self.reportUserReasonString,
                  @"message" : self.reportUserAlertView.textView.text }
        completion:^(id responseObject, NSError *error) {

          if (error) {
              [self presentGenericError];
              return;
          }

          if (responseObject) {

              NSString *username = @"";
              if (![_representedUser.username isEqual:[NSNull null]] && (![_representedUser.username isEqualToString:@"<null>"])) {
                  username = [NSString stringWithFormat:@"@%@", _representedUser.username];
              } else if (![_representedUser.firstName isEqual:[NSNull null]] && (![_representedUser.firstName isEqualToString:@"<null>"])) {
                  username = _representedUser.firstName;
              } else {
                  username = @"them";
              }
              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"REPORT SENT" message:[NSString stringWithFormat:@"Thanks for helping make Fresco a better community! Would you like to block %@ as well?", username] actionTitle:@"CLOSE" cancelTitle:@"BLOCK USER" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
              [alert show];
          }
        }];
}

@end
