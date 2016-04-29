//
//  FRSSignUpViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSignUpViewController.h"

//View Controllers
#import "FRSSetupProfileViewController.h"

//Helpers
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import "FRSDataValidator.h"

@import MapKit;


@interface FRSSignUpViewController () <UITextFieldDelegate, MKMapViewDelegate, UIScrollViewDelegate>

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

@end

@implementation FRSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    
    
    [self addNotifications];
    
    self.notificationsEnabled = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"SIGN UP";
    [self configureBackButtonAnimated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}


#pragma mark - UI 

-(void)configureUI{
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

-(void)configureScrollView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -44 -52 -12)];
    
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

-(void)configureTextFields{
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

-(void)configureEmailAddressField{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.emailTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email address" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.emailTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.emailTF.delegate = self;
    self.emailTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTF.textColor = [UIColor frescoDarkTextColor];
    self.emailTF.tintColor = [UIColor frescoOrangeColor];
    self.emailTF.font = [UIFont systemFontOfSize:15];
    self.emailTF.returnKeyType = UIReturnKeyNext;

    [backgroundView addSubview:self.emailTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
}

-(void)configurePasswordField{
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

-(void)configureNotificationSection{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 192, self.scrollView.frame.size.width, 62)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    UILabel *topLabel = [[UILabel alloc] init];
    topLabel.text = @"ASSIGNMENT NOTIFICATIONS";
    topLabel.textColor = [UIColor frescoDarkTextColor];
    topLabel.font = [UIFont notaBoldWithSize:15];
    [topLabel sizeToFit];
    [topLabel setFrame:CGRectMake(16, 15, topLabel.frame.size.width, topLabel.frame.size.height)];
    [backgroundView addSubview:topLabel];
    
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.text = @"We'll tell you about paid photo ops nearby";
    bottomLabel.textColor = [UIColor frescoMediumTextColor];
    bottomLabel.font = [UIFont systemFontOfSize:12];
    [bottomLabel sizeToFit];
    bottomLabel.frame = CGRectMake(16, 36, bottomLabel.frame.size.width, bottomLabel.frame.size.height);
    [backgroundView addSubview:bottomLabel];
    
    
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(backgroundView.frame.size.width - 51 - 12, 15.5, 51, 31)];
    toggle.on = NO;
    toggle.onTintColor = [UIColor frescoGreenColor];
    [toggle addTarget:self action:@selector(handleToggleSwitched:) forControlEvents:UIControlEventValueChanged];
    [backgroundView addSubview:toggle];
    
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 61.5)]];
    
}

-(void)configureMapView{
    
    NSInteger height = 240;
    if (IS_STANDARD_IPHONE_6) height = 280;
    if (IS_STANDARD_IPHONE_6_PLUS) height = 310;
    
    
    //Up until this point all the ui elements were static heights
    //The map height is dependent on the iPhone size now
    //We use a variable for easy tracking of the y-origin of subsequent elements
    //Eventually it will also be used to adjust the content size of the scroll view
    self.y = 254;
    
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.y, self.scrollView.frame.size.width, height)];
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

-(void)configureSliderSection{
    
    self.sliderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.scrollView.frame.size.width, 56)];
    self.sliderContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.sliderContainer];
    
    [self.sliderContainer addSubview:[UIView lineAtPoint:CGPointMake(0, 0)]];
    [self.sliderContainer addSubview:[UIView lineAtPoint:CGPointMake(0, self.sliderContainer.frame.size.height)]];
    
    self.radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.view.frame.size.width - 104, 28)];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [self.radiusSlider setMaximumTrackTintColor:[UIColor colorWithWhite:181/255.0 alpha:1.0]];
    [self.self.sliderContainer addSubview:self.radiusSlider];

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

-(void)configurePromoSection{
    
    self.promoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.scrollView.frame.size.width, 44)];
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
    
    self.promoDescription = [[UILabel alloc] initWithFrame:CGRectMake(16, self.y, self.scrollView.frame.size.width - 2 * 16, 28)];
    self.promoDescription.numberOfLines = 0;
    self.promoDescription.text = @"If you use a friend’s promo code, you’ll get $20 when you respond to an assignment for the first time.";
    self.promoDescription.font = [UIFont systemFontOfSize:12];
    self.promoDescription.textColor = [UIColor frescoMediumTextColor];
    [self.promoDescription sizeToFit];
    [self.scrollView addSubview:self.promoDescription];
    
    self.y += self.promoDescription.frame.size.height + 24;
    
    self.promoContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
    self.promoDescription.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
}

-(void)adjustScrollViewContentSize{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.y);
}

-(void)configureBottomBar{
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
}

-(void)toggleCreateAccountButtonTitleColorToState:(UIControlState )controlState{
    if (controlState == UIControlStateNormal){
        [self.createAccountButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
//        self.createAccountButton.enabled = NO;
    }
    else {
        [self.createAccountButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.createAccountButton setTitleColor:[[UIColor frescoBlueColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
//        self.createAccountButton.enabled = YES;
    }
}

-(void)addSocialButtonsToBottomBar{
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 1, 24 + 18, 24 + 18)];
    [facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [facebookButton setImage:[UIImage imageNamed:@"facebook-icon-filled"] forState:UIControlStateHighlighted];
    [facebookButton setImage:[UIImage imageNamed:@"facebook-icon-filled"] forState:UIControlStateSelected];
    [facebookButton addTarget:self action:@selector(facebookTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:facebookButton];
    
    UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(facebookButton.frame.origin.x + facebookButton.frame.size.width, 1, 24 + 18, 24 + 18)];
    [twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
    [twitterButton setImage:[UIImage imageNamed:@"twitter-icon-filled"] forState:UIControlStateHighlighted];
    [twitterButton setImage:[UIImage imageNamed:@"twitter-icon-filled"] forState:UIControlStateSelected];
    [twitterButton addTarget:self action:@selector(twitterTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:twitterButton];
}

#pragma TextField Delegate

-(void)dismissKeyboard {
    [self highlightTextField:nil enabled:NO];
        
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField {

    if (textField == self.usernameTF) {
        [self.emailTF becomeFirstResponder];
    } else if (textField == self.emailTF) {
        [self.passwordTF becomeFirstResponder];
    } else if (textField == self.passwordTF) {
        [self.passwordTF resignFirstResponder];
    }

    
    return NO;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{

    if (textField == self.usernameTF){
        [self highlightTextField:self.usernameTF enabled:YES];
        if ([self.usernameTF.text isEqualToString:@""]){
            self.usernameTF.text = @"@";
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
 
    if (textField == self.usernameTF){
        
        [self highlightTextField:self.usernameTF enabled:NO];

        if ([self.usernameTF.text isEqualToString:@"@"]){
            self.usernameTF.text = @"";
        }
    }
//
//    UIControlState controlState;
//    
//    if ([FRSDataValidator isValidUserName:self.usernameTF.text] && [FRSDataValidator isValidEmail:self.emailTF.text] && [FRSDataValidator isValidPassword:self.passwordTF.text])
//        controlState = UIControlStateHighlighted;
//    else
//        controlState = UIControlStateNormal;
//    
//    [self toggleCreateAccountButtonTitleColorToState:controlState];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.usernameTF) {
        
//        NSCharacterSet *set = [NSCharacterSet symbolCharacterSet];
//        if ([string rangeOfCharacterFromSet:[set invertedSet]].location == NSNotFound) {
//            NSLog(@"valid");
//        } else {
//            NSLog(@"invalid");
//        }
        
        if (textField.text.length == 1 && [string isEqualToString:@""]) {//When detect backspace when have one character.
            return NO;
        }
    }
    return YES;
}



#pragma mark Action Logic 

-(void)handleToggleSwitched:(UISwitch *)toggle{
    
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
        
        [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.mapView.transform = CGAffineTransformMakeScale(1, 1);
            self.mapView.alpha = 1;
        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.promoContainer.transform = CGAffineTransformMakeTranslation(0, 0);
            self.promoDescription.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, 0);
            self.sliderContainer.alpha = 1;
        } completion:nil];
        
    } else {
        
        [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.notificationsEnabled = NO;
        });
        
        self.scrollView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.mapView.transform = CGAffineTransformMakeScale(0.93, 0.93);
            self.mapView.alpha = 0;
        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.2 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.promoContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
            self.promoDescription.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderContainer.transform = CGAffineTransformMakeTranslation(0, -(self.mapView.frame.size.height + self.sliderContainer.frame.size.height +18));
        } completion:nil];
        [UIView animateWithDuration:0.3 delay:0.15 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderContainer.alpha = 0;
        } completion:nil];
    }
}

-(void)createAccount {
    
    FRSSetupProfileViewController *vc = [[FRSSetupProfileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)twitterTapped{
    [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error) {
        //
    }];
}

-(void)facebookTapped{
    [FRSSocial loginWithFacebook:^(BOOL authenticated, NSError *error) {
        //
    } parent:self];
}

#pragma mark - Keyboard

-(void)handleKeyboardWillShow:(NSNotification *)sender {
    
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    
    NSInteger newScrollViewHeight = self.view.frame.size.height - keyboardSize.height;
    NSInteger yOffset = self.scrollView.contentSize.height - newScrollViewHeight;
    
    CGPoint point = self.scrollView.contentOffset;

    [UIView animateWithDuration:0.15 animations:^{
        [self.scrollView setContentOffset:point animated:NO];
    }];
    
    if (self.promoTF.isFirstResponder) {
        if (self.notificationsEnabled) {
            
            self.scrollView.frame = CGRectMake(0, -keyboardSize.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);

            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
            
        } else {
            if (IS_IPHONE_6) {
                self.scrollView.frame = CGRectMake(0, -36, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            } else if (IS_IPHONE_6_PLUS) {
                
            } else if (IS_IPHONE_5) {
                self.scrollView.frame = CGRectMake(0, -144, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            }
        }
    }
}

-(void)handleKeyboardWillHide:(NSNotification *)sender{
    
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, 0);
    
    if (self.scrollView.frame.size.height < self.view.frame.size.height - 108){
        [UIView animateWithDuration:0.15 animations:^{
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height - 44);
        }];
    }
    
    if (self.promoTF.isFirstResponder){
        self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
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



#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
//    [self.view resignFirstResponder];
//    [self.usernameTF resignFirstResponder];
//    [self.emailTF resignFirstResponder];
//    [self.passwordTF resignFirstResponder];
//    [self.promoTF resignFirstResponder];
}

@end
