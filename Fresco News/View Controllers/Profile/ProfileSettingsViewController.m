 //
//  ProfileSettingsViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 5/12/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ProfileSettingsViewController.h"
#import "FRSUser.h"
#import "FRSDataManager.h"
#import "FRSRootViewController.h"
#import "MKMapView+Additions.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MapKit/MapKit.h>
#import "MapViewOverlayBottom.h"
#import "MapOverlayTop.h"
#import <SVPulsingAnnotationView.h>

@interface ProfileSettingsViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

/***** In order of presentation *****/

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/*
** Social Connect Buttons
*/

@property (weak, nonatomic) IBOutlet UIButton *connectTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *connectFacebookButton;

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

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

/*
** Radius Setting
*/

@property (weak, nonatomic) IBOutlet UISlider *radiusStepper;
@property (weak, nonatomic) IBOutlet UILabel *radiusStepperLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapviewRadius;

@property (weak, nonatomic) IBOutlet MapOverlayTop *topMapOverlay;
@property (weak, nonatomic) IBOutlet MapViewOverlayBottom *bottomMapOverlay;

/*
** UI Constraints
*/

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterIconCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookIconCenterXConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAccountVerticalBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAccountVerticalTop;

/* Action Sheet */

@property (strong, nonatomic) UIActionSheet *disableAccountSheet;

@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad{

    [super viewDidLoad];
    
    //Checks if the user's primary login is through social, then disable the email and password fields
    if(([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] || [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
       && [FRSDataManager sharedManager].currentUser.email == nil){
        
        [self.view viewWithTag:100].hidden = YES;
        [self.view viewWithTag:101].hidden = YES;
        [self.view viewWithTag:102].hidden = YES;

        CGFloat y = -self.view.frame.size.height/5;
        self.constraintAccountVerticalTop.constant = y;
        self.constraintAccountVerticalBottom.constant = 0;
        
        self.textfieldEmail.userInteractionEnabled = NO;
        self.textfieldNewPassword.userInteractionEnabled = NO;
        self.textfieldConfirmPassword.userInteractionEnabled = NO;

    } else {
        self.constraintAccountVerticalTop.constant = [self.view viewWithTag:100].frame.size.height;
        self.constraintAccountVerticalBottom.constant = 0;
    }
    
    //Update the profile image
    if ([FRSDataManager sharedManager].currentUser.avatar != nil) {
        [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[[FRSDataManager sharedManager].currentUser avatarUrl]] placeholderImage:[UIImage imageNamed:@"user"]
                                              success:nil failure:nil];
    }

    //TapGestureRecognizer for the profile picture, to bring up the MediaPickerController
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    
    //Make the profile image interactive
    [self.profileImageView setUserInteractionEnabled:YES];
    [self.profileImageView addGestureRecognizer:singleTap];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    
    //Round the buttons
    self.connectTwitterButton.layer.cornerRadius = 4;
    self.connectTwitterButton.clipsToBounds = YES;
    
    self.connectFacebookButton.layer.cornerRadius = 4;
    self.connectFacebookButton.clipsToBounds = YES;
    
    //Update social connect buttons
    [self updateLinkingStatus];
    
    //Initialize Disable Account UIActionSheet
    self.disableAccountSheet = [[UIActionSheet alloc]
                            initWithTitle:@"Are you sure? You can recover your account up to one year from today."
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:@"Disable"
                            otherButtonTitles:nil];
    
    //Disable Account Sheet Tag
    self.disableAccountSheet.tag = 100;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Radius slider values
    self.scrollView.alwaysBounceHorizontal = NO;

    self.textfieldFirst.text = [FRSDataManager sharedManager].currentUser.first;
    self.textfieldLast.text = [FRSDataManager sharedManager].currentUser.last;
    self.textfieldEmail.text = [FRSDataManager sharedManager].currentUser.email;

    self.radiusStepper.value = [[FRSDataManager sharedManager].currentUser.notificationRadius floatValue];

    // update the slider label
    [self sliderValueChanged:self.radiusStepper];
}


- (void)updateLinkingStatus {
    
    if (![PFUser currentUser]) {
        [self.connectTwitterButton setHidden:YES];
        [self.connectFacebookButton setHidden:YES];
    }
    else {
        
        [self.connectTwitterButton setHidden:NO];
        
        [self.connectFacebookButton setHidden:NO];
    
        //Twitter
        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self.connectTwitterButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            self.twitterIconCenterXConstraint.constant = 45;
        }
        else {
            [self.connectTwitterButton setTitle:@"Connect" forState:UIControlStateNormal];
            self.twitterIconCenterXConstraint.constant = 35;
        }
    
        //Facebook
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self.connectFacebookButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            self.facebookIconCenterXConstraint.constant = 45;
        } else {
            [self.connectFacebookButton setTitle:@"Connect" forState:UIControlStateNormal];
            self.facebookIconCenterXConstraint.constant = 35;
        }
    }
    
}

- (IBAction)connectFacebook:(id)sender
{
    [self.connectFacebookButton setTitle:@"" forState:UIControlStateNormal];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, 20, (self.connectFacebookButton.frame.size.width), 7)];
    spinner.color = [UIColor whiteColor];
    [spinner startAnimating];
    
    [self.connectFacebookButton addSubview:spinner];

    //Conect the user
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
            
            //If fails, alert user
            if (!succeeded) {
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:@"Error"
                                             message:@"It seems you already have an account linked with Facebook."
                                             action:nil]
                                   animated:YES
                                 completion:nil];
            }
            
            [self updateLinkingStatus];
            [spinner removeFromSuperview];
            
        }];
    }
    //Disconnect the user
    else {
        
        //Make sure the social account isn't their primary connector
        if([FRSDataManager sharedManager].currentUser.email != nil){
            
            [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Success"
                                                 message:@"You've been disconnected from Facebook."
                                                 action:nil]
                                       animated:YES
                                     completion:nil];

                }
                else {
                    
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Error"
                                                 message:@"It seems you already have an account linked with Facebook."
                                                 action:nil]
                                       animated:YES
                                     completion:nil];
                }
                
                [self updateLinkingStatus];
                [spinner removeFromSuperview];
           
            }];
            
        }
        else{

            UIAlertController *alertCon = [[FRSAlertViewManager sharedManager]
                                           alertControllerWithTitle:@"Warning"
                                           message:@"It looks like you signed up with Facebook! Would you like to disable your account?"
                                           action:@"Cancel" handler:nil];
            
            [alertCon addAction:[UIAlertAction actionWithTitle:@"Disable" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                [self.disableAccountSheet showInView:self.view];
            }]];
            
            [self updateLinkingStatus];
            [spinner removeFromSuperview];
            
        }
    
    }

}

- (IBAction)connectTwitter:(id)sender
{
    [self.connectTwitterButton setTitle:@"" forState:UIControlStateNormal];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, 20, (self.connectTwitterButton.frame.size.width), 7)];
    spinner.color = [UIColor whiteColor];
    
    [spinner startAnimating];
    
    [self.connectTwitterButton addSubview:spinner];

    //Connect the user
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {

            if(!succeeded){
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:@"Error"
                                             message:@"It seems you already have an account linked with Twitter."
                                             action:nil]
                                   animated:YES
                                 completion:nil];
            
            }
            
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
            
        }];
        
    }
    //Disconnect the user
    else {
        
        //Make sure the social account isn't their primary connector
        if([FRSDataManager sharedManager].currentUser.email != nil){
            
            [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                
                if (!error && succeeded) {
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Success"
                                                 message:@"You've been disconnected from Twitter."
                                                 action:nil]
                                       animated:YES
                                     completion:nil];
                }
                else {
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Error"
                                                 message:@"It seems you already have an account linked with Twitter."
                                                 action:nil]
                                       animated:YES
                                     completion:nil];
                }
                
                [spinner removeFromSuperview];
                [self updateLinkingStatus];

            }];
            
        }
        else{
            
            UIAlertController *alertCon = [[FRSAlertViewManager sharedManager]
                                           alertControllerWithTitle:@"Warning"
                                           message:@"It looks like you signed up with Twitter! Would you like to disable your account?"
                                           action:@"Cancel" handler:nil];
            
            [alertCon addAction:[UIAlertAction actionWithTitle:@"Disable" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                [self.disableAccountSheet showInView:self.view];
            }]];
            
            [self presentViewController:alertCon animated:YES completion:nil];
            
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
            
        }
        
    }
}

- (IBAction)saveChanges:(id)sender
{
    
    NSMutableDictionary *updateParams = [[NSMutableDictionary alloc] initWithCapacity:5];
  
    if ([self.textfieldEmail.text length])
        [updateParams setObject:self.textfieldEmail.text forKey:@"email"];
        
    if ([self.textfieldFirst.text length])
        [updateParams setObject:self.textfieldFirst.text forKey:@"firstname"];
    
    if ([self.textfieldLast.text length])
        [updateParams setObject:self.textfieldLast.text forKey:@"lastname"];
 

    [updateParams setObject:[NSString stringWithFormat:@"%d", (int)self.radiusStepper.value] forKey:@"radius"];
    
    NSData *imageData = nil;
    
    if(self.selectedImage){
        
        imageData = UIImageJPEGRepresentation(self.selectedImage, 0.5);
    }
    
    [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:imageData block:^(BOOL success, NSError *error) {

        if (!success) {
            
            [self presentViewController:[[FRSAlertViewManager sharedManager]
                                         alertControllerWithTitle:@"Error"
                                         message:@"Could not save Profile settings"
                                         action:@"Dismiss" handler:^(UIAlertAction *handler){
                                             
                                             NSLog(@"ok");
                                             
                                         }]
                               animated:YES
                             completion:nil];
            
        }
        // On success, run password check
        else {
            
            //Tells the ProfileHeaderViewController to update it's view
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updateProfileHeader"];
            
            //If they are set, reset them via parse
            if ([self.textfieldNewPassword.text length]) {
                
                if([self.textfieldNewPassword.text isEqualToString:self.textfieldConfirmPassword.text]){
                    
                    [PFUser currentUser].password = self.textfieldNewPassword.text;
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                        
                        if(success) [self.navigationController popViewControllerAnimated:YES];
                    
                    }];
                    
                }
                else{
                    
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Passwords do not match"
                                                 message:@"Please make sure your new passwords are equals"
                                                 action:@"Dismiss"]
                                       animated:YES
                                     completion:nil];
                }
            }
            //If passwords are not reset, just go back
            else [self.navigationController popViewControllerAnimated:YES];

        }

    }];
    
    // send a second post to save the radius -- ignore success
    [updateParams removeAllObjects];
    
}

- (IBAction)logOut:(id)sender
{
    [[FRSDataManager sharedManager] logout];
    
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    
    [rvc setRootViewControllerToHighlights];
    
}

- (IBAction)disableAccount:(id)sender {
    
    [self.disableAccountSheet showInView:self.view];
    
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
    else{
        
        self.radiusStepperLabel.text = @"Off";
        
    }
}

- (IBAction)sliderTouchUpInside:(UISlider *)slider
{
    self.radiusStepper.value = [MKMapView roundedValueForRadiusSlider:slider];
    [self.mapviewRadius updateUserLocationCircleWithRadius:self.radiusStepper.value * kMetersInAMile];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView updateUserLocationCircleWithRadius:self.radiusStepper.value * kMetersInAMile];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    return [MKMapView circleRenderWithColor:[UIColor colorWithHex:@"#0077ff"] forOverlay:overlay];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *userIdentifier = @"currentLocation";
    
    //If the annotiation is for the user location
    
    if (annotation == mapView.userLocation) {
      
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:userIdentifier];
        
        if(!pinView){
        
            return [MKMapView setupPinForAnnotation:annotation withAnnotationView:pinView];

        }
    }
    
    return nil;
}

#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 100) {
        
        //Disable clicked
        if(buttonIndex == 0){
            
            [[FRSDataManager sharedManager] disableFrescoUser:^(BOOL success, NSError *error){
            
                if(success){
                    
                    [[FRSDataManager sharedManager] logout];
                    
                    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
                    
                    [rvc setRootViewControllerToHighlights];
                    
                }
                else{
                    
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Error"
                                                 message:@"It seems we couldn't successfully disable your account. Please contact support@fresconews.com for help."
                                                 action:nil]
                                       animated:YES
                                     completion:nil];
                
                }
                
            }];

        }
        //Cancel clicked
        else if(buttonIndex == 1){
            

        }
    }
}


#pragma mark - UIImagePickerController Delegate

-(void)tapDetected{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        viewController.navigationItem.title = @"Choose a new avatar";
        navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.54];
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar-background"] forBarMetrics:UIBarMetricsDefault];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    self.profileImageView.image = self.selectedImage;

    // Code here to work with media
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
