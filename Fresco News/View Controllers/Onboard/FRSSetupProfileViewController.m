//
//  FRSSetupProfileViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSetupProfileViewController.h"
#import "FRSBaseViewController.h"
#import "FRSProfileViewController.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import <Haneke/Haneke.h>

@interface FRSSetupProfileViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *topContainer;

@property (strong, nonatomic) UIView *profileShadow;
@property (strong, nonatomic) UIView *bottomBar;

@property (strong, nonatomic) UIImageView *profileIV;

@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *photosButton;

@property (strong, nonatomic) UITextView *bioTV;
@property (strong, nonatomic) UITextField *nameTF;
@property (strong, nonatomic) UITextField *locationTF;
@property (strong, nonatomic) UIImageView *placeHolderUserIcon;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) NSInteger y;
@property (strong, nonatomic) UITapGestureRecognizer *dismissGR;
@property (strong, nonatomic) UIButton *backTapButton;
@property (strong, nonatomic) UIButton *doneButton;

@end

@implementation FRSSetupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self addNotifications];
    [self configureImagePicker];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    if(_isEditingProfile){//Back Button Disabled
        [self configureBackButtonAnimated:YES];
        //[self.navigationItem setLeftItemsSupplementBackButton:false];
    }
    
    [self hideTabBarAnimated:true];
    
    [self.navigationController setNavigationBarHidden:false];
    NSLog(@"%f",self.navigationController.navigationBar.bounds.origin.y);
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Nota-Bold" size:17.0]
                                                            }];

}

-(void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(NSDictionary *)updateDigest {
    NSMutableDictionary *profileInfo = [[NSMutableDictionary alloc] init];
    
    if (self.bioTV.text) {
        profileInfo[@"bio"] = self.bioTV.text;
    }
    if (self.nameTF.text) {
        profileInfo[@"full_name"] = self.nameTF.text;
    }
    if (self.locationTF.text) {
        profileInfo[@"location"] = self.locationTF.text;
    }
    if (self.profileIV.image) {
        //Send image to backend and set the url to the avatar :)
        NSData *imageData = UIImageJPEGRepresentation(self.profileIV.image, 1.0);
        
        [[FRSAPIClient sharedClient] postAvatar:setAvatarEndpoint withParameters:@{@"avatar":imageData} completion:^(id responseObject, NSError *error) {
            NSLog(@"Response Object: %@", responseObject);
            NSLog(@"Error: %@", error);
        }];
        //profileInfo[@"avatar"] = [NSURL URLWithDataRepresentation:data relativeToURL:[[NSURL alloc] init]];
    }
    
    return profileInfo;
}

-(void)addUserProfile {
    
    if (self.nameTF.text == nil) {
        return;
    }

    
    [[FRSAPIClient sharedClient] updateUserWithDigestion:[self updateDigest] completion:^(id responseObject, NSError *error) {
        if (error) {
            // show modal
            if (error.code/100 == 4) {
                // we fucked up
            }
            else if (error.code/100 == 5) {
                // they fucked up
            }
            else if (error.code/100 == 3) {
                // auth fucked up
            }
            //NSLog(@"RESPONSE:%@ ", responseObject);
            NSLog(@"ERROR!:%@ ", error);
            
            return;
        }
        // dismiss modal
        
        self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
        
        CABasicAnimation *translate = [CABasicAnimation animationWithKeyPath:@"position.y"];
        [translate setFromValue:[NSNumber numberWithFloat:self.view.center.y]];
        [translate setToValue:[NSNumber numberWithFloat:self.view.center.y +50]];
        [translate setDuration:0.6];
        [translate setRemovedOnCompletion:NO];
        [translate setFillMode:kCAFillModeForwards];
        [translate setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0 :0 :1.0]];
        [[self.view layer] addAnimation:translate forKey:@"translate"];
        
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        if(_isEditingProfile){
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            FRSProfileViewController *profileController = (FRSProfileViewController *)[self.navigationController.viewControllers objectAtIndex: 0];
            profileController.nameLabel.text = self.nameTF.text;
            profileController.locationLabel.text = self.locationTF.text;
            profileController.bioTextView.text = self.bioTV.text;
            profileController.profileIV.image = self.profileIV.image;
            profileController.profileIV.contentMode = UIViewContentModeScaleAspectFill;
            [[self navigationController] popToRootViewControllerAnimated:NO];
        }else{
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [[self navigationController] setNavigationBarHidden:YES];
            [[self navigationController] popToRootViewControllerAnimated:NO];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    }];
}


-(void)configureImagePicker{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = (id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)self;
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
    self.navigationItem.titleView.backgroundColor = [UIColor whiteColor];
    if(self.isEditingProfile){
        self.navigationItem.title = @"EDIT PROFILE";
        
        UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [container addSubview:backButton];
        
        backButton.tintColor = [UIColor whiteColor];
        //    backButton.backgroundColor = [UIColor redColor];
        backButton.frame = CGRectMake(-15, -12, 48, 48);
        backButton.imageView.frame = CGRectMake(-12, 0, 48, 48); //this doesnt change anything
        //    backButton.imageView.backgroundColor = [UIColor greenColor];
        [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:backButtonImage forState:UIControlStateNormal];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:container];
        
        
        self.backTapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
        [self.backTapButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        //    self.backTapButton.backgroundColor = [UIColor blueColor];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.backTapButton];
        
        //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        //    [view addGestureRecognizer:tap];
        
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }else{
        self.navigationItem.title = @"SET UP YOUR PROFILE";
        self.navigationItem.hidesBackButton = YES;
    }}

-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
    [self.backTapButton removeFromSuperview];
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
//    [self.profileIV addBorderWithWidth:8 color:[UIColor whiteColor]];
    self.profileIV.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.profileIV.userInteractionEnabled = YES;
    self.profileIV.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self.profileShadow addSubview:self.profileIV];
    
    
    self.placeHolderUserIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"large-user"]];
    self.placeHolderUserIcon.frame = CGRectMake(60, 60, 72, 72);
    if (IS_IPHONE_5) {
        self.placeHolderUserIcon.frame = CGRectMake(40, 40, 48, 48);
    }
    
    if(_isEditingProfile){
        [self.profileIV setImage:self.profileImage];
    }else{
        [self.profileIV addSubview:self.placeHolderUserIcon];
    }
    
    
    UIView *ring = [[UIView alloc] initWithFrame:CGRectMake(self.profileIV.frame.origin.x-1, self.profileShadow.frame.origin.y-1, height+2, height+2)];
    ring.backgroundColor = [UIColor clearColor];
    ring.layer.cornerRadius = height/2;
    [ring addBorderWithWidth:8 color:[UIColor whiteColor]];
    [self.scrollView addSubview:ring];
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
    self.nameTF.tag = 1;
    self.nameTF.tintColor = [UIColor frescoOrangeColor];
    if(_isEditingProfile && _nameStr != (id)[NSNull null] && _nameStr.length != 0){
        self.nameTF.text = _nameStr;
    }else{
        self.nameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    }
    self.nameTF.delegate = self;
    self.nameTF.font = [UIFont systemFontOfSize:15 weight:-1];
    self.nameTF.textColor = [UIColor frescoDarkTextColor];
    self.nameTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.nameTF.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTF.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    [self.nameTF addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    
    [backgroundView addSubview:self.nameTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y = self.topContainer.frame.origin.y + self.topContainer.frame.size.height + 44;
}

-(void)configureLocationField{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y , self.view.frame.size.width, 44)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];
    
    self.locationTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 16 *2, 44)];
    self.locationTF.tag = 2;
    self.locationTF.tintColor = [UIColor frescoOrangeColor];
    if(_isEditingProfile && _locStr != (id)[NSNull null] && _locStr.length != 0){
        self.locationTF.text = _locStr;
    }else{
        self.locationTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Location" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    }
    self.locationTF.delegate = self;
    self.locationTF.font = [UIFont systemFontOfSize:15 weight:-1];
    self.locationTF.textColor = [UIColor frescoDarkTextColor];
    self.locationTF.backgroundColor = [UIColor frescoBackgroundColorLight];
    [backgroundView addSubview:self.locationTF];
    
    [backgroundView addSubview:[UIView lineAtPoint:CGPointMake(0, 43.5)]];
    
    self.y += 44;
}

-(void)configureBioField{
    //64 is the nav bar, 44 is the bottom bar
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.y, self.view.frame.size.width, self.view.frame.size.height - self.y - 64)];
    backgroundView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:backgroundView];

    self.bioTV = [[UITextView alloc] initWithFrame:CGRectMake(16, 11, backgroundView.frame.size.width - 32, backgroundView.frame.size.height - 22)];
    self.bioTV.tag = 3;
    self.bioTV.tintColor = [UIColor frescoOrangeColor];
    self.bioTV.delegate = self;
    self.bioTV.textContainer.lineFragmentPadding = 0;
    self.bioTV.textContainerInset = UIEdgeInsetsZero;
    self.bioTV.font = [UIFont systemFontOfSize:15 weight:-1];
    self.bioTV.textColor = [UIColor frescoDarkTextColor];
    self.bioTV.backgroundColor = [UIColor frescoBackgroundColorLight];
    if(_isEditingProfile && _bioStr != (id)[NSNull null] && _bioStr.length != 0){
        self.bioTV.text = _bioStr;
    }else{
        self.bioTV.attributedText = [[NSAttributedString alloc] initWithString:@"Bio" attributes:@{NSForegroundColorAttributeName : [UIColor frescoLightTextColor], NSFontAttributeName : [UIFont systemFontOfSize:15 weight:-1]}];
    }
    
    [backgroundView addSubview:self.bioTV];
}


-(void)configureBottomBar{
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.bounds.size.height - 44, self.view.frame.size.width, 44)];

    self.bottomBar.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.bottomBar];
    
    [self.bottomBar addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 91 - 16, 0, 91, 44)];
    [self.doneButton setTitle:@"SAVE PROFILE" forState:UIControlStateNormal];
    self.doneButton.userInteractionEnabled = NO;
    [self.doneButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [self.doneButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.bottomBar addSubview:self.doneButton];
    [self.doneButton addTarget:self action:@selector(addUserProfile) forControlEvents:UIControlEventTouchUpInside];
    
//    [self constrainSubview:bottomBar ToBottomOfParentView:self.view WithHeight:44];
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


#pragma TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(_isEditingProfile){
        self.doneButton.userInteractionEnabled = YES;
        [self.doneButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    }else{
        if ([self.nameTF.text isEqualToString:@""]) {
            self.doneButton.userInteractionEnabled = NO;
            [self.doneButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        } else {
            self.doneButton.userInteractionEnabled = YES;
            [self.doneButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if(textField == self.nameTF){
        [_locationTF becomeFirstResponder];
    }else if(textField == self.locationTF){
        [_bioTV becomeFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (!self.dismissGR){
        self.dismissGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    }
    
    [self.view addGestureRecognizer:self.dismissGR];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:self.dismissGR];
}

#pragma Text View Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Bio"] || [textView.text isEqualToString:@"bio"]){
        textView.attributedText = nil;
        textView.text = @"";
        textView.textColor = [UIColor frescoDarkTextColor];
    }
    
    if (!self.dismissGR){
        self.dismissGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    }
    [self.view addGestureRecognizer:self.dismissGR];
}

-(void)textViewDidChange:(UITextView *)textView{
    if(_isEditingProfile){
        self.doneButton.userInteractionEnabled = YES;
        [self.doneButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
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
    
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    
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
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, 0);

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
        self.placeHolderUserIcon.alpha = 0;
    }
    else if ([info valueForKey:UIImagePickerControllerOriginalImage]){
        selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (selectedImage){
        self.profileIV.image = selectedImage;
        self.doneButton.userInteractionEnabled = YES;
        [self.doneButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
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
