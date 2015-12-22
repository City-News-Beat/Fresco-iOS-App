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

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UISlider *radiusSlider;

@property (strong, nonatomic) UIView *bottomBar;

@property (strong, nonatomic) UIButton *createAccountButton;

@end

@implementation FRSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    self.navigationItem.title = @"SIGN UP";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
    
    // Do any additional setup after loading the view.
}

#pragma mark - UI 

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureScrollView];
    [self configureTextFields];
    [self configureNotificationSection];
    [self configureMapView];
    [self configureSliderSection];
    [self adjustScrollViewContentSize];
    [self configureBottomBar];
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
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, self.scrollView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [self.usernameTF addSubview:bottomLine];
}

-(void)configureEmailAddressField{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 92, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.scrollView.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [backgroundView addSubview:topLine];
    
    self.emailTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.scrollView.frame.size.width - 32, 44)];
    self.emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email address" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.emailTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.emailTF.delegate = self;
    [backgroundView addSubview:self.emailTF];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, self.scrollView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [backgroundView addSubview:bottomLine];
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
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, self.scrollView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [backgroundView addSubview:bottomLine];
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
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.scrollView.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [backgroundView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 61.5, self.scrollView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [backgroundView addSubview:bottomLine];
    
}

-(void)configureMapView{
    
    NSInteger height = 240;
    if (IS_STANDARD_IPHONE_6) height = 280;
    if (IS_STANDARD_IPHONE_6_PLUS) height = 310;
    
    
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
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, height - 0.5, self.scrollView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
    [self.mapView addSubview:bottomLine];
}

-(void)configureSliderSection{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.origin.y + self.mapView.frame.size.height, self.scrollView.frame.size.width, 56)];
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
}

-(void)adjustScrollViewContentSize{
    
    //56 is the size of the slider background view, 8 is the bottom y padding, 44 is the size of the bottom bar
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 254 + self.mapView.frame.size.height + 56 + 8);
}

-(void)configureBottomBar{
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 108, self.view.frame.size.width, 44)];
    self.bottomBar.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.bottomBar];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.bottomBar.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.bottomBar addSubview:topLine];
    
    self.createAccountButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 167, 0, 167, 44)];
    [self.createAccountButton setTitle:@"CREATE MY ACCOUNT" forState:UIControlStateNormal];
    [self.createAccountButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.createAccountButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [self.createAccountButton setTitleColor:[UIColor frescoMediumTextColor] forState:UIControlStateHighlighted];
    [self.createAccountButton addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.createAccountButton];
    
}

#pragma mark Action Logic 

-(void)handleToggleSwitched:(UISwitch *)toggle{
    
}

-(void)createAccount{
    
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
