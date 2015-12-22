//
//  FRSSetupProfileViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSetupProfileViewController.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

@interface FRSSetupProfileViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIView *profileShadow;
@property (strong, nonatomic) UIImageView *profileIV;

@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *photosButton;

@property (strong, nonatomic) UITextField *nameTF;
@property (strong, nonatomic) UITextField *locationTF;
@property (strong, nonatomic) UITextView *bioTV;

@property (nonatomic) NSInteger y;

@end

@implementation FRSSetupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    // Do any additional setup after loading the view.
}

- (void)configureUI{
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17]};
    self.navigationController.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"SETUP YOUR PROFILE";
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureTopContainer];
    [self configureTextViews];
    [self configureBottomBar];
}

- (void)configureTopContainer{
    NSInteger height = 220;
    if (!IS_IPHONE_5) height = 284;
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    self.topContainer.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.topContainer];
    
    [self configureImageView];
    [self configureCameraButton];
    [self configurePhotosButton];
    
    [self.topContainer addSubview:[UIView lineAtPoint:CGPointMake(0, height - 0.5)]];
}

-(void)configureImageView{
    
    NSInteger height = 128;
    if (!IS_IPHONE_5) height = 192;
    
    self.profileShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 24, height, height)];
    [self.profileShadow addShadowWithColor:nil radius:3 offset:CGSizeMake(0, 2)];
    [self.view addSubview:self.profileShadow];

    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    [self.profileIV centerHorizontallyInView:self.topContainer];
    [self.profileIV clipAsCircle];
    [self.profileIV addBorderWithWidth:8 color:[UIColor whiteColor]];
    self.profileIV.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self.profileShadow addSubview:self.profileIV];
}

-(void)configureCameraButton{
    
    NSInteger x = 25;
    if (IS_IPHONE_6) x = 43;
    if (IS_IPHONE_6_PLUS) x = 56;
    
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(x, self.profileShadow.frame.origin.y + self.profileShadow.frame.size.height + 22 , 128, 24)];
    [self.cameraButton setImage:[UIImage imageNamed:@"camera-icon-profile"] forState:UIControlStateNormal];
    [self.cameraButton setTitle:@"OPEN CAMERA" forState:UIControlStateNormal];
    [self.cameraButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.cameraButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [self.topContainer addSubview:self.cameraButton];
}

-(void)configurePhotosButton {
    
    NSInteger x = 25;
    if (IS_IPHONE_6) x = 43;
    if (IS_IPHONE_6_PLUS) x = 56;
    
    NSInteger xOrigin = self.view.frame.size.width - x - 128;
    
    self.photosButton = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin, self.cameraButton.frame.origin.y, 128, 24)];
    [self.photosButton setImage:[UIImage imageNamed:@"photo-icon-profile"] forState:UIControlStateNormal];
    [self.photosButton setTitle:@"OPEN PHOTOS" forState:UIControlStateNormal];
    [self.photosButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.photosButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
    [self.topContainer addSubview:self.photosButton];
}

-(void)configureTextViews{
    [self configureNameField];
    [self configureLocationField];
    [self configureBioField];
}

-(void)configureNameField{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topContainer.frame.origin.y + self.topContainer.frame.size.height, self.view.frame.size.width, 44)];
    [self.view addSubview:backgroundView];
    
    self.nameTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 16 *2, 44)];
    self.nameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    [backgroundView addSubview:self.nameTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y = self.topContainer.frame.origin.y + self.topContainer.frame.size.height + 44;
}

-(void)configureLocationField{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y , self.view.frame.size.width, 44)];
    [self.view addSubview:backgroundView];
    
    self.locationTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 16 *2, 44)];
    self.locationTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Location" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    [backgroundView addSubview:self.locationTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
}

-(void)configureBioField{
    
}


-(void)configureBottomBar{
    
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
