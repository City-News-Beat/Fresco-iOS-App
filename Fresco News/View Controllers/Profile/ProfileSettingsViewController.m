//
//  ProfileSettingsViewController.m
//  FrescoNews
//
//  Created by Fresco News on 5/12/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Parse;
@import FBSDKCoreKit;
@import FBSDKLoginKit;

@class FRSUser;

#import "ProfileSettingsViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "MKMapView+Additions.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MapKit/MapKit.h>
#import "FRSSocialButton.h"
#import "NSString+Validation.h"
#import "ProfilePaymentSettingsViewController.h"
#import "FRSSaveButton.h"
#import "UIView+Border.h"
#import <DBImageColorPicker.h>

typedef enum : NSUInteger {
    SocialExists,
    SocialDisable,
    SocialUnlinked,
    SocialNoError
} SocialError;

@interface ProfileSettingsViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

/***** In order of presentation *****/

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIActivityIndicatorView *toolbarSpinner;

/*
** Profile Picture
*/

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) UIImage *selectedImage;

/*
** Text Fields
*/

@property (weak, nonatomic) IBOutlet UITextField *textfieldFirst;
@property (weak, nonatomic) IBOutlet UITextField *textfieldLast;
@property (weak, nonatomic) IBOutlet UITextField *textfieldNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *textfieldConfirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *textfieldEmail;

/*
** Buttons
*/

@property (weak, nonatomic) IBOutlet FRSSocialButton *connectTwitterButton;
@property (weak, nonatomic) IBOutlet FRSSocialButton *connectFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet FRSSaveButton *saveChangesbutton;

/*
** Radius Setting
*/

@property (weak, nonatomic) IBOutlet UISlider *radiusStepper;
@property (weak, nonatomic) IBOutlet UILabel *radiusStepperLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) DBImageColorPicker *picker;

/*
** UI Constraints
*/

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAccountVerticalBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAccountVerticalTop;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *viewsWithShadows;

@property (nonatomic, assign) BOOL locationUpdated;

@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Edit Profile";

    [self configureViews];
    
    self.textfieldFirst.text = [FRSDataManager sharedManager].currentUser.first;
    self.textfieldLast.text  = [FRSDataManager sharedManager].currentUser.last;
    self.textfieldEmail.text = [FRSDataManager sharedManager].currentUser.email;
    [self.textfieldFirst addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textfieldLast addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textfieldEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textfieldNewPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.addCardButton setTitleColor:[UIColor textInputBlackColor] forState:UIControlStateHighlighted];
    
    // Radius slider values
    self.radiusStepper.value = [[FRSDataManager sharedManager].currentUser.notificationRadius floatValue];
    
    // Update the slider label
    [self sliderValueChanged:self.radiusStepper];
    
    //Update social connect buttons
    [self updateLinkingStatus];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.picker)
        self.picker = [MKMapView createDBImageColorPickerForUserWithImage:nil];
    
    [self updateAddCardButton];
    
}

- (void)configureViews{
    
    self.saveChangesbutton.alpha = 0;
    
    [self.saveChangesbutton updateSaveState:SaveStateDisabled];
     
    for (UIView *view in self.viewsWithShadows) {
        
        [view addBorderWithWidth:1.0f];
        
    }
    
    //Checks if the user's primary login is through social, then disable the email and password fields
    if(([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] || [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
       && [FRSDataManager sharedManager].currentUser.email == nil){
        
        [self.view viewWithTag:100].hidden = YES;
        [self.view viewWithTag:101].hidden = YES;
        [[self.view viewWithTag:100] removeFromSuperview];
        [[self.view viewWithTag:101] removeFromSuperview];
        
        CGFloat y = -self.view.frame.size.height/8;
        self.constraintAccountVerticalTop.constant = y;
        self.constraintAccountVerticalBottom.constant = 0;
        
    }
    
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
    
    //Update the profile image
    if ([FRSDataManager sharedManager].currentUser.avatar != nil) {
        
        [self.profileImageView
         setImageWithURLRequest:[NSURLRequest requestWithURL:[[FRSDataManager sharedManager].currentUser avatarUrl]]
         placeholderImage:[UIImage imageNamed:@"user"]
         success:nil failure:nil];
    }
    
    //TapGestureRecognizer for the profile picture, to bring up the MediaPickerController
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    
    //Make the profile image interactive
    [self.profileImageView addGestureRecognizer:singleTap];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    [self.connectFacebookButton setUpSocialIcon:SocialNetworkFacebook withRadius:YES];
    [self.connectTwitterButton setUpSocialIcon:SocialNetworkTwitter withRadius:YES];
    
    UIImageView *caret = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    caret.contentMode = UIViewContentModeScaleAspectFit;
    caret.frame = CGRectMake(
                             [[UIScreen mainScreen] bounds].size.width - 30,
                             (self.addCardButton.frame.size.height / 2) - 7.5,
                             15,
                             15
                             );
    
    [self.addCardButton addSubview:caret];
    
    [self updateAddCardButton];
    
    [self getYolked];
    
}

- (void)viewDidAppear:(BOOL)animated {
   
    [super viewDidAppear:animated];
    
    self.saveChangesbutton.alpha = 1;

}

/*
** Automatic save when user goes back to Profile Screen
*/

- (void)willMoveToParentViewController:(UIViewController *)parent{
    
    [super willMoveToParentViewController:parent];
    
    [self saveChanges];
    
}


- (void)getYolked{

    UIImageView *egg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"egg"]];
    
    egg.frame = CGRectMake(0, 0, self.view.frame.size.width / 1.3, 220);
    egg.center = CGPointMake(self.view.bounds.size.width/2 , -400);
    egg.contentMode = UIViewContentModeScaleAspectFit;
    

    UILabel *version = [[UILabel alloc] init];
    version.numberOfLines = 0;
    version.frame = CGRectMake(0, 0, 65, 70);
    version.center = CGPointMake(self.navigationController.toolbar.frame.size.width / 2, self.scrollView.frame.size.height + 100);
    version.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:12];
    version.text = [NSString
                    stringWithFormat:@"Build %@\n\nVersion %@",
                    [[NSBundle mainBundle]infoDictionary][@"CFBundleVersion"],
                    [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"]];
    version.textColor = [UIColor textHeaderBlackColor];
    version.textAlignment = NSTextAlignmentCenter;
    
    [self.scrollView addSubview:version];
    [self.scrollView addSubview:egg];
    
}

#pragma mark - Controller Methods

/**
 *  Runs Parse social connect based on SocialNetwork param
 *
 *  @param network The network to connect to
 *  @param button  The button being pressed
 */

- (void)socialConnect:(SocialNetwork)network networkButton:(UIButton*)button{
    
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateNormal];
    
    self.connectTwitterButton.enabled = NO;
    self.connectFacebookButton.enabled = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect spinnerFrame = CGRectMake(0,0, 20, 20);
        self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
        self.spinner.center = CGPointMake(button.frame.size.width  / 2, button.frame.size.height / 2);
        self.spinner.color = [UIColor whiteColor];
        [self.spinner startAnimating];
        
        [button addSubview:self.spinner];
            
    });
    
    if(network == SocialNetworkFacebook){
        
        //Connect the user
        if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:@[@"public_profile"] block:^(BOOL succeeded, NSError *error) {
                
                //If fails, alert user
                if (!succeeded) {
                    
                    [self triggerSocialResponse:SocialExists network:@"Facebook"];
                    
                }
                else{
                    [self triggerSocialResponse:SocialNoError network:@"Facebook"];
                }
                
                
            }];
        }
        //Disconnect the user
        else {
            
            //Make sure the social account isn't their primary connector
            if([FRSDataManager sharedManager].currentUser.email != nil){
                
                [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded)
                        [self triggerSocialResponse:SocialUnlinked network:@"Facebook"];
                    else
                        [self triggerSocialResponse:SocialExists network:@"Facebook"];
                    
                }];
                
            }
            else
                [self triggerSocialResponse:SocialDisable network:@"Facebook"];
            
        }
        
    }
    else if(network == SocialNetworkTwitter){
        
        //Connect the user
        if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            
            [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                
                if(!succeeded){
                    
                    [self triggerSocialResponse:SocialExists network:@"Twitter"];
                }
                else{
                    [self triggerSocialResponse:SocialNoError network:@"Twitter"];
                }
                
                
            }];
            
        }
        //Disconnect the user
        else {
            
            //Make sure the social account isn't their primary connector
            if([FRSDataManager sharedManager].currentUser.email != nil){
                
                [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded)
                        [self triggerSocialResponse:SocialUnlinked network:@"Twitter"];
                    else
                        [self triggerSocialResponse:SocialExists network:@"Twitter"];
                    
                }];
                
            }
            else{
                
                [self triggerSocialResponse:SocialDisable network:@"Twitter"];
                
            }
            
        }
        
    }
    
}

/**
 *  Triggers a response based on the passed Error
 *
 *  @param error   <#error description#>
 *  @param network <#network description#>
 */

- (void)triggerSocialResponse:(SocialError)error network:(NSString *)network{
    
    NSString *message = @"";
    NSString *title = @"";
    
    if(error != SocialNoError){
        
        if(error == SocialDisable){
            
            [self disableAcctWithSocialNetwork:network];
            
        }
        else{
            
            if(error == SocialExists){
                message = [NSString stringWithFormat:@"It seems you already have an account linked with %@.", network];
                title = ERROR;
            }
            else if(error == SocialUnlinked){
                message = [NSString stringWithFormat:@"You've been disconnected from %@.", network];
                title = SUCCESS;
            }
            
            [self presentViewController:[FRSAlertViewManager
                                         alertControllerWithTitle:title
                                         message:message
                                         action:nil]
                               animated:YES
                             completion:nil];
            
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectTwitterButton.enabled = YES;
        self.connectFacebookButton.enabled = YES;
        [self updateLinkingStatus];
        [self.spinner removeFromSuperview];
    });
    
}

/**
 *  Updates the status of the social buttons
 */

- (void)updateLinkingStatus {
    
    dispatch_async(dispatch_get_main_queue(), ^{
            
        if (![PFUser currentUser]) {
            [self.connectTwitterButton setHidden:YES];
            [self.connectFacebookButton setHidden:YES];
        }
        else {
            
            [self.connectTwitterButton setHidden:NO];
            [self.connectFacebookButton setHidden:NO];
            
            [self.connectTwitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
            [self.connectFacebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        
            //Twitter
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]])
                [self.connectTwitterButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            else
                [self.connectTwitterButton setTitle:@"Connect" forState:UIControlStateNormal];

            //Facebook
            if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
                [self.connectFacebookButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            else
                [self.connectFacebookButton setTitle:@"Connect" forState:UIControlStateNormal];

            
        }
        
    });
}


/**
 *  Invokes disable account dialog, and runs disable command if confirmed
 *
 *  @param network The network name
 */

- (void)disableAcctWithSocialNetwork:(NSString *)network {
    
    NSString *warningTitle;
    NSString *warningMessage;
    
    if (network) {
        
        warningTitle = ACCT_WILL_BE_DISABLED;
        
        warningMessage = [NSString stringWithFormat:@"Since you signed up with %@, disconnecting %@ will disable your account. You can sign in any time in the next year to restore your account.", network, network];
    }
    else{
        
        warningTitle = WELL_MISS_YOU;
        warningMessage = YOU_CAN_LOGIN_FOR_ONE_YR;
    
    }
    
    UIAlertController *alertCon = [FRSAlertViewManager
                                   alertControllerWithTitle:warningTitle
                                   message: warningMessage
                                   action:CANCEL handler:nil];
    
    [alertCon addAction:[UIAlertAction actionWithTitle:DISABLE style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){

        [[FRSDataManager sharedManager] disableFrescoUser:^(BOOL success, NSError *error){
            
            if (success) {

                [[FRSDataManager sharedManager] logout];
                
                FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
                
                [rvc setRootViewControllerToHighlights];
                
                [self.navigationController popViewControllerAnimated:NO];
                
            }
            else{
                
                [self presentViewController:[FRSAlertViewManager
                                             alertControllerWithTitle:ERROR
                                             message:DISABLE_ACCT_ERROR
                                             action:nil]
                                   animated:YES
                                 completion:nil];
                
            }
            
        }];
    }]];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}


/**
 *  Updates the state of the card button
 */

- (void)updateAddCardButton{
    
    dispatch_async(dispatch_get_main_queue(), ^{
            
        if([[FRSDataManager sharedManager].currentUser.payable integerValue] == 1){
            
            //If we already have the last 4
            if([[NSUserDefaults standardUserDefaults] objectForKey:UD_LAST4]){
                
                [self.addCardButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:UD_LAST4] forState:UIControlStateNormal];
                
            }
            //We don't have the last 4
            else{
                
                //Retrieve the last 4 fromt the API
                [[FRSDataManager sharedManager] getUserPaymentInfo:^(id responseObject, NSError *error) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"last4"] forKey:UD_LAST4];
                    
                    [self.addCardButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:UD_LAST4] forState:UIControlStateNormal];
                    
                }];
                
            }
            
            static dispatch_once_t onceToken;
            
            dispatch_once(&onceToken, ^{
                
                self.addCardButton.titleLabel.textColor = [UIColor textHeaderBlackColor];
                self.addCardButton.titleLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15.5];
                
                UILabel *newCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 15)];
                
                newCardLabel.text = @"New card";
                newCardLabel.textAlignment = NSTextAlignmentRight;
                newCardLabel.font = [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:15.5];
                [newCardLabel sizeToFit];
                [newCardLabel setFrame:CGRectOffset(newCardLabel.frame,
                                                    [[UIScreen mainScreen] bounds].size.width  - (newCardLabel.frame.size.width * 1.6),
                                                    (self.addCardButton.frame.size.height / 2) - 10.5)];
                
                [self.addCardButton addSubview:newCardLabel];
                
            });
        }
        
    });
}

/*
** Catch all save method
*/

- (void)saveChanges {
    
    //Break if the saveChangesButton is not enabled
    if(!self.saveChangesbutton.enabled) return;

    NSMutableDictionary *updateParams = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    if ([self.textfieldFirst.text length])
        [updateParams setObject:self.textfieldFirst.text forKey:@"firstname"];
    
    if ([self.textfieldLast.text length])
        [updateParams setObject:self.textfieldLast.text forKey:@"lastname"];
    
    //Check if the password field is not empty and is being needed for check
    if(self.textfieldNewPassword.text && self.textfieldNewPassword.text.length > 0){
       
        //Check if the password field text is valid
        if(![self.textfieldNewPassword.text isValidPassword]){

            [self presentViewController:[FRSAlertViewManager
                                         alertControllerWithTitle:@"Invalid Password"
                                         message:@"Please enter a password that is 6 characters or longer" action:DISMISS]
                               animated:YES
                             completion:nil];
            
         
            
            return;
        }
        //If the password is valid, check if the password fields match
        else if(![self.textfieldNewPassword.text isEqualToString:self.textfieldConfirmPassword.text]){
            
            [self presentViewController:[FRSAlertViewManager
                                         alertControllerWithTitle:PASSWORD_ERROR_TITLE
                                         message:PASSWORD_ERROR_MESSAGE
                                         action:DISMISS]
                               animated:YES
                             completion:nil];

            return;
        }
       
    }
    
    [self.saveChangesbutton toggleSpinner];
    
    [updateParams setObject:[NSString stringWithFormat:@"%d", (int)self.radiusStepper.value] forKey:@"radius"];
    
    NSData *imageData = nil;
    
    if(self.selectedImage) {
        
        imageData = UIImageJPEGRepresentation(self.selectedImage, 0.5);
    }
    
    [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:imageData block:^(BOOL success, NSError *error) {
        
        if (!success) {
            
            [self.saveChangesbutton toggleSpinner];
                        
            [self presentViewController:[FRSAlertViewManager
                                         alertControllerWithTitle:ERROR
                                         message:PROFILE_SETTINGS_SAVE_ERROR
                                         action:DISMISS handler:nil]
                               animated:YES
                             completion:nil];
            
        
        }
        // On success, run password check
        else {
            
            //Tells the ProfileHeaderViewController to update it's view
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_UPDATE_PROFILE_HEADER];
            
            if (self.selectedImage){
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_IMAGE_SET object:nil];
            }
            
            //If the password field is set, reset it via parse
            if ([self.textfieldNewPassword.text length]) {
                
                [PFUser currentUser].password = self.textfieldNewPassword.text;
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    [self.saveChangesbutton toggleSpinner];
                    
                    //If the save fails
                    if(!succeeded){
                        
                        //Run check in case settings are saved in pop
                        if (self.isViewLoaded && self.view.window) {
                            // viewController is visible
                            [self presentViewController:[FRSAlertViewManager
                                                         alertControllerWithTitle:ERROR
                                                         message:PASSWORD_SAVE_ERROR
                                                         action:DISMISS handler:nil]
                                               animated:YES
                                             completion:nil];
                        }

                    
                    }
                    //The save is successful
                    else{

                        [self.navigationController popViewControllerAnimated:YES];
                    
                    }
                }];
                
            }
            //No passwords are set, pop back
            else{
            
                [self.saveChangesbutton toggleSpinner];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    
    // send a second post to save the radius -- ignore success
    [updateParams removeAllObjects];

}

#pragma mark - IBActions

- (IBAction)connectFacebook:(id)sender
{
    [self socialConnect:SocialNetworkFacebook networkButton:self.connectFacebookButton];
}

- (IBAction)connectTwitter:(id)sender
{
    [self socialConnect:SocialNetworkTwitter networkButton:self.connectTwitterButton];
}

- (IBAction)logOut:(id)sender {
    
    UIAlertController *logOutAlertController = [FRSAlertViewManager alertControllerWithTitle:@"Are you sure?" message:@"" action:CANCEL];
    
    [logOutAlertController addAction:[UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [[FRSDataManager sharedManager] logout];
        
        FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
        
        [rvc setRootViewControllerToHighlights];
        
        [self.navigationController popViewControllerAnimated:NO];
        
    }]];
    
    [self presentViewController:logOutAlertController animated:YES completion:nil];
}

- (IBAction)addCard:(id)sender {
    
    ProfilePaymentSettingsViewController *paymentSettings = [[ProfilePaymentSettingsViewController alloc] init];
    
    [self.navigationController pushViewController:paymentSettings animated:YES];
    
}

- (IBAction)disableAccount:(id)sender {

    [self disableAcctWithSocialNetwork:nil];
}

- (IBAction)saveChangeClicked:(id)ender
{
    [self saveChanges];
}

#pragma mark - UISilder Delegate and Actions

- (IBAction)sliderValueChanged:(UISlider *)slider
{
    CGFloat roundedValue = [MKMapView roundedValueForRadiusSlider:slider];
    
    if(roundedValue > 0){
        
        NSString *pluralizer = (roundedValue > 1 || roundedValue == 0) ? @"s" : @"";
    
        NSString *newValue = [NSString stringWithFormat:@"%2.0f mile%@", roundedValue, pluralizer];
        
        // only update changes
        if (![self.radiusStepperLabel.text isEqualToString:newValue])
            self.radiusStepperLabel.text = newValue;
        
    }
    else {
        self.radiusStepperLabel.text = OFF;
    }
}

- (IBAction)sliderTouchUpInside:(UISlider *)slider
{
    [self.saveChangesbutton updateSaveState:SaveStateEnabled];
    
    self.radiusStepper.value = [MKMapView roundedValueForRadiusSlider:slider];
    
    [self.mapView updateUserLocationCircleWithRadius:self.radiusStepper.value];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    
    [self.saveChangesbutton updateSaveState:SaveStateEnabled];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.textfieldFirst) {
        [self.textfieldLast becomeFirstResponder];
    }
    if (textField == self.textfieldLast) {
        [self.textfieldLast resignFirstResponder];
    }
    
    if (textField == self.textfieldNewPassword) {
        [self.textfieldConfirmPassword becomeFirstResponder];
    }
    
    if (textField == self.textfieldConfirmPassword) {
        [self.textfieldConfirmPassword resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!self.locationUpdated){
        [mapView updateUserLocationCircleWithRadius:self.radiusStepper.value];
        self.locationUpdated = YES;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    return [MKMapView radiusRendererForOverlay:overlay withImagePicker:self.picker];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //If the annotiation is for the user location
    if (annotation == mapView.userLocation)
        return [self.mapView setupUserPinForAnnotation:annotation];
    
    return nil;
}


#pragma mark - UIImagePickerController Delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        viewController.navigationItem.title = AVATAR_PROMPT;
        navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.54];
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar-background"] forBarMetrics:UIBarMetricsDefault];
    }
}

-(void)tapDetected {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    self.selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    self.profileImageView.image = self.selectedImage;
    
    [self.saveChangesbutton updateSaveState:SaveStateEnabled];
    
    [self.mapView updateUserPinViewForMapView:self.mapView withImage:self.selectedImage];
    self.picker = [MKMapView createDBImageColorPickerForUserWithImage:self.selectedImage];
    [self.mapView userRadiusUpdated:@(self.radiusStepper.value)];

    // Code here to work with media
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
