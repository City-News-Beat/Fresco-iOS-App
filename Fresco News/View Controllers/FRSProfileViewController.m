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

@interface FRSProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITabBarDelegate>

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

@end

@implementation FRSProfileViewController

@synthesize representedUser = _representedUser, authenticatedProfile = _authenticatedProfile;


-(void)loadAuthenticatedUser {
    _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
    self.authenticatedProfile = TRUE;
    [self configureWithUser:_representedUser];
    [self fetchGalleries];
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        if (!_representedUser) {
            _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
            self.authenticatedProfile = TRUE;
        }
    }
    
    return self;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.editedProfile = false;
    
    if (isLoadingUser) {
        return;
    }
    
    if (!_representedUser) {
        _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
        self.authenticatedProfile = TRUE;
        [self configureWithUser:_representedUser];
    }else{
        [[FRSAPIClient sharedClient] getUserWithUID:_representedUser.uid completion:^(id responseObject, NSError *error) {
            _representedUser = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSAPIClient sharedClient] managedObjectContext]];
            [self configureWithUser:_representedUser];
        }];
     }
    
    [self setupUI];
    [self configureUI];
    [self fetchGalleries];
    [super removeNavigationBarLine];
    
    if (self.shouldShowNotificationsOnLoad) {
        [self showNotificationsNotAnimated];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isLoadingUser) {
        return;
    }

    [self showTabBarAnimated:YES];
    self.tableView.bounces = false;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (isLoadingUser) {
        return;
    }

    [self addStatusBarNotification];
    [self showNavBarForScrollView:self.tableView animated:NO];
    
    
    if(!self.editedProfile){
        if (!_representedUser) {
            _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
            self.authenticatedProfile = TRUE;
            [self configureWithUser:_representedUser];
        }else{
            [[FRSAPIClient sharedClient] getUserWithUID:_representedUser.uid completion:^(id responseObject, NSError *error) {
                _representedUser = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSAPIClient sharedClient] managedObjectContext]];
                [self configureWithUser:_representedUser];
            }];
        }
    }else{
        self.editedProfile = false;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeStatusBarNotification];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //This logic should be happen once the notif view is dismissed.
    //We should see the tab bar in the notification view with the notification icon.
//    UITabBarItem *item4 = [self.tabBarController.tabBar.items objectAtIndex:4];
//    item4.image = [[UIImage imageNamed:@"tab-bar-profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item4.selectedImage = [[UIImage imageNamed:@"tab-bar-profile-sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    FRSTabBarController *frsTabBar = (FRSTabBarController *)self.tabBarController;
//    frsTabBar.dot.alpha = 0;
}

-(instancetype)initWithUser:(FRSUser *)user {
    
    if (self) {
        
        _representedUser = user; // obviously save for future
        _authenticatedProfile = [_representedUser.isLoggedIn boolValue]; // signifies profile view is current authed user
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        
    }
    return self;
}


-(instancetype)initWithUserName:(NSString *)userName {
    self = [super init];
    
    if (self) {
        isLoadingUser = TRUE;
        userId = userName;
        [self setupUI];
        [self configureUI];

        [[FRSAPIClient sharedClient] getUserWithUID:userName completion:^(id responseObject, NSError *error) {
            [self addStatusBarNotification];
            [self showNavBarForScrollView:self.tableView animated:NO];
            FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            FRSUser *user = [FRSUser nonSavedUserWithProperties:responseObject context:[delegate managedObjectContext]];
            _representedUser = user;
            
            [self fetchGalleries];
            [super removeNavigationBarLine];
            
            if (self.shouldShowNotificationsOnLoad) {
                [self showNotificationsNotAnimated];
            }
            
            if(!self.editedProfile){
                if (!_representedUser) {
                    _representedUser = [[FRSAPIClient sharedClient] authenticatedUser];
                    self.authenticatedProfile = TRUE;
                    [self configureWithUser:_representedUser];
                }else{
                    [[FRSAPIClient sharedClient] getUserWithUID:userName completion:^(id responseObject, NSError *error) {
                        _representedUser = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSAPIClient sharedClient] managedObjectContext]];
                        [self configureWithUser:_representedUser];
                    }];
                }
            }else{
                self.editedProfile = false;
            }

            [self showTabBarAnimated:YES];
            self.tableView.bounces = false;
        }];
    }
    
    return self;
}
-(void)setupUI {
    
    
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
    [self fetchGalleries];
    [self configureSpinner];
    
    [super removeNavigationBarLine];
    [self configureSectionView];
}


-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(self.view.frame.size.width/2 -10, self.view.frame.size.height/2 - 44 - 10, 20, 20);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

#pragma mark - UITabBarDelegate

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    
    
}

#pragma mark - Fetch Methods

-(void)fetchGalleries {
    BOOL reload = FALSE;
    
    if (self.currentFeed == self.galleries) {
        reload = TRUE;
    }

    [[FRSAPIClient sharedClient] fetchGalleriesForUser:self.representedUser completion:^(id responseObject, NSError *error) {
        self.galleries = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE];
        [self.tableView reloadData];
        
        if (reload) {
            self.currentFeed = self.galleries;
            [self.tableView reloadData];
        }
    }];
    
    [self fetchLikes];
}

-(void)fetchLikes {
    
    BOOL reload = FALSE;
    
    if (self.currentFeed == self.likes && self.likes != Nil) {
        reload = TRUE;
    }
    
    [[FRSAPIClient sharedClient] fetchLikesFeedForUser:self.representedUser completion:^(id responseObject, NSError *error) {
        self.likes = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:responseObject cache:FALSE];
        
        if (reload) {
            self.currentFeed = self.likes;
            [self.tableView reloadData];
        }
    }];
}

-(void)displayAwkwardView: (BOOL)show feedTable:(BOOL)feed{
    
    if (isLoadingUser) {
        return;
    }
    
    if(feed){
        self.feedAwkwardView.hidden = !show;
    }else{
        self.likesAwkwardView.hidden = !show;
    }
}

#pragma mark - UI Elements
-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureNavigationBar];
    //    [self configureTableView];
    //    [self configurePullToRefresh];
    [self configureProfileSocialOverlay];
}

-(void)configurePullToRefresh {
    
    [super removeNavigationBarLine];
    
    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor frescoOrangeColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:0 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:2 actionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView dg_stopLoading];
        });
    } loadingView:loadingView];
    
    
    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
    
}

- (void)dealloc{
    [self.tableView dg_removePullToRefresh];
}


-(void)configureNavigationBar{
    //  [super configureNavigationBar];
    [super removeNavigationBarLine];
    
    //self.navigationItem.title = @"@aesthetique";
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.navigationController.navigationBar.frame.size.height)];
    titleLabel.text = @"";
    titleLabel.font = [UIFont fontWithName:@"Nota-Bold" size:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //NSLog(@"CHILDREN: %lu", self.navigationController.childViewControllers.count);
    
    if ([self.representedUser.uid isEqualToString:[[FRSAPIClient sharedClient] authenticatedUser].uid] && [self.navigationController.childViewControllers  objectAtIndex:0]==self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bell-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showNotificationsAnimated)];
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pen-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showEditProfile)];
        UIBarButtonItem *gearItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
        editItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30);
        
        gearItem.tintColor = [UIColor whiteColor];
        editItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
        
        self.navigationItem.rightBarButtonItems = @[gearItem, editItem];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //?
    }else{
        if(![self.representedUser.uid isEqualToString:[[FRSAPIClient sharedClient] authenticatedUser].uid]){
            self.followBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"follow-white"] style:UIBarButtonItemStylePlain target:self action:@selector(followUser)];
            self.followBarButtonItem.tintColor = [UIColor whiteColor];
            
            if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
                [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];
            } else {
                [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
            }
            
            self.navigationItem.rightBarButtonItem = self.followBarButtonItem;
        }
        [self configureBackButtonAnimated:true];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

-(void)configureTableView{
    
    [self createProfileSection];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (isLoadingUser) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width , [UIScreen mainScreen].bounds.size.height)];
    }
    else {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width , self.view.frame.size.height-44)];
    }
    
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:self.tableView];
}

-(void)createProfileSection{
    self.profileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 269.5)];
    self.profileContainer.backgroundColor = [UIColor frescoOrangeColor];
    
    [self configureProfileImage];
    [self configureLabels];
    [self resizeProfileContainer];
}

-(void)configureProfileImage{
    self.profileBG = [[UIView alloc] initWithFrame:CGRectMake(16, 12, 96, 96)];
    [self.profileContainer addSubview:self.profileBG];
    [self.profileBG addShadowWithColor:[UIColor frescoShadowColor] radius:3 offset:CGSizeMake(0, 2)];
    
    self.profileIV = [[FRSBorderedImageView alloc] initWithFrame:CGRectMake(0, 0, self.profileBG.frame.size.width, self.profileBG.frame.size.height) borderColor:[UIColor whiteColor] borderWidth:4];
    self.profileIV.image = [UIImage imageNamed:@""];
    self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
    self.profileIV.layer.cornerRadius = self.profileIV.frame.size.width/2;
    self.profileIV.clipsToBounds = YES;
    [self.profileBG addSubview:self.profileIV];
    
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

-(void)configureProfileSocialOverlay{
    
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
    self.profileMaskView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.profileMaskView];
    self.whiteOverlay.layer.mask = self.profileMaskView.layer;
    
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (!CGRectContainsPoint(self.profileIV.frame, point)) {
        [self dismissSocialOverlay];
    }
}

-(void)presentSocialOverlay{
    
    if (!self.overlayPresented) {
        
        //Set overlay presented state to prevent animating if double tapped
        self.overlayPresented = YES;
        
        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.profileMaskView.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:nil];
        
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

-(void)dismissSocialOverlay{
    
    //Set overlay presented state to prevent animating if double tapped
    self.overlayPresented = NO;
    
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.profileMaskView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        
    } completion:nil];
    
    //    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
    //
    //        self.socialButtonContainer.alpha = 0;
    //        self.socialButtonContainer.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    //        self.whiteOverlay.alpha = 0;
    //
    //    } completion:nil];
    
}

-(void)configureLabels{
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
    
    self.bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin-4, 65, 150, self.profileContainer.frame.size.width - (origin-4) - 16)];
    
    //self.bioLabel.text = @""; //temp fix, need to make frame larger because of sizeToFit, disabling sizeToFit causes other issues.
    self.bioLabel.backgroundColor = [UIColor frescoOrangeColor];
    self.bioLabel.textColor = [UIColor whiteColor];
    self.bioLabel.font = [UIFont systemFontOfSize:15 weight:-300];
    //    [self.bioLabel sizeToFit];
    [self.profileContainer addSubview:self.bioLabel];

}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text) {
        /*[[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"bio":textView.text} completion:^(id responseObject, NSError *error) {
            NSLog(@"%@ %@", responseObject, error);
        }];*/
        [textView resignFirstResponder];
    }
}

-(void)resizeProfileContainer{
    
    CGFloat height = MAX(self.bioLabel.frame.origin.y + self.bioLabel.frame.size.height + 6, 160);
    
    [self.profileContainer setSizeWithSize:CGSizeMake(self.profileContainer.frame.size.width, height)];
    
    [self.sectionView setFrame:CGRectMake(0, self.profileContainer.frame.size.height, self.view.frame.size.width, 44)];
}

-(void)configureSectionView{
    self.sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.profileContainer.frame.size.height, self.view.frame.size.width, 44)];
    self.sectionView.backgroundColor = [UIColor frescoOrangeColor];
    
    self.feedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.sectionView.frame.size.width/2, self.sectionView.frame.size.height)];
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

-(void)handleFeedbackButtonTapped{
    if (self.feedButton.alpha > 0.7) return; //The button is already selected
    
    self.feedButton.alpha = 1.0;
    self.likesButton.alpha = 0.7;
    
    
    if (self.currentFeed != self.galleries) {
        self.currentFeed = self.galleries;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)handleLikesButtonTapped{
    if (self.likesButton.alpha > 0.7) return; //The button is already selected
    
    self.likesButton.alpha = 1.0;
    self.feedButton.alpha = 0.7;
    
    if (self.currentFeed != self.likes) {
        self.currentFeed = self.likes;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

-(void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)notification {
    
    FRSGallery *gallery = self.galleries[notification.row];
    
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:gallery];
    vc.shouldHaveBackButton = YES;
    [super showNavBarForScrollView:self.tableView animated:NO];
    
    self.navigationItem.title = @"";
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self hideTabBarAnimated:YES];
}

-(void)readMoreStory:(NSIndexPath *)indexPath {
    FRSStoryCell *storyCell = [self.tableView cellForRowAtIndexPath:indexPath];
    FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:storyCell.story];
    detailView.navigationController = self.navigationController;
    [self.navigationController pushViewController:detailView animated:YES];
}

-(FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

#pragma mark - UITableView Delegate & DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
    
    //We have two sections for our tableview. The first section holds the profile container and has a header height of 0.
    //The second section holds the feed/likes, and the header has the segmented tab and has a height of 44.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0){
        return 1;
    }
    else {
        if (!self.currentFeed) {
            self.currentFeed = self.galleries;
        }

        //Awkward View
        if(tableView == self.tableView){
            if(self.currentFeed.count == 0){
                [self displayAwkwardView:true feedTable:false];
            }else{
                [self displayAwkwardView:false feedTable:false];
            }
        }else if(tableView == self.contentTable){
            if(self.currentFeed.count == 0){
                [self displayAwkwardView:true feedTable:true];
            }else{
                [self displayAwkwardView:false feedTable:true];
            }
        }
        
        if(self.currentFeed.count == 0){
            return 1;
        }else{
            return self.currentFeed.count;
        }
        
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0;
    }
    else{
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return self.profileContainer.frame.size.height+64;
    }
    else {
        if (!self.currentFeed.count) return 60;
        if ([[self.currentFeed[indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
            FRSGallery *gallery = self.currentFeed[indexPath.row];
            return [gallery heightForGallery];
        }
        else {
            FRSStory *story = self.currentFeed[indexPath.row];
            return [story heightForStory];
        }
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    if (indexPath.section == 0){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profile-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        if(self.currentFeed.count == 0){
            cell = [[UITableViewCell alloc] init];
            CGRect newFrame = tableView.frame;
            newFrame.size.height = 40;
            newFrame.origin.y = tableView.frame.size.height/6;
            [cell.contentView addSubview:[[FRSAwkwardView alloc] initWithFrame:newFrame]];
            [cell.contentView setBackgroundColor:[UIColor frescoBackgroundColorDark]];
            [cell setBackgroundColor:[UIColor frescoBackgroundColorDark]];
        }else if ([[[self.currentFeed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
            
            if (!cell){
                cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
            }
        }
        else if ([[[self.currentFeed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSStory class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
            
            if (!cell){
                cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
            }
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section== 0){
        [cell addSubview:self.profileContainer];
    }
    else {
        __weak typeof(self) weakSelf = self;

        if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
            FRSGalleryCell *galCell = (FRSGalleryCell *)cell;
            galCell.galleryView.delegate.navigationController = self.navigationController;
            [galCell clearCell];
            
            galCell.shareBlock = ^void(NSArray *sharedContent) {
                [weakSelf showShareSheetWithContent:sharedContent];
            };
            
            galCell.readMoreBlock = ^(NSArray *bullshit){
                [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
            };
            
            galCell.gallery = self.currentFeed[indexPath.row];
            [galCell configureCell];
        }else if(self.currentFeed.count == 0){
            
        }else {
            FRSStoryCell *storyCell = (FRSStoryCell *)cell;
            storyCell.storyView.navigationController = self.navigationController;
            [storyCell clearCell];
            
            storyCell.shareBlock = ^void(NSArray *sharedContent) {
                [weakSelf showShareSheetWithContent:sharedContent];
            };
            
            storyCell.readMoreBlock = ^(NSArray *bullshit){
                [weakSelf readMoreStory:indexPath];
            };
            
            storyCell.story = self.currentFeed[indexPath.row];
            [storyCell configureCell];
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view;
    
    view.backgroundColor = [UIColor clearColor];
    topView.backgroundColor = [UIColor clearColor];
    
    if (section == 0){
        view = [UIView new];
    }
    else if (section == 1){
        //[self configureSectionView];
        
        if (topView) {
            return topView;
        }
        //[self configureSectionView];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 44)];
        [self.sectionView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];

        topView = view;
        return topView;
    }
    
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    //Bounce only at the bottom of the tableview
    scrollView.bounces = (scrollView.contentOffset.y > 10);
    
    CGRect newFrame = self.sectionView.frame;
    
    newFrame.origin.y = (self.navBarYValue/self.navBarHeight)*(self.sectionView.frame.size.height)-self.sectionView.frame.size.height;
    
    //Prevent it from over extending (going past the bottom of the nav bar)
    if(newFrame.origin.y > 0){
        newFrame.origin.y = 0;
    }
    
    //If it goes over the profile height, attach it to the bot of the profile container view
    CGPoint localPoint = newFrame.origin;
    CGPoint basePoint = [self.view convertPoint:localPoint toView:self.tableView];
    if(basePoint.y < self.profileContainer.frame.size.height + (_sectionView.frame.size.height*1.5)){
        newFrame.origin.y = self.profileContainer.frame.size.height-scrollView.contentOffset.y;
    }
    
    [self.sectionView setFrame:newFrame];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}

#pragma mark - Navigation

//Breaking this up into two methods because presentVC:animated: is being passed into the notification button's selector and defaulting to NO.
-(void)showNotificationsAnimated {
    FRSUserNotificationViewController *notifVC = [[FRSUserNotificationViewController alloc] init];

    [self.navigationController pushViewController:notifVC animated:NO];
}

//Breaking this up into two methods because presentVC:animated: is being passed into the notification button's selector and defaulting to NO.
-(void)showNotificationsNotAnimated {
    FRSUserNotificationViewController *notifVC = [[FRSUserNotificationViewController alloc] init];
    
    [self.navigationController pushViewController:notifVC animated:NO];
}

-(void)showSettings {
    self.navigationController.hidesBottomBarWhenPushed = YES;
    FRSSettingsViewController *settingsVC = [[FRSSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
    self.navigationItem.title = @"";
    [self hideTabBarAnimated:YES];
}

-(void)followUser {
    
    
    UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    FRSSearchViewController *searchVC = (FRSSearchViewController *)previousController;
    
    if ([previousController isKindOfClass:[FRSSearchViewController class]]) {
        searchVC.shouldUpdateOnReturn = YES;
    } else {
        searchVC.shouldUpdateOnReturn = NO;
    }

    
    
    [[FRSAPIClient sharedClient] followUser:self.representedUser completion:^(id responseObject, NSError *error) {
        if (error) {
            return;
        }
        
        if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
            [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];
            NSLog(@"FOLLOWED USER: %d %@", (error == Nil), self.representedUser.uid);
        } else {
            [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
            [self unfollowUser];
        }
    }];
}

-(void)unfollowUser {
    [[FRSAPIClient sharedClient] unfollowUser:self.representedUser completion:^(id responseObject, NSError *error) {
        if (error) {
            return;
        }
        
        if ([[_representedUser valueForKey:@"following"] boolValue] == TRUE) {
            [self.followBarButtonItem setImage:[UIImage imageNamed:@"followed-white"]];
        } else {
            [self.followBarButtonItem setImage:[UIImage imageNamed:@"follow-white"]];
        }
        NSLog(@"UNFOLLOWED USER: %d %@", (error == Nil), self.representedUser.uid);
    }];
}

-(void)showEditProfile {
    [self segueToSetup];
}

-(void)segueToSetup {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate reloadUser];
    
    FRSSetupProfileViewController *setupProfileVC = [[FRSSetupProfileViewController alloc] init];
    setupProfileVC.nameStr = self.nameLabel.text;
    setupProfileVC.locStr = self.locationLabel.text;
    setupProfileVC.bioStr = self.bioLabel.text;
    setupProfileVC.profileImageURL = self.profileImageURL;
    setupProfileVC.isEditingProfile = true;
    [self.navigationController pushViewController:setupProfileVC animated:YES];
}

-(void)showFollowers {
    NSLog(@"Pushing1");
    FRSFollowersViewController *vc = [[FRSFollowersViewController alloc] init];
    NSLog(@"Pushing2");
    vc.representedUser = _representedUser;
    NSLog(@"Pushing3");
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Social Overlay Actions

-(void)twitterTapped{
    [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
        
    }];
}

-(void)facebookTapped {
    [FRSSocial loginWithFacebook:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
        
    } parent:self]; // presenting view controller
    
}

#pragma mark - User

-(void)configureWithUser:(FRSUser *)user {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // self.profileIV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.profileImage]]];
        self.nameLabel.text = user.username;
        if(user.profileImage != [NSNull null]){
            self.profileImageURL = [NSURL URLWithString:user.profileImage];
            [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:user.profileImage]];
        }
        
        //self.locationLabel.text = user.
        [self.bioLabel setNumberOfLines:0];
        self.bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.bioLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;

        self.bioLabel.text = user.bio;
        NSLog(@"USER'S BIO: %@", user.bio);
        [self.bioLabel sizeToFit];
        
        //[self.profileContainer setFrame:CGRectMake(self.profileContainer.frame.origin.x, self.profileContainer.frame.origin.y, self.profileContainer.frame.size.width,269.5 + self.bioLabel.frame.size.height)];
        [self resizeProfileContainer];
        //[self.bioLabel setFrame:CGRectMake(self.bioLabel.frame.origin.x, self.bioLabel.frame.origin.y, self.bioLabel.frame.size.width, lineHeight * self.bioLabel.numberOfLines)];
        
        self.nameLabel.text = user.firstName;
        
        NSLog(@"FOLLOWERS: %@",[user valueForKey:@"followedCount"]);
        
        [self.followersButton setTitle:[NSString stringWithFormat:@"%@", [user valueForKey:@"followedCount"]] forState:UIControlStateNormal];
        
        NSLog(@"%@", user);
        self.locationLabel.text = [user valueForKey:@"location"];
        //self.bioLabel.text = user.bio;
        //[self.bioLabel sizeToFit];
        
        self.usernameLabel.text = user.username;
        titleLabel.text = [NSString stringWithFormat:@"@%@", user.username];
        
        if ([user.username isEqualToString:@""] || !user.username || [user.username isEqual:[NSNull null]]) {
            if (![user.firstName isEqualToString:@""]) {
                titleLabel.adjustsFontSizeToFitWidth = YES;
                titleLabel.text = user.firstName;
            }
            else {
                titleLabel.text = @"";
            }
        }
        //  self.locationLabel.text = user.address; //user.address does not exiset yet
        
        [self.loadingView stopLoading];
        [self.loadingView removeFromSuperview];
    });
}


@end
