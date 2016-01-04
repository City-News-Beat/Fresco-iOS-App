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

@interface FRSSetupProfileViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIView *profileShadow;
@property (strong, nonatomic) UIImageView *profileIV;

@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *photosButton;

@property (strong, nonatomic) UITextField *nameTF;
@property (strong, nonatomic) UITextField *locationTF;
@property (strong, nonatomic) UITextView *bioTV;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) NSInteger y;

@property (strong, nonatomic) UITapGestureRecognizer *dismissGR;

@end

@implementation FRSSetupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self addNotifications];
    [self configureImagePicker];
    // Do any additional setup after loading the view.
}

-(void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)configureImagePicker{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
}

#pragma mark - UI Elements

- (void)configureUI{
    [self configureNavigationBar];
    [self configureScrollView];
    [self configureTopContainer];
    [self configureTextViews];
    [self configureBottomBar];
}

-(void)configureNavigationBar{
    self.navigationItem.title = @"SETUP YOUR PROFILE";
    
    
}

-(void)configureScrollView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.view addSubview:self.scrollView];
    
}

- (void)configureTopContainer{
    NSInteger height = 220;
    if (!IS_IPHONE_5) height = 284;
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    self.topContainer.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.scrollView addSubview:self.topContainer];
    
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
    [self.scrollView addSubview:self.profileShadow];

    self.profileIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    [self.profileIV centerHorizontallyInView:self.topContainer];
    [self.profileIV clipAsCircle];
    [self.profileIV addBorderWithWidth:8 color:[UIColor whiteColor]];
    self.profileIV.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.profileIV.userInteractionEnabled = YES;
    
    [self.profileShadow addSubview:self.profileIV];
}

-(void)configureCameraButton{
    
    NSInteger x = 25;
    if (IS_IPHONE_6) x = 43;
    if (IS_IPHONE_6_PLUS) x = 56;
    
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(x, self.profileShadow.frame.origin.y + self.profileShadow.frame.size.height + 22 , 128, 24)];
    [self.cameraButton setImage:[UIImage imageNamed:@"camera-icon-profile"] forState:UIControlStateNormal];
    [self.cameraButton setTitle:@"OPEN CAMERA" forState:UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(presentCameraImagePicker) forControlEvents:UIControlEventTouchUpInside];
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
    [self.photosButton addTarget:self action:@selector(presentImagePickerController) forControlEvents:UIControlEventTouchUpInside];
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
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    self.nameTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 16 *2, 44)];
    self.nameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.nameTF.delegate = self;
    self.nameTF.font = [UIFont systemFontOfSize:15 weight:-1];
    self.nameTF.textColor = [UIColor frescoMediumTextColor];
    [backgroundView addSubview:self.nameTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y = self.topContainer.frame.origin.y + self.topContainer.frame.size.height + 44;
}

-(void)configureLocationField{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y , self.view.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    self.locationTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 16 *2, 44)];
    self.locationTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Location" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    self.locationTF.delegate = self;
    self.locationTF.font = [UIFont systemFontOfSize:15 weight:-1];
    self.locationTF.textColor = [UIColor frescoMediumTextColor];
    [backgroundView addSubview:self.locationTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y += 44;
}

-(void)configureBioField{
    //64 is the nav bar, 44 is the bottom bar
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.view.frame.size.width, self.view.frame.size.height - self.y - 64 - 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];

    self.bioTV = [[UITextView alloc] initWithFrame:CGRectMake(16, 11, backgroundView.frame.size.width - 32, backgroundView.frame.size.height - 22)];
    self.bioTV.delegate = self;
    self.bioTV.textContainer.lineFragmentPadding = 0;
    self.bioTV.textContainerInset = UIEdgeInsetsZero;
    self.bioTV.font = [UIFont systemFontOfSize:15 weight:-1];
    self.bioTV.textColor = [UIColor frescoMediumTextColor];
    self.bioTV.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.bioTV.attributedText = [[NSAttributedString alloc] initWithString:@"Bio" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    
    
    [backgroundView addSubview:self.bioTV];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, backgroundView.frame.size.height - 0.5)]];
}


-(void)configureBottomBar{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - 44, self.scrollView.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(backgroundView.frame.size.width - 32 - 37, 0, 37 + 32, 44)];
    [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [backgroundView addSubview:doneButton];
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

#pragma Text View Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (!self.dismissGR)
        self.dismissGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:self.dismissGR];
    
    if (textView.attributedText){
        textView.attributedText = nil;
        textView.textColor = [UIColor frescoMediumTextColor];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [self.view removeGestureRecognizer:self.dismissGR];
    
    if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        textView.attributedText = [[NSAttributedString alloc] initWithString:@"Bio" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    }
}



#pragma mark - Keyboard


-(void)handleKeyboardWillShow:(NSNotification *)sender{
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSInteger newScrollViewHeight = self.view.frame.size.height - keyboardSize.height;
    CGPoint point;
    
    if (self.nameTF.isFirstResponder){
        point = CGPointMake(0, self.topContainer.frame.size.height / 2);
    }
    else if (self.locationTF.isFirstResponder){
        point = CGPointMake(0, self.topContainer.frame.size.height / 2 + 44);
    }
    else {
        point = CGPointMake(0, self.topContainer.frame.size.height / 2 + 44 * 2);
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, newScrollViewHeight);
        [self.scrollView setContentOffset:point animated:NO];
    }];
}

-(void)handleKeyboardWillHide:(NSNotification *)sender{
    if (self.scrollView.frame.size.height < self.view.frame.size.height - 108){
        [UIView animateWithDuration:0.15 animations:^{
            self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height);
        }];
    }
}

-(void)dismissKeyboard{
    [self.nameTF resignFirstResponder];
    [self.locationTF resignFirstResponder];
    [self.bioTV resignFirstResponder];
}

#pragma mark - UIImagePicker

-(void)presentImagePickerController{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)presentCameraImagePicker{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *selectedImage;
    if ([info valueForKey:UIImagePickerControllerEditedImage]){
        selectedImage = [info valueForKey:UIImagePickerControllerEditedImage];
    }
    else if ([info valueForKey:UIImagePickerControllerOriginalImage]){
        selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (selectedImage){
        self.profileIV.image = selectedImage;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
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
