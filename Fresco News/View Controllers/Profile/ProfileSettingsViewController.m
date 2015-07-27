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
#import "MKMapView+Additions.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MapKit/MapKit.h>

@interface ProfileSettingsViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

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

/*
** UI Constraints
*/

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterIconCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookIconCenterXConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAccountVerticalBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAccountVerticalTop;
@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad{

    [super viewDidLoad];
    
    self.frsUser = [FRSDataManager sharedManager].currentUser;
    
    //TapGestureRecognizer for the profile picture, to bring up the MediaPickerController
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    
    //Checks if the user's primary login is through social
    if(([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] || [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) && self.frsUser.email == nil){
        
        [self.view viewWithTag:100].hidden = YES;
        [self.view viewWithTag:101].hidden = YES;
        [self.view viewWithTag:102].hidden = YES;

        self.constraintAccountVerticalTop.constant = 0;
        self.constraintAccountVerticalBottom.constant = 0;
        
        self.textfieldEmail.userInteractionEnabled = NO;
        self.textfieldNewPassword.userInteractionEnabled = NO;
        self.textfieldConfirmPassword.userInteractionEnabled = NO;

    }

    if (self.frsUser.cdnProfileImageURL) {
        [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.frsUser cdnProfileImageURL]]
                                     placeholderImage:[UIImage imageNamed:@"user"]
                                              success:nil failure:nil];
    }

    [self.profileImageView setUserInteractionEnabled:YES];
    [self.profileImageView addGestureRecognizer:singleTap];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLinkingStatus];
    
    self.frsUser = [FRSDataManager sharedManager].currentUser;

    // Radius slider values
    self.scrollView.alwaysBounceHorizontal = NO;

    self.textfieldFirst.text = self.frsUser.first;
    self.textfieldLast.text = self.frsUser.last;
    self.textfieldEmail.text = self.frsUser.email;

    self.radiusStepper.value = [self.frsUser.notificationRadius floatValue];

    // update the slider label
    [self sliderValueChanged:self.radiusStepper];
    
    self.connectTwitterButton.layer.cornerRadius = 4;
    self.connectTwitterButton.clipsToBounds = YES;
    
    self.connectFacebookButton.layer.cornerRadius = 4;
    self.connectFacebookButton.clipsToBounds = YES;

}

- (void)updateLinkingStatus {
    
    if (![PFUser currentUser]) {
        [self.connectTwitterButton setHidden:YES];
        [self.connectFacebookButton setHidden:YES];
    } else {
        [self.connectTwitterButton setHidden:NO];
        [self.connectFacebookButton setHidden:NO];
    
        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self.connectTwitterButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            self.twitterIconCenterXConstraint.constant = 45;
        } else {
            [self.connectTwitterButton setTitle:@"Connect" forState:UIControlStateNormal];
            self.twitterIconCenterXConstraint.constant = 35;
        }
    
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
        
        [PFFacebookUtils linkUserInBackground:[PFUser currentUser]
                       withPublishPermissions:@[@"publish_actions"]
                                        block:^(BOOL succeeded, NSError *error) {
                                            if (succeeded) {
                                                NSLog(@"Woohoo, user is linked with Facebook!");
                                            }
                                            else {
                                                NSLog(@"%@", error);
                                            }
                                            [spinner removeFromSuperview];
                                            [self updateLinkingStatus];
                                        }];
    }
    //Disconnect the user
    else {
        
        //Make sure the social account isn't their primary connector
        if([FRSDataManager sharedManager].currentUser.email != nil){
            
            [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"The user is no longer associated with their Facebook account.");
                }
                else {
                    NSLog(@"%@", error);
                }
                [spinner removeFromSuperview];
                [self updateLinkingStatus];
            }];
            
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"It seems like you logged in through Facebook. If you disconnect it, this would disable your account entirely!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            [spinner removeFromSuperview];
            [self updateLinkingStatus];
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
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
                NSLog(@"Woohoo, user logged in with Twitter!");
            }
            else {
                NSLog(@"%@", error);
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
                    NSLog(@"The user is no longer associated with their Twitter account.");
                }
                else {
                    NSLog(@"%@", error);
                }
                [spinner removeFromSuperview];
                [self updateLinkingStatus];
            }];
            
        }
        else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"It seems like you logged in through Twitter. If you disconnect it, this would disable your account entirely!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
            
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
    
    [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:imageData block:^(id responseObject, NSError *error) {

        if (error) {

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Could not save Profile settings"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            
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
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passwords do not match"
                                                                    message:@"Please make sure your new passwords are equal"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }
            }
            //If passwords are not reset, just go back
            else [self.navigationController popViewControllerAnimated:YES];

        }

    }];
    
    // send a second post to save the radius -- ignore success
    [updateParams removeAllObjects];
    
}

- (IBAction)changePassword:(UIButton *)sender
{
    NSString *email = self.textfieldEmail.text;
    if (![email length])
        email = [FRSDataManager sharedManager].currentUser.email;
    
    if ([email length]) {
        
        [PFUser requestPasswordResetForEmailInBackground:email
                                                   block:^(BOOL succeeded, NSError *error) {
                                                       if (!error) {
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                                                                           message:@"Email sent. Follow the instructions in the email to change your password."
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:@"Dismiss"
                                                                                                 otherButtonTitles:nil];
                                                           [alert show];
                                                       }
                                                       else {
                                                           NSLog(@"Error: %@", error);
                                                       }
                                                   }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter an email address"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)logOut:(id)sender
{
    [[FRSDataManager sharedManager] logout];
    [self navigateToMainApp];
}

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