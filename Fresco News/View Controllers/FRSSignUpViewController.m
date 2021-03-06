//
//  FRSSignUpViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSignUpViewController.h"
#import "FRSSetupProfileViewController.h" // !HELPFUL, LOOP BACK
#import "FRSLoginViewController.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import "FRSAlertView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSAppDelegate.h"
#import "FRSNavigationController.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FRSNavigationController.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSPermissionAlertView.h"
#import "FRSSignUpAlertView.h"
#import "NSString+Validation.h"
#import "FRSConnectivityAlertView.h"
#import "FRSSnapKit.h"
#import <QuartzCore/QuartzCore.h>
#import <UXCam/UXCam.h>
#import <Crashlytics/Crashlytics.h>

@import MapKit;

@interface FRSSignUpViewController () <UITextFieldDelegate, MKMapViewDelegate, UIScrollViewDelegate, FRSAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextField *usernameTF;
@property (strong, nonatomic) UITextField *emailTF;
@property (strong, nonatomic) UITextField *passwordTF;
@property (strong, nonatomic) UITextField *promoTF;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UISlider *radiusSlider;
@property (strong, nonatomic) UIView *bottomBar;
@property (strong, nonatomic) UIButton *createAccountButton;
@property (strong, nonatomic) UILabel *promoDescription;
@property (strong, nonatomic) UITapGestureRecognizer *dismissGR;
@property (strong, nonatomic) UIView *usernameHighlightLine;
@property (strong, nonatomic) UIImageView *usernameCheckIV;
@property (strong, nonatomic) UIView *sliderContainer;
@property (strong, nonatomic) UIView *promoContainer;
@property (nonatomic) NSInteger y;
@property (nonatomic) BOOL notificationsEnabled;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) FRSAlertView *alert;
@property (strong, nonatomic) UIView *errorContainer;
@property (strong, nonatomic) UIView *assignmentsCard;
@property (nonatomic) BOOL emailError;
@property (nonatomic) BOOL usernameTaken;
@property (nonatomic) BOOL emailTaken;
@property (strong, nonatomic) NSTimer *usernameTimer;
@property (nonatomic) NSInteger yPos;
@property (nonatomic) NSInteger height;
@property BOOL locationEnabled;
@property (nonatomic) CGFloat miles;
@property (strong, nonatomic) UIView *TOSContainerView;
@property (strong, nonatomic) UIButton *TOSCheckBoxButton;
@property BOOL TOSAccepted;
@property (strong, nonatomic) FRSSetupProfileViewController *setupProfileVC;
@property CGFloat latitude;
@property CGFloat longitude;
@property (strong, nonatomic) NSMutableArray *formViews;

@end

@implementation FRSSignUpViewController
@synthesize twitterSession = _twitterSession, facebookToken = _facebookToken, facebookButton = _facebookButton, twitterButton = _twitterButton, currentSocialDigest = _currentSocialDigest;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];

    //[self addNotifications];

    self.notificationsEnabled = NO;
    self.emailError = NO;

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];
    }

    self.setupProfileVC = [[FRSSetupProfileViewController alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self addNotifications];
}

- (NSDictionary *)currentSocialDigest {
    return [[FRSAuthManager sharedInstance] socialDigestionWithTwitter:_twitterSession facebook:_facebookToken];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FRSTracker track:onboardingReads];

    if (!_hasShown) {
        //        [self.usernameTF becomeFirstResponder];
    }
    _hasShown = TRUE;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    self.navigationItem.title = @"SIGN UP";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17] }];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    backItem.imageInsets = UIEdgeInsetsMake(2, -4.5, 0, 0);
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem animated:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToPreviousViewController) name:@"returnToPreviousViewController" object:nil];
}

- (void)back {
    BOOL shouldGoBack = NO;

    if ((![self.passwordTF.text isEqualToString:@""]) || (![self.emailTF.text isEqualToString:@""]) || ([self.usernameTF.text length] > 1)) {

        [self.passwordTF resignFirstResponder];
        [self.emailTF resignFirstResponder];
        [self.usernameTF resignFirstResponder];
        [self.promoTF resignFirstResponder];

        self.alert = [[FRSSignUpAlertView alloc] initSignUpAlert];

        [self.alert show];
    } else {
        shouldGoBack = YES;
    }

    if (shouldGoBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)returnToPreviousViewController {
    [self.alert dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";

    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack

    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:facebookName];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];

        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:twitterHandle];

        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:settingsUserNotificationRadius];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.miles] forKey:settingsUserNotificationRadius];

    FRSUser *userToUpdate = [[FRSUserManager sharedInstance] authenticatedUser];
    userToUpdate.notificationRadius = @(self.miles);
    [[[FRSUserManager sharedInstance] managedObjectContext] save:Nil];
}

- (void)updateUserLocationOnMap {

    if (self.latitude && self.longitude) {
        return;
    }

    self.latitude = [FRSLocator sharedLocator].currentLocation.coordinate.latitude;
    self.longitude = [FRSLocator sharedLocator].currentLocation.coordinate.longitude;

    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);

    MKCoordinateRegion region;
    region.center.latitude = self.latitude;
    region.center.longitude = self.longitude;
    region.span.latitudeDelta = 0.015;
    region.span.longitudeDelta = 0.015;
    self.mapView.region = region;

    [self zoomToCoordinates:[NSNumber numberWithDouble:[[FRSLocator sharedLocator] currentLocation].coordinate.latitude] lon:[NSNumber numberWithDouble:[[FRSLocator sharedLocator] currentLocation].coordinate.longitude] withRadius:@(self.miles) withAnimation:YES];
}

- (void)addNotifications {

    /* Keyboard Notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    /* Text Field Notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:self.usernameTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:self.emailTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:self.passwordTF];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    self.formViews = [[NSMutableArray alloc] init];

    [self configureScrollView];
    [self configureTextFields];
    [self configureNotificationSection];
    [self configureMapView];
    [self configureSliderSection];
    [self configureTOS];
    //    [self configurePromoSection];
    [self adjustScrollViewContentSize];
    [self configureBottomBar];
}

- (void)configureScrollView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.height = self.view.frame.size.height - 44;
    self.yPos = 64;

    if ([self.navigationController.viewControllers indexOfObject:self] == 2) {
        self.height = self.view.frame.size.height - 44 - 52 - 12;
        self.yPos = 0;
    }

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.yPos, self.view.frame.size.width, self.height)];

    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = NO;

    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.scrollView];

    if (IS_IPHONE_6) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.frame.size.height + self.promoTF.frame.size.height + self.promoDescription.frame.size.height + 24);
    } else if (IS_IPHONE_6_PLUS) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.frame.size.height + self.promoTF.frame.size.height + self.promoDescription.frame.size.height - 12);
    } else if (IS_IPHONE_5) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.frame.size.height + self.promoTF.frame.size.height + self.promoDescription.frame.size.height + 84);
    }
}

- (void)configureTextFields {
    [self configureUserNameField];
    [self configureEmailAddressField];
    [self configurePasswordField];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}

- (void)configureUserNameField {
    self.usernameTF = [[UITextField alloc] initWithFrame:CGRectMake(48, 24, self.scrollView.frame.size.width - 2 * 48, 44)];
    self.usernameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"@username" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont notaMediumWithSize:17] }];
    self.usernameTF.delegate = self;
    self.usernameTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTF.textColor = [UIColor frescoDarkTextColor];
    self.usernameTF.font = [UIFont notaMediumWithSize:17];
    self.usernameTF.tintColor = [UIColor frescoOrangeColor];
    self.usernameTF.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:self.usernameTF];

    self.usernameHighlightLine = [[UIView alloc] initWithFrame:CGRectMake(48, 92 - 64 + 44, self.usernameTF.frame.size.width, 0.5)];
    self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
    [self.scrollView addSubview:self.usernameHighlightLine];

    self.usernameCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-green"]];
    self.usernameCheckIV.frame = CGRectMake(self.usernameTF.frame.size.width - 24, 10, 24, 24);
    self.usernameCheckIV.alpha = 0;
    [self.usernameTF addSubview:self.usernameCheckIV];
}

- (void)configureEmailAddressField {

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];

    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];

    self.emailTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email address" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1] }];
    self.emailTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.emailTF.delegate = self;
    self.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTF.textColor = [UIColor frescoDarkTextColor];
    self.emailTF.tintColor = [UIColor frescoOrangeColor];
    self.emailTF.font = [UIFont systemFontOfSize:15];
    self.emailTF.returnKeyType = UIReturnKeyNext;

    [backgroundView addSubview:self.emailTF];

    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
}

- (void)configurePasswordField {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 136, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];

    self.passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1] }];
    self.passwordTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.passwordTF.delegate = self;
    self.passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTF.textColor = [UIColor frescoDarkTextColor];
    self.passwordTF.tintColor = [UIColor frescoOrangeColor];
    self.passwordTF.font = [UIFont systemFontOfSize:15];
    self.passwordTF.secureTextEntry = YES;
    self.passwordTF.returnKeyType = UIReturnKeyNext;

    [backgroundView addSubview:self.passwordTF];

    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
}

- (void)configureNotificationSection {
    self.assignmentsCard = [[UIView alloc] initWithFrame:CGRectMake(0, 192, self.scrollView.frame.size.width, 62)];
    self.assignmentsCard.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.assignmentsCard];
    [self.formViews addObject:self.assignmentsCard];

    UILabel *topLabel = [[UILabel alloc] init];
    topLabel.text = @"ASSIGNMENT NOTIFICATIONS";
    topLabel.textColor = [UIColor frescoDarkTextColor];
    topLabel.font = [UIFont notaBoldWithSize:15];
    [topLabel sizeToFit];
    [topLabel setFrame:CGRectMake(16, 15, topLabel.frame.size.width, topLabel.frame.size.height)];
    [self.assignmentsCard addSubview:topLabel];

    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.text = @"We'll tell you about paid photo ops nearby";
    bottomLabel.textColor = [UIColor frescoMediumTextColor];
    bottomLabel.font = [UIFont systemFontOfSize:12];
    [bottomLabel sizeToFit];
    bottomLabel.frame = CGRectMake(16, 36, bottomLabel.frame.size.width, bottomLabel.frame.size.height);
    [self.assignmentsCard addSubview:bottomLabel];

    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.assignmentsCard.frame.size.width - 51 - 12, 15.5, 51, 31)];
    toggle.on = NO;
    toggle.onTintColor = [UIColor frescoGreenColor];
    [toggle addTarget:self action:@selector(handleToggleSwitched:) forControlEvents:UIControlEventValueChanged];
    [self.assignmentsCard addSubview:toggle];

    [self.assignmentsCard addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];

    [self.assignmentsCard addSubview:[UIView lineAtPoint:CGPointMake(0, 61.5)]];
}

- (void)configureTOS {

    self.y += 44 + 12; // cc: dan
    self.TOSContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.assignmentsCard.frame.origin.y + self.assignmentsCard.frame.size.height + 12, self.view.frame.size.width, 44)];
    [self.scrollView addSubview:self.TOSContainerView];
    [self.formViews addObject:self.TOSContainerView];

    self.TOSCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.TOSCheckBoxButton setImage:[UIImage imageNamed:@"check-disabled"] forState:UIControlStateNormal];
    self.TOSCheckBoxButton.frame = CGRectMake(16, 10, 24, 24);
    [self.TOSCheckBoxButton addTarget:self action:@selector(acceptTOS) forControlEvents:UIControlEventTouchUpInside];
    [self.TOSContainerView addSubview:self.TOSCheckBoxButton];

    UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 11, 215, 20)];
    agreeLabel.textColor = [UIColor frescoDarkTextColor];
    agreeLabel.text = @"I agree to the";
    agreeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    [self.TOSContainerView addSubview:agreeLabel];

    UIButton *safariButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [safariButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    safariButton.frame = CGRectMake(147, 11, 120, 20);
    safariButton.tintColor = [UIColor frescoDarkTextColor];
    [safariButton setTitle:@"terms of service" forState:UIControlStateNormal];
    safariButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [safariButton addTarget:self action:@selector(openSafari) forControlEvents:UIControlEventTouchUpInside];
    [self.TOSContainerView addSubview:safariButton];
}

- (void)openSafari {
    NSURL *termsURL = [NSURL URLWithString:@"https://fresconews.com/terms"];
    [[UIApplication sharedApplication] openURL:termsURL];
}

- (void)acceptTOS {

    //We need the bearer token to accept TOS, actual accepting happens on the API when the user creates their account.

    if (!self.TOSAccepted) {
        self.TOSAccepted = YES;
        [self.TOSCheckBoxButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.TOSCheckBoxButton setImage:[UIImage imageNamed:@"check-enabled"] forState:UIControlStateNormal];
    } else {
        self.TOSAccepted = NO;
        [self.TOSCheckBoxButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.TOSCheckBoxButton setImage:[UIImage imageNamed:@"check-disabled"] forState:UIControlStateNormal];
    }

    [self checkCreateAccountButtonState];

    if ([self checkFields]) {
        [self toggleCreateAccountButtonTitleColorToState:UIControlStateHighlighted];
    }
}

- (void)configureMapView {

    NSInteger height = 240;
    if (IS_STANDARD_IPHONE_6)
        height = 280;
    if (IS_STANDARD_IPHONE_6_PLUS)
        height = 310;

    //Up until this point all the ui elements were static heights
    //The map height is dependent on the iPhone size now
    //We use a variable for easy tracking of the y-origin of subsequent elements
    //Eventually it will also be used to adjust the content size of the scroll view
    self.y = 254;

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 254, self.scrollView.frame.size.width, height)];
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(40.00123, -70.10239);

    MKCoordinateRegion region;
    region.center.latitude = 40.7118;
    region.center.longitude = -74.0105;
    region.span.latitudeDelta = 0.015;
    region.span.longitudeDelta = 0.015;
    self.mapView.region = region;

    [self.scrollView addSubview:self.mapView];

    [self.mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];

    self.y += self.mapView.frame.size.height;

    self.mapView.transform = CGAffineTransformMakeScale(0.93, 0.93);
    self.mapView.alpha = 0;

    CGFloat circleRadius;
    if (IS_IPHONE_5) {
        circleRadius = 208;
    } else if (IS_IPHONE_6) {
        circleRadius = 248;
    } else if (IS_IPHONE_6_PLUS) {
        circleRadius = 278;
    }

    UIView *mapCircleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - circleRadius / 2, 16, circleRadius, circleRadius)];
    mapCircleView.backgroundColor = [UIColor frescoLightBlueColor];
    mapCircleView.layer.cornerRadius = circleRadius / 2;
    [self.mapView addSubview:mapCircleView];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(mapCircleView.frame.size.width / 2 - 24 / 2, mapCircleView.frame.size.height / 2 - 24 / 2, 24, 24)];
    view.backgroundColor = [UIColor whiteColor];

    view.layer.cornerRadius = 12;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 2);
    view.layer.shadowOpacity = 0.15;
    view.layer.shadowRadius = 1.5;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [[UIScreen mainScreen] scale];

    [mapCircleView addSubview:view];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(mapCircleView.frame.size.width / 2 - 18 / 2, mapCircleView.frame.size.height / 2 - 18 / 2, 18, 18);
    imageView.layer.cornerRadius = 9;
    [mapCircleView addSubview:imageView];

    if ([FRSUserManager sharedInstance].authenticatedUser.profileImage) {

    } else {
        imageView.backgroundColor = [UIColor frescoBlueColor];
    }
}

- (void)configureSliderSection {

    self.sliderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.origin.y + self.mapView.frame.size.height, self.scrollView.frame.size.width, 56)];
    self.sliderContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.sliderContainer];

    [self.sliderContainer addSubview:[UIView lineAtPoint:CGPointMake(0, 0)]];
    [self.sliderContainer addSubview:[UIView lineAtPoint:CGPointMake(0, self.sliderContainer.frame.size.height)]];

    self.radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.view.frame.size.width - 104, 28)];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [self.radiusSlider setMaximumTrackTintColor:[UIColor colorWithWhite:181 / 255.0 alpha:1.0]];
    [self.radiusSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderContainer addSubview:self.radiusSlider];

    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [self.self.sliderContainer addSubview:smallIV];

    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [self.sliderContainer addSubview:bigIV];

    self.y += self.sliderContainer.frame.size.height + 12;

    self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height + 18));
    self.sliderContainer.alpha = 0;
}

- (void)sliderValueChanged:(UISlider *)slider {

    if (!_firstSlide) {
        _firstSlide = TRUE;
        [FRSTracker track:signupRadiusChange];
    }

    self.miles = slider.value * 50;

    if (slider.value == 0) {
        return;
    }

    [self zoomToCoordinates:[NSNumber numberWithDouble:[[FRSLocator sharedLocator] currentLocation].coordinate.latitude] lon:[NSNumber numberWithDouble:[[FRSLocator sharedLocator] currentLocation].coordinate.longitude] withRadius:@(self.miles) withAnimation:YES];
}

- (void)zoomToCoordinates:(NSNumber *)lat lon:(NSNumber *)lon withRadius:(NSNumber *)radius withAnimation:(BOOL)animate {
    // Span uses degrees, 1 degree = 69 miles
    MKCoordinateSpan span = MKCoordinateSpanMake(
        ([radius floatValue] / 30),
        ([radius floatValue] / 30));
    MKCoordinateRegion region = { CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]), span };
    MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];

    [self.mapView setRegion:regionThatFits animated:animate];
}

- (void)configurePromoSection {

    self.promoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.assignmentsCard.frame.origin.y + self.assignmentsCard.frame.size.height + 12, self.scrollView.frame.size.width, 44)];
    self.promoContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.promoContainer];

    [self.promoContainer addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];

    self.promoTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.promoTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Promo" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1] }];
    self.promoTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.promoTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.promoTF.tintColor = [UIColor frescoOrangeColor];
    self.promoTF.delegate = self;
    self.promoTF.font = [UIFont systemFontOfSize:15];
    self.promoTF.returnKeyType = UIReturnKeyGo;
    [self.promoContainer addSubview:self.promoTF];
    [self.promoContainer addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];

    self.y += self.promoContainer.frame.size.height + 12;

    self.promoDescription = [[UILabel alloc] initWithFrame:CGRectMake(16, self.promoContainer.frame.size.height + 12, self.scrollView.frame.size.width - 2 * 16, 28)];
    self.promoDescription.numberOfLines = 0;
    self.promoDescription.text = @"If you use a friend’s promo code, you’ll get $20 when you respond to an assignment for the first time.";
    self.promoDescription.font = [UIFont systemFontOfSize:12];
    self.promoDescription.textColor = [UIColor frescoMediumTextColor];
    [self.promoDescription sizeToFit];
    [self.promoContainer addSubview:self.promoDescription];

    self.y += self.promoDescription.frame.size.height + 24;
}

- (void)adjustScrollViewContentSize {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.y);
}

- (void)configureBottomBar {

    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44 - 64, self.view.frame.size.width, 44)];
    self.bottomBar.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.bottomBar];

    [self.bottomBar addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];

    self.createAccountButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 167, 0, 167, 44)];
    [self.createAccountButton setTitle:@"CREATE MY ACCOUNT" forState:UIControlStateNormal];
    [self.createAccountButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self toggleCreateAccountButtonTitleColorToState:UIControlStateNormal];
    [self.createAccountButton addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.createAccountButton];

    [self addSocialButtonsToBottomBar];

    [FRSSnapKit constrainSubview:self.bottomBar ToBottomOfParentView:self.view WithHeight:44];
}

- (void)toggleCreateAccountButtonTitleColorToState:(UIControlState)controlState {
    if (controlState == UIControlStateNormal) {
        [self.createAccountButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.createAccountButton.enabled = NO;
    } else {
        [self.createAccountButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.createAccountButton setTitleColor:[[UIColor frescoBlueColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        self.createAccountButton.enabled = YES;
    }
}

- (void)addSocialButtonsToBottomBar {
    _twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 1, 24 + 18, 24 + 18)];
    [_twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
    [_twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateHighlighted];
    [_twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateSelected];
    [_twitterButton addTarget:self action:@selector(twitterTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:_twitterButton];

    _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(_twitterButton.frame.origin.x + _twitterButton.frame.size.width, 1, 24 + 18, 24 + 18)];
    [_facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [_facebookButton setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateHighlighted];
    [_facebookButton setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateSelected];
    [_facebookButton addTarget:self action:@selector(facebookTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.bottomBar addSubview:_facebookButton];
}

- (void)animateTextFieldError:(UITextField *)textField {
    CGFloat duration = 0.1;

    /* SHAKE */
    [UIView animateWithDuration:duration
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{

          textField.transform = CGAffineTransformMakeTranslation(-7.5, 0);

        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:duration
              delay:0.0
              options:UIViewAnimationOptionCurveEaseInOut
              animations:^{

                textField.transform = CGAffineTransformMakeTranslation(5, 0);

              }
              completion:^(BOOL finished) {
                [UIView animateWithDuration:duration
                    delay:0.0
                    options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{

                      textField.transform = CGAffineTransformMakeTranslation(-2.5, 0);

                    }
                    completion:^(BOOL finished) {
                      [UIView animateWithDuration:duration
                          delay:0.0
                          options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{

                            textField.transform = CGAffineTransformMakeTranslation(2.5, 0);

                          }
                          completion:^(BOOL finished) {
                            [UIView animateWithDuration:duration
                                                  delay:0.0
                                                options:UIViewAnimationOptionCurveEaseInOut
                                             animations:^{

                                               textField.transform = CGAffineTransformMakeTranslation(0, 0);

                                             }
                                             completion:nil];
                          }];
                    }];
              }];
        }];
}

- (void)animateUsernameCheckImageView:(UIImageView *)imageView animateIn:(BOOL)animateIn success:(BOOL)success {

    if (success) {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-green"];
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
    }

    if (animateIn) {
        if (self.usernameCheckIV.alpha == 0) {

            self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.usernameCheckIV.alpha = 0;
            self.usernameCheckIV.alpha = 1;
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1, 1);
        }
    } else {

        self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
        self.usernameCheckIV.alpha = 0;
    }
}

#pragma mark - TextField Delegate

- (void)textFieldDidChange {
    if ((self.emailTF.isEditing) && ([self.emailTF.text isValidEmail])) {
        [self checkEmail];
    }

    if (self.usernameTF.isEditing) {
        [self startUsernameTimer];

        if ([[self.usernameTF.text substringFromIndex:1] isEqualToString:@""]) {
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:NO success:NO];
        }
    }

    [self checkCreateAccountButtonState];
}

- (void)checkCreateAccountButtonState {
    UIControlState controlState;
    if (([self.usernameTF.text length] > 0) && ([self.emailTF.text length] > 0) && ([self.passwordTF.text length] > 0)) {

        if ([[self.usernameTF.text substringFromIndex:1] isValidUsername] && [self.emailTF.text isValidEmail] && [self.passwordTF.text isValidPassword] && (!self.emailTaken) && (!self.usernameTaken) && (self.TOSAccepted)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }

        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
}

- (void)dismissKeyboard {
    [self highlightTextField:nil enabled:NO];

    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTF) {
        if (![[self.usernameTF.text substringFromIndex:1] isValidUsername] || [textField.text isEqualToString:@"@"]) {
            [self animateTextFieldError:self.usernameTF];
            [textField becomeFirstResponder];
            self.usernameCheckIV.alpha = 0;
            return FALSE;
        }
        [self.emailTF becomeFirstResponder];
    } else if (textField == self.emailTF) {
        if (![textField.text isValidEmail] || [self.emailTF.text isEqualToString:@""]) {
            [self animateTextFieldError:textField];
            [textField becomeFirstResponder];
            return FALSE;
        }

        [self.passwordTF becomeFirstResponder];
    } else if (textField == self.passwordTF) {
        [self.passwordTF resignFirstResponder];
    }

    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.usernameTF) {
        [self startUsernameTimer];

        [self highlightTextField:self.usernameTF enabled:YES];
        if ([self.usernameTF.text isEqualToString:@""]) {
            self.usernameTF.text = @"@";
        }
    }

    if (self.usernameTF.isFirstResponder || self.emailTF.isFirstResponder || self.passwordTF.isFirstResponder) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    if ([self.usernameTF.text length] == 0) {
        return;
    }

    if (textField == self.usernameTF) {

        [self usernameTimerFired];
        [self stopUsernameTimer];

        [self highlightTextField:self.usernameTF enabled:NO];

        if (![[self.usernameTF.text substringFromIndex:1] isValidUsername]) {
            [self animateTextFieldError:self.usernameTF];
            [textField becomeFirstResponder];
            return;
        }

        if ([self.usernameTF.text isEqualToString:@"@"]) {
            self.usernameTF.text = @"";
            return;
        }
    }
}

- (void)startUsernameTimer {
    if (!self.usernameTimer) {
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(usernameTimerFired) userInfo:nil repeats:YES];
    }
}

- (void)stopUsernameTimer {
    if ([self.usernameTimer isValid]) {
        [self.usernameTimer invalidate];
    }

    self.usernameTimer = nil;
}

- (void)usernameTimerFired {
    // Check for emoji and error
    if ([[self.usernameTF.text substringFromIndex:1] stringContainsEmoji]) {
        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
        return;
    }

    if (self.usernameTF.isEditing && (![[self.usernameTF.text substringFromIndex:1] stringContainsEmoji])) {
        if ((![[self.usernameTF.text substringFromIndex:1] isEqualToString:@""])) {
            [[FRSUserManager sharedInstance] checkUsername:[self.usernameTF.text substringFromIndex:1]
                                                completion:^(id responseObject, NSError *error) {
                                                  //Return if no internet
                                                  if (error) {
                                                      if (error.code == -1009) {
                                                          return;
                                                      }
                                                      [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
                                                      self.usernameTaken = YES;
                                                      [self stopUsernameTimer];
                                                      [self checkCreateAccountButtonState];
                                                  } else {
                                                      BOOL available = [responseObject[@"available"] boolValue];
                                                      if (available) {
                                                          [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:YES];
                                                          self.usernameTaken = NO;
                                                          [self stopUsernameTimer];
                                                          [self checkCreateAccountButtonState];
                                                      } else {
                                                          [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
                                                          self.usernameTaken = YES;
                                                          [self stopUsernameTimer];
                                                          [self checkCreateAccountButtonState];
                                                      }
                                                  }
                                                }];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.emailTF) {
        if (self.emailError) {
            [self shouldShowEmailDialogue:NO];
        }
    }

    if (textField == self.usernameTF) {
        if ([string containsString:@" "]) {
            return NO;
        }

        if (textField.text.length == 1 && [string isEqualToString:@""]) { //When detect backspace when have one character.
            return NO;
        }
    }
    return YES;
}

#pragma mark Action Logic

- (void)handleToggleSwitched:(UISwitch *)toggle {
    [self checkLocationStatus];
    [self checkNotificationStatus];

    if (toggle.on) {

        if (!self.notificationsEnabled || !self.locationEnabled) {

            FRSPermissionAlertView *alert = [[FRSPermissionAlertView alloc] initPermissionsAlert];
            alert.locationManager.delegate = self;
            [alert show];
        }

        self.notificationsEnabled = YES;
        self.scrollView.scrollEnabled = YES;
        [self.promoTF resignFirstResponder];
        [self.usernameTF resignFirstResponder];
        [self.passwordTF resignFirstResponder];
        [self.usernameTF resignFirstResponder];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [UIView animateWithDuration:0.3
                           animations:^{
                             [self.radiusSlider setValue:0.6 animated:YES];
                             [self sliderValueChanged:self.radiusSlider];
                           }];
          [[NSUserDefaults standardUserDefaults] setValue:@30 forKey:settingsUserNotificationRadius];
        });

        if (IS_IPHONE_5) {
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height - 44) animated:YES];
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
        }

        if (self.emailError) {

            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 44);

            [UIView animateWithDuration:0.3
                                  delay:0.15
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.mapView.transform = CGAffineTransformMakeScale(1, 1);
                               self.mapView.alpha = 1;
                             }
                             completion:^(BOOL finished){
                             }];

            [UIView animateWithDuration:0.15
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.mapView.transform = CGAffineTransformMakeTranslation(0, 44);
                             }
                             completion:nil];

            [self.scrollView insertSubview:self.mapView belowSubview:self.assignmentsCard];
            [self.scrollView insertSubview:self.sliderContainer belowSubview:self.assignmentsCard];

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 44);
                               self.sliderContainer.alpha = 1;
                             }
                             completion:nil];

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.promoContainer.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height + 44);
                             }
                             completion:nil];

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height + 44); //+promoContainer.frame.size.height, when we add promo
                             }
                             completion:nil];

        } else {

            [self.radiusSlider setValue:0 animated:YES];
            [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:settingsUserNotificationRadius];

            //Unregister notifications
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];

            [UIView animateWithDuration:0.3
                                  delay:0.15
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.mapView.transform = CGAffineTransformMakeScale(1, 1);
                               self.mapView.alpha = 1;
                             }
                             completion:nil];

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 10);
                               self.sliderContainer.alpha = 1;
                             }
                             completion:nil];

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.promoContainer.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height);
                             }
                             completion:nil];

            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height); //+promoContainer.frame.size.height, when we add promo
                             }
                             completion:nil];
        }

    } else {

        [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];

        if (self.emailError) {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height - 44);
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          self.notificationsEnabled = NO;
        });

        self.scrollView.scrollEnabled = NO;

        [UIView animateWithDuration:0.3
            delay:0.0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
              self.mapView.transform = CGAffineTransformMakeScale(0.93, 0.93);
              self.mapView.alpha = 0;
            }
            completion:^(BOOL finished) {
              self.mapView.frame = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height);
            }];

        if (!self.emailError) {
            [UIView animateWithDuration:0.3
                                  delay:0.2
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 0);
                             }
                             completion:nil];
            [UIView animateWithDuration:0.3
                                  delay:0.2
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, 0);
                             }
                             completion:nil];
        } else {
            [UIView animateWithDuration:0.3
                                  delay:0.2
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 44);
                             }
                             completion:nil];
            [UIView animateWithDuration:0.3
                                  delay:0.2
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, 44); //+44 when we add promo
                             }
                             completion:nil];
        }

        [UIView animateWithDuration:0.3
                              delay:0.15
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height + 18));
                         }
                         completion:nil];
        [UIView animateWithDuration:0.3
                              delay:0.15
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.sliderContainer.alpha = 0;
                         }
                         completion:nil];
    }

    if ([self checkFields]) {
        [self toggleCreateAccountButtonTitleColorToState:UIControlStateHighlighted];
    }
}

- (void)createAccount {

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.miles] forKey:settingsUserNotificationRadius];

    [self dismissKeyboard];

    if (![self checkFields]) {
        return;
    }

    [self configureSpinner];
    [self startSpinner:self.loadingView onButton:self.createAccountButton];

    NSDictionary *currentInstallation = [[FRSAuthManager sharedInstance] currentInstallation];

    NSMutableDictionary *registrationDigest = [[NSMutableDictionary alloc] init];
    [registrationDigest setObject:self.currentSocialDigest forKey:@"social_links"];

    if (currentInstallation && [currentInstallation objectForKey:@"device_token"]) {
        [registrationDigest setObject:[[FRSAuthManager sharedInstance] currentInstallation] forKey:@"installation"];
    }

    [registrationDigest setObject:[self.usernameTF.text substringFromIndex:1] forKey:@"username"];
    [registrationDigest setObject:self.passwordTF.text forKey:@"password"];
    [registrationDigest setObject:self.emailTF.text forKey:@"email"];
    [registrationDigest setObject:@(self.miles) forKey:@"radius"];

    [[FRSAuthManager sharedInstance] registerWithUserDigestion:registrationDigest
                                                    completion:^(id responseObject, NSError *error) {
                                                      if (error) {
                                                          [registrationDigest setObject:error.localizedDescription forKey:@"error"];
                                                          [FRSTracker track:registrationError parameters:@{ @"error" : registrationDigest }];

                                                          [Answers logSignUpWithMethod:@"Email"
                                                                               success:@NO
                                                                      customAttributes:@{ @"twitter" : @((self.twitterSession != Nil)),
                                                                                          @"facebook" : @((self.facebookToken != Nil)) }];

                                                          NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                          NSInteger responseCode = response.statusCode;

                                                          if (responseCode == 412) {
                                                              NSString *ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                              NSError *jsonError;

                                                              NSDictionary *jsonErrorResponse = [NSJSONSerialization JSONObjectWithData:[ErrorResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
                                                              NSString *errorMessage = jsonErrorResponse[@"error"][@"msg"];

                                                              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                                                              [alert show];

                                                          } else if (error.code == -1009) {
                                                              FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionBannerWithBackButton:YES];
                                                              [alert show];
                                                          } else {
                                                              [self presentGenericError];
                                                          }
                                                      } else {
                                                          [Answers logSignUpWithMethod:@"Email"
                                                                               success:@YES
                                                                      customAttributes:@{ @"twitter" : @((self.twitterSession != Nil)),
                                                                                          @"facebook" : @((self.facebookToken != Nil)) }];

                                                          _isAlreadyRegistered = TRUE;
                                                          [self segueToSetup];
                                                      }

                                                      [self stopSpinner:self.loadingView onButton:self.createAccountButton];
                                                    }];
}

- (void)checkEmail {
    [[FRSUserManager sharedInstance] checkEmail:self.emailTF.text
                                     completion:^(id responseObject, NSError *error) {
                                       if (error) {
                                           if (error.code == -1009) {
                                               return;
                                           }
                                           self.emailTaken = NO;
                                           [self shouldShowEmailDialogue:NO];

                                       } else {
                                           BOOL available = [responseObject[@"available"] boolValue];
                                           if (available) { //
                                               self.emailTaken = NO;
                                               [self shouldShowEmailDialogue:NO];
                                           } else {
                                               self.emailTaken = YES;
                                               [self shouldShowEmailDialogue:YES];
                                               [self presentInvalidEmail];
                                           }
                                       }

                                       [self checkCreateAccountButtonState];
                                     }];
}

- (BOOL)checkFields {
    if (self.usernameTF.text.length <= 1 || ![[self.usernameTF.text substringFromIndex:1] isValidUsername]) {
        return FALSE;
    }

    if (self.passwordTF.text.length < 5) {
        return FALSE;
    }

    if (self.emailTF.text.length == 0 || ![self.emailTF.text isValidEmail]) {
        return FALSE;
    }

    if (!self.TOSAccepted) {
        return FALSE;
    }

    return TRUE;
}

- (void)twitterTapped {

    if (_twitterSession) {
        _twitterSession = Nil;
        [_twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];

        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:twitterHandle];
        return;
    }

    //Create Spinner for async. operation
    [self setSpinnerStateOnView:self.twitterButton shouldShow:YES];

    [FRSSocial registerWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token, NSDictionary *user) {
      [self setSpinnerStateOnView:self.twitterButton shouldShow:NO];

      if (session && !error) {
          [_twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateNormal];
          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:twitterConnected];
          [[NSUserDefaults standardUserDefaults] setValue:session.userName forKey:twitterHandle];
          //self.setupProfileVC.nameStr = session
          TWTRAPIClient *apiClient = [[TWTRAPIClient alloc] initWithUserID:[session userID]];
          _twitterSession = session;

          [apiClient loadUserWithID:[session userID]
                         completion:^(TWTRUser *_Nullable user, NSError *_Nullable error) {
                           if (user.name) {
                               self.setupProfileVC.nameStr = user.name;
                           }
                         }];
      } else {
          [_twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];

          if (error.code == -1009) {
              [self setSpinnerStateOnView:self.twitterButton shouldShow:NO];
              return;
          }

          FRSAlertView *alert = [[FRSAlertView alloc]
                 initWithTitle:@"COULDN’T LOG IN"
                       message:@"We couldn’t verify your Twitter account. Please try signing in with your email and password."
                   actionTitle:@"OK"
                   cancelTitle:@""
              cancelTitleColor:nil
                      delegate:nil];
          [alert show];
      }
    }];
}

- (void)facebookTapped {

    //If we have the token already, clear it and reset the image
    if (_facebookToken) {
        _facebookToken = Nil;

        [_facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];

        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:facebookName];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];

        return;
    }

    //Create Spinner for async. operation
    [self setSpinnerStateOnView:self.facebookButton shouldShow:YES];

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];

    [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                 fromViewController:self.inputViewController
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                              if (!error && result && result.token) {
                                  //Save token to controller state
                                  _facebookToken = result.token;

                                  //Make request for facebook user's profile meta
                                  [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"picture.width(300).height(300), name, email" }] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                    if (!error) {
                                        [[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"name"] forKey:facebookName];
                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:facebookConnected];

                                        if (result[@"email"]) {
                                            self.emailTF.text = result[@"email"];
                                            [self checkEmail];
                                        }

                                        if (result[@"name"]) {
                                            self.setupProfileVC.nameStr = result[@"name"];
                                        }

                                        //TODO set avatar URL
                                        if (result[@"picture"][@"data"][@"url"]) {
                                            // self.setupProfileVC.fbPhotoURL = result[@"picture"][@"data"][@"url"];
                                        }
                                    }

                                    if (error.code == -1009) {
                                        FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionBannerWithBackButton:YES];
                                        [alert show];
                                        return;
                                    }

                                    [self.facebookButton setImage:[UIImage imageNamed:@"social-facebook"]
                                                         forState:UIControlStateNormal];
                                    [self setSpinnerStateOnView:self.facebookButton shouldShow:NO];
                                  }];
                              } else {
                                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];
                                  [self setSpinnerStateOnView:self.facebookButton shouldShow:NO];
                              }
                            }];
}

/**
 Creates or removes a spinner on the passed button

 @param button button to act on
 @param show whether to show or hide
 */
- (void)setSpinnerStateOnView:(UIButton *)button shouldShow:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (show) {
          //Create Spinner
          button.hidden = true;
          button.enabled = false;
          DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
          spinner.tintColor = [UIColor frescoOrangeColor];
          [spinner setPullProgress:90];
          [spinner startAnimating];
          [spinner setFrame:CGRectMake(
                                button.imageView.frame.origin.x,
                                button.imageView.frame.origin.y,
                                button.imageView.frame.size.width,
                                button.imageView.frame.size.height)];
          [button.superview addSubview:spinner];
      } else {
          for (UIView *i in button.superview.subviews) {
              if ([i isKindOfClass:[DGElasticPullToRefreshLoadingViewCircle class]]) {
                  [(DGElasticPullToRefreshLoadingView *)i stopLoading];
                  [(DGElasticPullToRefreshLoadingView *)i removeFromSuperview];
              }
          }
          button.enabled = true;
          button.hidden = false;
      }
    });
}

#pragma mark - Spinner

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

- (void)pushViewControllerWithCompletion:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self.navigationController pushViewController:viewController animated:animated];
    [CATransaction commit];
}

- (void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {

    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 - 16, button.frame.size.height / 2 - 10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

- (void)stopSpinner:(DGElasticPullToRefreshLoadingView *)spinner onButton:(UIButton *)button {

    [button setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [spinner stopLoading];
    [spinner removeFromSuperview];
}

#pragma mark - Keyboard

- (void)handleKeyboardWillShow:(NSNotification *)sender {
    self.scrollView.scrollEnabled = YES;
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    CGPoint point = self.scrollView.contentOffset;
    [UIView animateWithDuration:0.15
                     animations:^{
                       [self.scrollView setContentOffset:point animated:NO];
                     }];

    if (self.promoTF.isFirstResponder) {
        if (self.notificationsEnabled) {

            self.scrollView.frame = CGRectMake(0, -keyboardSize.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);

            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];

        } else {

            if (self.emailError) {
                if (IS_IPHONE_6) {
                    self.scrollView.frame = CGRectMake(0, -36 - 44, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                } else if (IS_IPHONE_6_PLUS) {

                } else if (IS_IPHONE_5) {
                    self.scrollView.frame = CGRectMake(0, -144 - 44, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                }
            } else {
                if (IS_IPHONE_6) {
                    self.scrollView.frame = CGRectMake(0, -36, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                } else if (IS_IPHONE_6_PLUS) {

                } else if (IS_IPHONE_5) {
                    self.scrollView.frame = CGRectMake(0, -144, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                }
            }
        }
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)handleKeyboardWillHide:(NSNotification *)sender {

    if (self.notificationsEnabled) {
        self.scrollView.scrollEnabled = YES;
    } else {
        if (self.scrollView.contentOffset.y != 0) {
            [self.scrollView setContentOffset:CGPointZero animated:YES];
        }

        self.scrollView.scrollEnabled = NO;
    }

    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, 0);

    if (self.scrollView.frame.size.height < self.view.frame.size.height - 108) {
        [UIView animateWithDuration:0.15
                         animations:^{
                           self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height - 44);
                         }];
    }

    if (self.promoTF.isFirstResponder) {
        self.scrollView.frame = CGRectMake(0, self.yPos, self.view.frame.size.width, self.height);
    }

    if (!self.notificationsEnabled) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)highlightTextField:(UITextField *)textField enabled:(BOOL)enabled {

    if (!enabled) {
        [UIView animateWithDuration:.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
                           self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:nil];

        return;

    } else {
        [UIView animateWithDuration:.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.usernameHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
                           self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 2);
                         }
                         completion:nil];
    }
}

#pragma mark - Error Handling

- (void)presentInvalidEmail {

    if (self.errorContainer.alpha == 0) {
        self.errorContainer = [[UIView alloc] initWithFrame:CGRectMake(16, 192, 192, 20)];
        [self.scrollView addSubview:self.errorContainer];

        UILabel *invalidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 192, 20)];
        invalidLabel.text = @"Email is taken.";
        invalidLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        invalidLabel.textColor = [UIColor frescoRedColor];
        [self.errorContainer addSubview:invalidLabel];

        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [loginButton addTarget:self action:@selector(segueToLogin) forControlEvents:UIControlEventTouchUpInside];
        loginButton.frame = CGRectMake(90, 0, 100, 20);
        loginButton.tintColor = [UIColor frescoRedColor];
        [loginButton setTitle:@"Tap to log in" forState:UIControlStateNormal];
        [loginButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
        [self.errorContainer addSubview:loginButton];

        [self shouldShowEmailDialogue:YES];
    }
}

- (void)shouldShowEmailDialogue:(BOOL)yes {
    if (yes) {
        self.emailError = YES;

        self.errorContainer.alpha = 1;

        NSArray *views = [self.scrollView subviews];

        NSLog(@"%lu", (unsigned long)[views count]);

        if (self.notificationsEnabled) {

            //            for(UIView *subview in vi)

            self.assignmentsCard.transform = CGAffineTransformMakeTranslation(0, 44);
            self.mapView.transform = CGAffineTransformMakeTranslation(0, 44);
            self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 44);
            //self.promoContainer.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height + self.sliderContainer.frame.size.height);
            //self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height + self.sliderContainer.frame.size.height);
            NSLog(@"TOSContainer View Y %f", self.TOSContainerView.frame.origin.y);
            self.TOSContainerView.frame = CGRectMake(self.TOSContainerView.frame.origin.x, 658, self.TOSContainerView.frame.size.width, self.TOSContainerView.frame.size.height);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 44);

        } else {
            self.assignmentsCard.transform = CGAffineTransformMakeTranslation(0, 44);
            self.mapView.transform = CGAffineTransformMakeTranslation(0, 44);
            //self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 44);
            self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, 44);
        }

    } else {
        self.emailError = NO;

        self.errorContainer.alpha = 0;

        self.assignmentsCard.transform = CGAffineTransformMakeTranslation(0, 0);
        self.mapView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 0);

        if (self.notificationsEnabled) {
            self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height + self.sliderContainer.frame.size.height);
        } else {
            self.TOSContainerView.transform = CGAffineTransformMakeTranslation(0, 0);
        }
    }
}

- (void)segueToSetup {
    [[FRSUserManager sharedInstance] reloadUser];

    [self.navigationController pushViewController:self.setupProfileVC animated:YES];
    id<FRSAppDelegate> delegate = (id<FRSAppDelegate>)[[UIApplication sharedApplication] delegate];
    [delegate registerForPushNotifications];
}

- (void)segueToLogin {
    [self dismissKeyboard];
    FRSLoginViewController *loginVC = [[FRSLoginViewController alloc] init];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView.scrollEnabled) {
        if (self.emailTF.isEditing || self.passwordTF.isEditing || self.usernameTF.isEditing || self.promoTF.isEditing) {
            [self dismissKeyboard];
        }
    }
}

#pragma mark - Notification Status

- (void)checkNotificationStatus {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];

        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            self.notificationsEnabled = YES;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:settingsUserNotificationToggle];
        } else {
            self.notificationsEnabled = NO;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:settingsUserNotificationToggle];
        }
    }
}

#pragma mark - Location Status

- (void)checkLocationStatus {
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:locationEnabled];
        self.locationEnabled = YES;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:locationEnabled];
        self.locationEnabled = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
}

#pragma mark - FRSAlertViewDelegate

- (void)didPressButton:(FRSAlertView *)alertView atIndex:(NSInteger)index {
    if (index == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.passwordTF];
}


@end
