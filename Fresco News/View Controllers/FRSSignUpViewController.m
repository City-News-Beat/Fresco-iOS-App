//
//  FRSSignUpViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSignUpViewController.h"

//View Controllers
#import "FRSSetupProfileViewController.h" // !HELPFUL, LOOP BACK
#import "FRSLoginViewController.h"

//Helpers
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

//UI
#import "FRSAlertView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import <QuartzCore/QuartzCore.h>


@import MapKit;

@interface FRSSignUpViewController () <UITextFieldDelegate, MKMapViewDelegate, UIScrollViewDelegate, FRSAlertViewDelegate>

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

@end

@implementation FRSSignUpViewController
@synthesize twitterSession = _twitterSession, facebookToken = _facebookToken, facebookButton = _facebookButton, twitterButton = _twitterButton, currentSocialDigest = _currentSocialDigest;

-(void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    
    
    [self addNotifications];
    
    self.notificationsEnabled = NO;
    self.emailError = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(NSDictionary *)currentSocialDigest {
    return [[FRSAPIClient sharedClient] socialDigestionWithTwitter:_twitterSession facebook:_facebookToken];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_hasShown) {
//        [self.usernameTF becomeFirstResponder];
    }
    _hasShown = TRUE;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    
    self.navigationItem.title = @"SIGN UP";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
          @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem animated:animated];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToPreviousViewController) name:@"returnToPreviousViewController" object:nil];
}

-(void)back {
    BOOL shouldGoBack = NO;
    
    if ((![self.passwordTF.text isEqualToString:@""]) || (![self.emailTF.text isEqualToString:@""]) || ([self.usernameTF.text length] > 1)) {
        
        [self.passwordTF resignFirstResponder];
        [self.emailTF resignFirstResponder];
        [self.usernameTF resignFirstResponder];
        [self.promoTF resignFirstResponder];
        
        self.alert = [[FRSAlertView alloc] initSignUpAlert];
        
        [self.alert show];
    } else {
        shouldGoBack = YES;
    }

    if (shouldGoBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)returnToPreviousViewController {
    [self.alert dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)addNotifications {
    
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

-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    [self configureScrollView];
    [self configureTextFields];
    [self configureNotificationSection];
    [self configureMapView];
    [self configureSliderSection];
    [self configurePromoSection];
    [self adjustScrollViewContentSize];
    [self configureBottomBar];
}

-(void)configureScrollView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.height = self.view.frame.size.height -44;
    self.yPos = 64;
    
    if ([self.navigationController.viewControllers indexOfObject:self] == 2) {
        self.height = self.view.frame.size.height -44 -52 -12;
        self.yPos = 0;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.yPos, self.view.frame.size.width, self.height)];
    
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = NO;
    
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.scrollView];
    
    if (IS_IPHONE_6) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.frame.size.height + self.promoTF.frame.size.height + self.promoDescription.frame.size.height +24);
    } else if (IS_IPHONE_6_PLUS) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.frame.size.height + self.promoTF.frame.size.height + self.promoDescription.frame.size.height -12);
    } else if (IS_IPHONE_5) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.frame.size.height + self.promoTF.frame.size.height + self.promoDescription.frame.size.height +84);
    }
}

-(void)configureTextFields {
    [self configureUserNameField];
    [self configureEmailAddressField];
    [self configurePasswordField];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}


-(void)configureUserNameField {
    self.usernameTF = [[UITextField alloc] initWithFrame:CGRectMake(48, 24, self.scrollView.frame.size.width - 2 * 48, 44)];
    self.usernameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"@username" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont notaMediumWithSize:17]}];
    self.usernameTF.delegate = self;
    self.usernameTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTF.textColor = [UIColor frescoDarkTextColor];
    self.usernameTF.font = [UIFont notaMediumWithSize:17];
    self.usernameTF.tintColor = [UIColor frescoOrangeColor];
    self.usernameTF.returnKeyType = UIReturnKeyNext;
    [self.scrollView addSubview:self.usernameTF];
    
    self.usernameHighlightLine = [[UIView alloc] initWithFrame:CGRectMake(48, 92-64+44, self.usernameTF.frame.size.width, 0.5)];
    self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
    [self.scrollView addSubview:self.usernameHighlightLine];
    
    self.usernameCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-green"]];
    self.usernameCheckIV.frame = CGRectMake(self.usernameTF.frame.size.width - 24, 10, 24, 24);
    self.usernameCheckIV.alpha = 0;
    [self.usernameTF addSubview:self.usernameCheckIV];
}

-(void)configureEmailAddressField {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.emailTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email address" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
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

-(void)configurePasswordField {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 136, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    self.passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
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

-(void)configureNotificationSection {
    self.assignmentsCard = [[UIView alloc] initWithFrame:CGRectMake(0, 192, self.scrollView.frame.size.width, 62)];
    self.assignmentsCard.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.assignmentsCard];
    
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

-(void)configureMapView {
    
    NSInteger height = 240;
    if (IS_STANDARD_IPHONE_6) height = 280;
    if (IS_STANDARD_IPHONE_6_PLUS) height = 310;
    
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
}

-(void)configureSliderSection {
    
    self.sliderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.origin.y + self.mapView.frame.size.height, self.scrollView.frame.size.width, 56)];
    self.sliderContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.sliderContainer];
    
    [self.sliderContainer addSubview:[UIView lineAtPoint:CGPointMake(0, 0)]];
    [self.sliderContainer addSubview:[UIView lineAtPoint:CGPointMake(0, self.sliderContainer.frame.size.height)]];
    
    self.radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.view.frame.size.width - 104, 28)];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [self.radiusSlider setMaximumTrackTintColor:[UIColor colorWithWhite:181/255.0 alpha:1.0]];
    [self.sliderContainer addSubview:self.radiusSlider];

    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [self.self.sliderContainer addSubview:smallIV];
    
    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [self.sliderContainer addSubview:bigIV];
    
    self.y += self.sliderContainer.frame.size.height + 12;
    
    self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
    self.sliderContainer.alpha = 0;
}

-(void)configurePromoSection {
    
    self.promoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.assignmentsCard.frame.origin.y + self.assignmentsCard.frame.size.height +12, self.scrollView.frame.size.width, 44)];
    self.promoContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.promoContainer];
    
    [self.promoContainer addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.promoTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.promoTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Promo" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.promoTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.promoTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.promoTF.tintColor = [UIColor frescoOrangeColor];
    self.promoTF.delegate = self;
    self.promoTF.font = [UIFont systemFontOfSize:15];
    self.promoTF.returnKeyType = UIReturnKeyGo;
    [self.promoContainer addSubview:self.promoTF];
    [self.promoContainer addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y += self.promoContainer.frame.size.height + 12;
    
    self.promoDescription = [[UILabel alloc] initWithFrame:CGRectMake(16, self.promoContainer.frame.size.height +12, self.scrollView.frame.size.width - 2 * 16, 28)];
    self.promoDescription.numberOfLines = 0;
    self.promoDescription.text = @"If you use a friend’s promo code, you’ll get $20 when you respond to an assignment for the first time.";
    self.promoDescription.font = [UIFont systemFontOfSize:12];
    self.promoDescription.textColor = [UIColor frescoMediumTextColor];
    [self.promoDescription sizeToFit];
    [self.promoContainer addSubview:self.promoDescription];
    
    self.y += self.promoDescription.frame.size.height + 24;
    
//    self.promoContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
//    self.promoDescription.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
}

-(void)adjustScrollViewContentSize {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.y);
}

-(void)configureBottomBar {
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height -44 -64, self.view.frame.size.width, 44)];
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
    
    
    [self constrainSubview:self.bottomBar ToBottomOfParentView:self.view WithHeight:44];

}

-(void)constrainSubview:(UIView *)subView ToBottomOfParentView:(UIView *)parentView WithHeight:(CGFloat)height {
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Trailing
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parentView
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1
                                   constant:0];
    
    //Leading
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parentView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1
                                   constant:0];
    
    //Bottom
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:parentView
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1
                                  constant:0];
    
    //Height
    NSLayoutConstraint *constantHeight = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:0
                                  multiplier:0
                                  constant:height];
    
    [parentView addConstraint:trailing];
    [parentView addConstraint:bottom];
    [parentView addConstraint:leading];
    
    [subView addConstraint:constantHeight];
}



-(void)toggleCreateAccountButtonTitleColorToState:(UIControlState )controlState {
    if (controlState == UIControlStateNormal){
        [self.createAccountButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.createAccountButton.enabled = NO;
    }
    else {
        [self.createAccountButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.createAccountButton setTitleColor:[[UIColor frescoBlueColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        self.createAccountButton.enabled = YES;
    }
    
}


-(void)addSocialButtonsToBottomBar {
    _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 1, 24 + 18, 24 + 18)];
    [_facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [_facebookButton setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateHighlighted];
    [_facebookButton setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateSelected];
    [_facebookButton addTarget:self action:@selector(facebookTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:_facebookButton];
    
    _twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(_facebookButton.frame.origin.x + _facebookButton.frame.size.width, 1, 24 + 18, 24 + 18)];
    [_twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
    [_twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateHighlighted];
    [_twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateSelected];
    [_twitterButton addTarget:self action:@selector(twitterTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:_twitterButton];
}

-(void)animateTextFieldError:(UITextField *)textField {
    
    CGFloat duration = 0.1;
    
    /* SHAKE */
    
    [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        textField.transform = CGAffineTransformMakeTranslation(-7.5, 0);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            
            textField.transform = CGAffineTransformMakeTranslation(5, 0);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                
                textField.transform = CGAffineTransformMakeTranslation(-2.5, 0);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    textField.transform = CGAffineTransformMakeTranslation(2.5, 0);
                    
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                        
                        textField.transform = CGAffineTransformMakeTranslation(0, 0);
                        
                    } completion:nil];
                }];
            }];
        }];
    }];
}

-(void)animateUsernameCheckImageView:(UIImageView *)imageView animateIn:(BOOL)animateIn success:(BOOL)success {
    
    if(success) {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-green"];
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
    }
    
    if (animateIn) {
        if (self.usernameCheckIV.alpha == 0) {
            
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.usernameCheckIV.alpha = 0;
          
//            [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
              self.usernameCheckIV.alpha = 1;
//            } completion:nil];
          
//            [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
              self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.05, 1.05);
              
//            } completion:^(BOOL finished) {
//                [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                  self.usernameCheckIV.transform = CGAffineTransformMakeScale(1, 1);
//                } completion:nil];
//            }];
      }
  } else {
      
//        [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
          self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.1, 1.1);
          
//        } completion:^(BOOL finished) {
//          [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
              self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
//            } completion:nil];
//        }];
      
//        [UIView animateWithDuration:0.2 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
          self.usernameCheckIV.alpha = 0;
//        } completion:nil];
    }
}

#pragma mark - TextField Delegate

-(void)textFieldDidChange {
    
    if ((self.emailTF.isEditing) && ([self isValidEmail:self.emailTF.text])) {
        [self checkEmail];
    }
    
    if (self.usernameTF.isEditing) {
        [self startUsernameTimer];
        
        if ([[self.usernameTF.text substringFromIndex:1] isEqualToString:@""]){
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:NO success:NO];
        }
    }
    
    [self checkCreateAccountButtonState];
}

-(void)checkCreateAccountButtonState {
    UIControlState controlState;
    
    if (([self.usernameTF.text length] > 0) && ([self.emailTF.text length] > 0) && ([self.passwordTF.text length] >0)) {
        
        if ([self isValidUsername:[self.usernameTF.text substringFromIndex:1]] && [self isValidEmail:self.emailTF.text] && [self isValidPassword:self.passwordTF.text] && (!self.emailTaken) && (!self.usernameTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
}


-(void)dismissKeyboard {
    [self highlightTextField:nil enabled:NO];
    
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {

    if (textField == self.usernameTF) {
        if (![self isValidUsername:[self.usernameTF.text substringFromIndex:1]] || [textField.text isEqualToString:@"@"]){
            [self animateTextFieldError:self.usernameTF];
            [textField becomeFirstResponder];
            self.usernameCheckIV.alpha = 0;
            return FALSE;
        }
        [self.emailTF becomeFirstResponder];
    } else if (textField == self.emailTF) {
        if (![self isValidEmail:textField.text] || [self.emailTF.text isEqualToString:@""]) {
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


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.usernameTF) {
        
        [self startUsernameTimer];
        
        [self highlightTextField:self.usernameTF enabled:YES];
        if ([self.usernameTF.text isEqualToString:@""]){
            self.usernameTF.text = @"@";
        }
    }

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([self.usernameTF.text length] == 0) {
        return;
    }
    
    if (textField == self.usernameTF) {
        
        [self usernameTimerFired];
        [self stopUsernameTimer];
        
        [self highlightTextField:self.usernameTF enabled:NO];
        
        if (![self isValidUsername:[self.usernameTF.text substringFromIndex:1]]){
            [self animateTextFieldError:self.usernameTF];
            [textField becomeFirstResponder];
            return;
        }

        if ([self.usernameTF.text isEqualToString:@"@"]){
            self.usernameTF.text = @"";
            return;
        }
    }
    
//    UIControlState controlState;
//
//    if ([self isValidUsername:[self.usernameTF.text substringFromIndex:1]] && [self isValidEmail:self.emailTF.text] && [self isValidPassword:self.passwordTF.text] && (!self.emailTaken) && (!self.usernameTaken)) {
//        controlState = UIControlStateHighlighted;
//    } else {
//        controlState = UIControlStateNormal;
//    }
//    
//    [self toggleCreateAccountButtonTitleColorToState:controlState];
}


-(void)startUsernameTimer {
    if (!self.usernameTimer) {
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(usernameTimerFired) userInfo:nil repeats:YES];
    }
}

-(void)stopUsernameTimer {
    if ([self.usernameTimer isValid]) {
        [self.usernameTimer invalidate];
    }
    
    self.usernameTimer = nil;
}

-(void)usernameTimerFired {
    
    if (self.usernameTF.isEditing) {
        
        if ((![[self.usernameTF.text substringFromIndex:1] isEqualToString:@""])) {
            
            [[FRSAPIClient sharedClient] checkUsername:[self.usernameTF.text substringFromIndex:1] completion:^(id responseObject, NSError *error) {

                if ([error.userInfo[@"NSLocalizedDescription"][@"msg"] isEqualToString:@"No user found"]) {
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
            }];
        }
    }
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.emailTF) {
        if (self.emailError) {
            [self shouldShowEmailDialogue:NO];
        }
    }
    
    if (textField == self.usernameTF) {
        
        if ([string containsString:@" "]) {
            return FALSE;
        }
        
        if (textField.text.length == 1 && [string isEqualToString:@""]) {//When detect backspace when have one character.
            return NO;
        }
    }
    return YES;
}



#pragma mark Action Logic 

-(void)handleToggleSwitched:(UISwitch *)toggle {
    id<FRSAppDelegate> delegate = (id<FRSAppDelegate>)[[UIApplication sharedApplication] delegate];
    [delegate registerForPushNotifications];
    
    if (toggle.on){
        
        
        self.notificationsEnabled = YES;
        self.scrollView.scrollEnabled = YES;
        [self.promoTF resignFirstResponder];
        [self.usernameTF resignFirstResponder];
        [self.passwordTF resignFirstResponder];
        [self.usernameTF resignFirstResponder];

        if (IS_IPHONE_5) {
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height -44) animated:YES];
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
        }

        
        if (self.emailError) {
            
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height +44);
            
            [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.mapView.transform = CGAffineTransformMakeScale(1, 1);
                self.mapView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
            
            [UIView animateWithDuration:0.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.mapView.transform = CGAffineTransformMakeTranslation(0, 44);
            } completion:nil];
            
            [self.scrollView insertSubview:self.mapView belowSubview:self.assignmentsCard];
            [self.scrollView insertSubview:self.sliderContainer belowSubview:self.assignmentsCard];
            
            [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 44);
                self.sliderContainer.alpha = 1;
            } completion:nil];
            
            [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.promoContainer.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height +self.sliderContainer.frame.size.height +44);
            } completion:nil];
            
        } else {
            
            
            [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.mapView.transform = CGAffineTransformMakeScale(1, 1);
                self.mapView.alpha = 1;
            } completion:nil];
            
            [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 0);
                self.sliderContainer.alpha = 1;
            } completion:nil];
            
            [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.promoContainer.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height +self.sliderContainer.frame.size.height);
            } completion:nil];
        }
        

        

        
    } else {
        
        [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
        
        if (self.emailError) {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height -44);
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.notificationsEnabled = NO;
        });
        
        self.scrollView.scrollEnabled = NO;
        
        
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.mapView.transform = CGAffineTransformMakeScale(0.93, 0.93);
            self.mapView.alpha = 0;
        } completion:^(BOOL finished) {
            self.mapView.frame = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height);
        }];
        
        
        if (!self.emailError) {
            [UIView animateWithDuration:0.3 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:nil];
        } else {
            [UIView animateWithDuration:0.3 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 44);
            } completion:nil];
        }
        
        [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
        } completion:nil];
        [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderContainer.alpha = 0;
        } completion:nil];
    }
}

-(void)createAccount {

    [self dismissKeyboard];
    
    if (_isAlreadyRegistered) {
        [self segueToSetup];
        return;
    }
    
    if (![self checkFields]) {
        return;
    }
    
    [self configureSpinner];
    [self startSpinner:self.loadingView onButton:self.createAccountButton];
    
    NSDictionary *currentInstallation = [[FRSAPIClient sharedClient] currentInstallation];

    NSMutableDictionary *registrationDigest = [[NSMutableDictionary alloc] init];
    [registrationDigest setObject:self.currentSocialDigest forKey:@"social_links"];
    
    if (currentInstallation) {
        [registrationDigest setObject:[[FRSAPIClient sharedClient] currentInstallation] forKey:@"installation"];
    }
    
    [registrationDigest setObject:[self.usernameTF.text substringFromIndex:1] forKey:@"username"];
    [registrationDigest setObject:self.passwordTF.text forKey:@"password"];
    [registrationDigest setObject:self.emailTF.text forKey:@"email"];

    if (_isAlreadyRegistered) {
        
        if (![_pastRegistration[@"email"] isEqualToString:self.emailTF.text]) {

        }
        
        [[FRSAPIClient sharedClient] updateUserWithDigestion:registrationDigest completion:^(id responseObject, NSError *error) {
            if (error) {
                // show error
            }
            else {
                // continue on whatever
            }
        }];
        
        return;
    }
    
    [[FRSAPIClient sharedClient] registerWithUserDigestion:registrationDigest completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", error, responseObject);
        
        NSString *errorMessage = [[error userInfo] objectForKey:@"Content-Length"];
        NSLog(@"%@", errorMessage);
        
        
        if (error.code == 0) {
            _isAlreadyRegistered = TRUE;
            [self segueToSetup];
            //check dictionary
        }
        _pastRegistration = registrationDigest;
        
        [self stopSpinner:self.loadingView onButton:self.createAccountButton];
        
    }];
}

-(void)checkEmail {

    [[FRSAPIClient sharedClient] checkEmail:self.emailTF.text completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            self.emailTaken = YES;
            [self shouldShowEmailDialogue:YES];
            [self presentInvalidEmail];
        } else {
            self.emailTaken = NO;
            [self shouldShowEmailDialogue:NO];
        }
        
        [self checkCreateAccountButtonState];
    }];
}

-(BOOL)checkFields {
    if (self.usernameTF.text.length <= 1 || ![self isValidUsername:[self.usernameTF.text substringFromIndex:1]]) {
        return FALSE;
    }
    
    if (self.passwordTF.text.length < 5) {
        return FALSE;
    }
    
    if (self.emailTF.text.length == 0 || ![self isValidEmail:self.emailTF.text]) {
        return FALSE;
    }
    
    return TRUE;
}

-(void)twitterTapped {
    
    if (_twitterSession) {
        _twitterSession = Nil;
        [UIView animateWithDuration:.2 animations:^{
            [_twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
        }];
        return;
    }
    
    _twitterButton.enabled = FALSE; // prevent double tapping
    
    [FRSSocial registerWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
        _twitterButton.enabled = TRUE;
        
        if (error) {
            [self handleSocialChallenge:error];
            return;
        }
        
        [UIView animateWithDuration:.2 animations:^{
            [_twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateNormal];
        }];
        
        _twitterSession = session;
    }];
}

-(void)facebookTapped {
    
    if (_facebookToken) {
        _facebookToken = Nil;
        [UIView animateWithDuration:.2 animations:^{
            [_facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
        }];
        
        return;
    }
    
    _facebookButton.enabled = FALSE; // prevent double tapping
    
    [FRSSocial registerWithFacebook:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
        _facebookButton.enabled = TRUE;
        
        if (error) {
            [self handleSocialChallenge:error];
            return;
        }
        
        [UIView animateWithDuration:.2 animations:^{
            [_facebookButton setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateNormal];
        }];
        
        _facebookToken = token;
        
    } parent:self]; // presenting view controller for safari view login
}

-(void)handleSocialChallenge:(NSError *)error {
    
}


#pragma mark - Spinner

-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

-(void)pushViewControllerWithCompletion:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    [self.navigationController pushViewController:viewController animated:animated];
    [CATransaction commit];
}

-(void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 -16, button.frame.size.height/2 -10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

-(void)stopSpinner:(DGElasticPullToRefreshLoadingView *)spinner onButton:(UIButton *)button {
    
    [button setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [spinner stopLoading];
    [spinner removeFromSuperview];
}

#pragma mark - Keyboard

-(void)handleKeyboardWillShow:(NSNotification *)sender {
    
    self.scrollView.scrollEnabled = YES;
    
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);

    CGPoint point = self.scrollView.contentOffset;

    [UIView animateWithDuration:0.15 animations:^{
        [self.scrollView setContentOffset:point animated:NO];
    }];
    
    if (self.promoTF.isFirstResponder) {
        if (self.notificationsEnabled) {
            
            self.scrollView.frame = CGRectMake(0, -keyboardSize.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);

            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
            
        } else {
            
            if (self.emailError) {
                if (IS_IPHONE_6) {
                    self.scrollView.frame = CGRectMake(0, -36 -44, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                } else if (IS_IPHONE_6_PLUS) {
                    
                } else if (IS_IPHONE_5) {
                    self.scrollView.frame = CGRectMake(0, -144 -44, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
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

-(void)handleKeyboardWillHide:(NSNotification *)sender {
    
    if (self.notificationsEnabled) {
        self.scrollView.scrollEnabled = YES;
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        self.scrollView.scrollEnabled = NO;
    }
    
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, 0);
    
    if (self.scrollView.frame.size.height < self.view.frame.size.height - 108){
        [UIView animateWithDuration:0.15 animations:^{
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height - 44);
        }];
    }
    
    if (self.promoTF.isFirstResponder) {
        self.scrollView.frame = CGRectMake(0, self.yPos, self.view.frame.size.width, self.height);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)highlightTextField:(UITextField *)textField enabled:(BOOL)enabled {
    
    if (!enabled) {
        [UIView animateWithDuration:.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.backgroundColor = [UIColor frescoShadowColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];

        return;
        
    } else {
        [UIView animateWithDuration:.15 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.usernameHighlightLine.backgroundColor = [UIColor frescoOrangeColor];
            self.usernameHighlightLine.transform = CGAffineTransformMakeScale(1, 2);
        } completion:nil];
    }
}


#pragma mark - Text Field Validation

-(BOOL)isValidEmail:(NSString *)emailString {
    
    if([emailString length] == 0) {
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)isValidUsername:(NSString *)username {

    if ([username isEqualToString:@"@"]) {
        return NO;
    }
    
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validUsernameChars];
    NSCharacterSet *disallowedSet = [allowedSet invertedSet];
    if (([username rangeOfCharacterFromSet:disallowedSet].location == NSNotFound) /*&& ([username length] >= 4)*/ && (!([username length] > 20))) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)isValidPassword:(NSString *)password {
    
    if (password.length < 8) {
        return NO;
    }
    
    // check length
        // return false
    
    // check against pattern (i.e. xxXXxxx1)
        // return false
    
    return YES;
}

#pragma mark - Error Handling


-(void)presentInvalidEmail {
    
    if (self.errorContainer.alpha == 0) {
        self.errorContainer = [[UIView alloc] initWithFrame:CGRectMake(16, 192, 192, 20)];
        [self.scrollView addSubview:self.errorContainer];
        
        UILabel *invalidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 192, 20)];
        invalidLabel.text = @"Email is taken.";
        invalidLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        invalidLabel.textColor = [UIColor frescoRedHeartColor];
        [self.errorContainer addSubview:invalidLabel];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [loginButton addTarget:self action:@selector(segueToLogin) forControlEvents:UIControlEventTouchUpInside];
        loginButton.frame = CGRectMake(90, 0, 100, 20);
        loginButton.tintColor = [UIColor frescoRedHeartColor];
        [loginButton setTitle:@"Tap to log in" forState:UIControlStateNormal];
        [loginButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
        [self.errorContainer addSubview:loginButton];
        
        [self shouldShowEmailDialogue:YES];
    }
}

-(void)shouldShowEmailDialogue:(BOOL)yes {
    
    if (yes) {
        self.emailError = YES;
        
        self.errorContainer.alpha = 1;

        if (self.notificationsEnabled) {

            self.assignmentsCard.transform = CGAffineTransformMakeTranslation(0, 44);
            self.mapView.transform = CGAffineTransformMakeTranslation(0, 44);
            self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 44);
            self.promoContainer.transform = CGAffineTransformMakeTranslation(0, self.mapView.frame.size.height + self.sliderContainer.frame.size.height +self.sliderContainer.frame.size.height);
            
        } else {
            self.assignmentsCard.transform = CGAffineTransformMakeTranslation(0, 44);
            self.mapView.transform = CGAffineTransformMakeTranslation(0, 44);
            self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 44);
        }
        
    } else {
        self.emailError = NO;
        
        if (self.notificationsEnabled) {

        } else {
            self.errorContainer.alpha = 0;
            self.assignmentsCard.transform = CGAffineTransformMakeTranslation(0, 0);
            self.mapView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 0);
        }
    }
}

-(void)segueToSetup {
    FRSSetupProfileViewController *setupProfileVC = [[FRSSetupProfileViewController alloc] init];
    [self.navigationController pushViewController:setupProfileVC animated:YES];
}

-(void)segueToLogin {
    FRSLoginViewController *loginVC = [[FRSLoginViewController alloc] init];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController pushViewController:loginVC animated:YES];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView.scrollEnabled) {
        if (self.emailTF.isEditing || self.passwordTF.isEditing || self.usernameTF.isEditing || self.promoTF.isEditing) {
            [self dismissKeyboard];
        }
    }
}











@end
