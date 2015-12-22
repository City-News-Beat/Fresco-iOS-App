//
//  FRSSignUpViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSignUpViewController.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

@import MapKit;


@interface FRSSignUpViewController () <UITextFieldDelegate, MKMapViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *usernameTF;
@property (strong, nonatomic) UITextField *emailTF;
@property (strong, nonatomic) UITextField *passwordTF;
@property (strong, nonatomic) UITextField *promoTF;

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UISlider *radiusSlider;

@property (strong, nonatomic) UIView *bottomBar;

@property (strong, nonatomic) UIButton *createAccountButton;

@property (strong, nonatomic) UITapGestureRecognizer *dismissGR;

@property (nonatomic) NSInteger y;

@end

@implementation FRSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    
    
    [self addNotifications];
    
    
    // Do any additional setup after loading the view.
}

-(void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}


#pragma mark - UI 

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureNavigationBar];
    [self configureScrollView];
    [self configureTextFields];
    [self configureNotificationSection];
    [self configureMapView];
    [self configureSliderSection];
    [self configurePromoSection];
    [self adjustScrollViewContentSize];
    [self configureBottomBar];
}

-(void)configureNavigationBar{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    self.navigationItem.title = @"SIGN UP";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
}


-(void)configureScrollView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 108)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.scrollView];
}

-(void)configureTextFields{
    [self configureUserNameField];
    [self configureEmailAddressField];
    [self configurePasswordField];
}

-(void)configureUserNameField{
    self.usernameTF = [[UITextField alloc] initWithFrame:CGRectMake(48, 24, self.scrollView.frame.size.width - 2 * 48, 44)];
    self.usernameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"@username" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont notaMediumWithSize:17]}];
    self.usernameTF.delegate = self;
    [self.scrollView addSubview:self.usernameTF];
    
    [self.usernameTF addSubview:[self lineAtPoint:CGPointMake(0, 43.5)]];
}

-(void)configureEmailAddressField{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.emailTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email address" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.emailTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.emailTF.delegate = self;
    [backgroundView addSubview:self.emailTF];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, 43.5)]];
}

-(void)configurePasswordField{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 136, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    self.passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.passwordTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.passwordTF.delegate = self;
    [backgroundView addSubview:self.passwordTF];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, 43.5)]];
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
    toggle.on = YES;
    toggle.onTintColor = [UIColor frescoGreenColor];
    [toggle addTarget:self action:@selector(handleToggleSwitched:) forControlEvents:UIControlEventValueChanged];
    [backgroundView addSubview:toggle];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, -0.5)]];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, 61.5)]];
    
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
    
    [self.mapView addSubview:[self lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.y += self.mapView.frame.size.height;
}

-(void)configureSliderSection{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.scrollView.frame.size.width, 56)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    self.radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.view.frame.size.width - 104, 28)];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [self.radiusSlider setMaximumTrackTintColor:[UIColor colorWithWhite:181/255.0 alpha:1.0]];
    [backgroundView addSubview:self.radiusSlider];

    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [backgroundView addSubview:smallIV];
    
    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [backgroundView addSubview:bigIV];
    
    self.y += backgroundView.frame.size.height + 12;
}

-(void)configurePromoSection{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.promoTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.promoTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Promo" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.promoTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.promoTF.delegate = self;
    [backgroundView addSubview:self.promoTF];
    
    [backgroundView addSubview:[self lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y += backgroundView.frame.size.height + 12;
    
    UILabel *promoDescription = [[UILabel alloc] initWithFrame:CGRectMake(16, self.y, self.scrollView.frame.size.width - 2 * 16, 28)];
    promoDescription.numberOfLines = 0;
    promoDescription.text = @"If you use a friend’s promo code, you’ll get $20 when you respond to an assignment for the first time.";
    promoDescription.font = [UIFont systemFontOfSize:12];
    promoDescription.textColor = [UIColor frescoMediumTextColor];
    [promoDescription sizeToFit];
    [self.scrollView addSubview:promoDescription];
    
    self.y += promoDescription.frame.size.height + 24;
}

-(void)adjustScrollViewContentSize{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.y);
}

-(void)configureBottomBar{
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 108, self.view.frame.size.width, 44)];
    self.bottomBar.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.bottomBar];
    
    [self.bottomBar addSubview:[self lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.createAccountButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 167, 0, 167, 44)];
    [self.createAccountButton setTitle:@"CREATE MY ACCOUNT" forState:UIControlStateNormal];
    [self.createAccountButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.createAccountButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [self.createAccountButton setTitleColor:[UIColor frescoMediumTextColor] forState:UIControlStateHighlighted];
    [self.createAccountButton addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.createAccountButton];
}

-(UIView *)lineAtPoint:(CGPoint)point{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, self.scrollView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    return line;
}

#pragma TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (!self.dismissGR)
        self.dismissGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:self.dismissGR];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:self.dismissGR];
}

#pragma mark Action Logic 

-(void)handleToggleSwitched:(UISwitch *)toggle{
    if (toggle.on){
        
    }
    else {
        
    }
}

-(void)createAccount{
    
}

#pragma mark - Keyboard

-(void)handleKeyboardWillShow:(NSNotification *)sender{
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (self.promoTF.isFirstResponder){
        NSInteger newScrollViewHeight = self.view.frame.size.height - keyboardSize.height;
        NSInteger yOffset = self.scrollView.contentSize.height - newScrollViewHeight;
        
        [UIView animateWithDuration:0.15 animations:^{
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, newScrollViewHeight);
            [self.scrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
        }];
    }
}

-(void)handleKeyboardWillHide:(NSNotification *)sender{
    if (self.scrollView.frame.size.height < self.view.frame.size.height - 108){
        [UIView animateWithDuration:0.15 animations:^{
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height - 44);
        }];
    }
}

-(void)dismissKeyboard{
    [self.usernameTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
