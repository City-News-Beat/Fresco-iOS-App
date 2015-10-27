//
//  GalleryPostViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Parse;
@import FBSDKCoreKit;
@import AssetsLibrary;
@import Photos;
#import <AFNetworking.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "GalleryPostViewController.h"
#import "GalleryView.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "FRSTabBarController.h"
#import "FRSCamViewController.h"
#import "FRSDataManager.h"
#import "FirstRunViewController.h"
#import "FRSSocialButton.h"
#import "FRSRootViewController.h"
#import "FRSUploadManager.h"

@interface GalleryPostViewController () <UITextViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
@property (weak, nonatomic) IBOutlet FRSSocialButton *twitterButton;
@property (weak, nonatomic) IBOutlet FRSSocialButton *facebookButton;

@property (weak, nonatomic) IBOutlet UIView *assignmentView;
@property (weak, nonatomic) IBOutlet UILabel *assignmentLabel;
@property (weak, nonatomic) IBOutlet UIButton *linkAssignmentButton;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *socialTipView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterHeightConstraint;

@property (strong, nonatomic) FRSAssignment *defaultAssignment;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UITapGestureRecognizer *socialTipTap;
@property (strong, nonatomic) UITapGestureRecognizer *submitTap;

@end

@implementation GalleryPostViewController

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupButtons];
    
    self.title = @"Create a Gallery";
    
    self.navigationController.navigationBar.tintColor = [UIColor textHeaderBlackColor];
    
    [self.galleryView setGallery:self.gallery shouldBeginPlaying:YES withDynamicAspectRatio:NO];
    
    self.captionTextView.delegate = self;
    self.captionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.captionTextView setTextContainerInset:UIEdgeInsetsMake(5, 5, 0, 0)];
    self.captionTextView.returnKeyType = UIReturnKeyDone;
    
    [self.socialTipView setUserInteractionEnabled:YES];
    
    [self.facebookButton setUpSocialIcon:SocialNetworkFacebook withRadius:NO];
    [self.twitterButton setUpSocialIcon:SocialNetworkTwitter withRadius:NO];
    
    self.socialTipTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateSocialTipView)];
    [self.socialTipView addGestureRecognizer:self.socialTipTap];
    
    self.submitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitGalleryPost:)];
    [self.navigationController.toolbar addGestureRecognizer:self.submitTap];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *captionString = [defaults objectForKey:@"captionStringInProgress"];
        
        self.captionTextView.text = captionString.length ? captionString : WHATS_HAPPENING;
        
        if ([PFUser currentUser]) {
            
            self.twitterButton.hidden = NO;
            self.facebookButton.hidden = NO;
            
            self.twitterButton.selected = [defaults boolForKey:@"twitterButtonSelected"] && [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]];
            self.facebookButton.selected = [defaults boolForKey:@"facebookButtonSelected"] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
            self.socialTipView.hidden = [defaults boolForKey:UD_GALLERY_POSTED];
            
        }
        else {
            self.twitterButton.hidden = YES;
            self.facebookButton.hidden = YES;
            self.socialTipView.hidden = YES;
        }
        
    });

    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_GALLERY_POSTED];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self toggleToolbarAppearance];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
   
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
    
    //Turn off any video
    [self.galleryView cleanUpVideoPlayer];
    
    [self.captionTextView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Setup

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:CANCEL
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(rightBarButtonItemClicked:)];
}

- (void)configureControlsForUpload:(BOOL)upload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.view.userInteractionEnabled = !upload;
        self.navigationController.navigationBar.userInteractionEnabled = !upload;
        self.navigationController.toolbar.userInteractionEnabled = !upload;
        self.navigationController.interactivePopGestureRecognizer.enabled = !upload;
        
    });
}

#pragma mark - Toolbar Items

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title =  [[UIBarButtonItem alloc] initWithTitle:GALLERY_TOOLBAR
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(submitGalleryPost:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:self
                                                                           action:@selector(submitGalleryPost:)];

    return @[space, title, space];
}


#pragma mark - Navigational Methods

-(void)rightBarButtonItemClicked:(id)sender{

    [self returnToTabBarWithPrevious:YES];
}

/**
 *  Returns to tab bar
 *
 *  @return Takes option of returning to previously selected tab
 */

-(void)returnToTabBarWithPrevious:(BOOL)previous{
    
    FRSTabBarController *tabBarController = ((FRSRootViewController *)self.presentingViewController.presentingViewController).tbc;
    
    if (previous) {

        tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:UD_PREVIOUSLY_SELECTED_TAB];
    }
    else {
        tabBarController.selectedIndex = 4;
    }
    
    [tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (void)returnToCamera:(id)sender
{
    
    self.presentingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)twitterButtonTapped:(FRSSocialButton *)button
{
    [self updateSocialTipView];
    
    if (!button.isSelected && ![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        UIAlertController *alertCon = [FRSAlertViewManager
                                       alertControllerWithTitle:@"Whoops"
                                       message:@"It seems like you're not connected to Twitter, click \"Connect\" if you'd like to connect Fresco with Twitter"
                                       action:@"Cancel" handler:^(UIAlertAction *action) {
                                           button.selected = NO;
                                       }];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //Run Twitter link
            [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                
                if(error){
                    
                    [self presentViewController:[FRSAlertViewManager
                                                 alertControllerWithTitle:@"Error"
                                                 message:@"We were unable to link your Twitter account!"
                                                 action:nil]
                                       animated:YES
                                     completion:^{
                                         button.selected = NO;
                                     }];
                    
                }
            }];
            
        }]];
        
        //Bring up alert view
        [self presentViewController:alertCon animated:YES completion:nil];
        
    } else {

        [[NSUserDefaults standardUserDefaults] setBool:button.isSelected forKey:@"twitterButtonSelected"];
    }

    button.selected = !button.isSelected;

}

- (IBAction)facebookButtonTapped:(FRSSocialButton *)button
{
    [self updateSocialTipView];
    
    if (!button.isSelected && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        UIAlertController *alertCon = [FRSAlertViewManager
                                       alertControllerWithTitle:@"Whoops"
                                       message:@"It seems like you're not connected to Facebook, click \"Connect\" if you'd like to connect Fresco with Facebook"
                                       action:@"Cancel" handler:^(UIAlertAction *action) {
                                           button.selected = NO;
                                       }];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //Run Facebook link
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
                
                if(error){
                
                    [self presentViewController:[FRSAlertViewManager
                                                 alertControllerWithTitle:ERROR
                                                 message:@"We were unable to link your Facebook account!"
                                                 action:nil]
                                       animated:YES
                                     completion:^{
                                         button.selected = NO;
                                     }];
                
                }

            }];
            
        }]];
        
        //Bring up alert view
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }
    else{
    
        [[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:@"facebookButtonSelected"];
    
    }

    button.selected = !button.isSelected;

}

- (IBAction)linkAssignmentButtonTapped:(id)sender
{
    if (self.defaultAssignment) {
        
        UIAlertController *alertCon = [FRSAlertViewManager
                                       alertControllerWithTitle:@"Remove Assignment?"
                                       message:@"Are you sure you want remove this assignment?"
                                       action:CANCEL handler:nil];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            
            [self toggleAssignment:NO];
            
        }]];
        
        [self presentViewController:alertCon animated:YES completion:nil];

    }
    else {
        [self toggleAssignment:NO];
    }
}

#pragma mark - Controller Methods

- (void)crossPostToTwitter:(NSString *)string {
    
    if (!self.twitterButton.selected) {
        return;
    }
    
    [[FRSUploadManager sharedManager] postToTwitter:string];
}

- (void)crossPostToFacebook:(NSString *)string
{
    if (!self.facebookButton.selected) {
        return;
    }
    
    [[FRSUploadManager sharedManager] postToFacebook:string];

}

- (void)updateSocialTipView {
 
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.socialTipView.hidden == NO) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.socialTipView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
              self.socialTipView.hidden = YES;
            
            }];
        }
        
    });
}

- (void)setDefaultAssignment:(FRSAssignment *)defaultAssignment
{
    _defaultAssignment = defaultAssignment;
    
    self.linkAssignmentButton.hidden = NO;
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Taken for %@", self.defaultAssignment.title]];
    
    [titleString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0]}
                         range:(NSRange){10, [titleString length] - 10}];
    
    self.assignmentLabel.attributedText = titleString;
    
}

/**
 *  Finds assignments in location and updates banner in view controller
 *
 *  @param location The location to look for assignments in
 */

- (void)configureAssignmentForLocation:(CLLocation *)location
{
    
    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:50 ofLocation:location.coordinate withResponseBlock:^(id responseObject, NSError *error) {

        // Find a photo that is within an assignment radius
        for (FRSPost *post in self.gallery.posts) {
            
            CLLocation *location = post.image.asset.location;
            
            if(location != nil){
                
                for (FRSAssignment *assignment in responseObject) {
                    if ([assignment.locationObject distanceFromLocation:location] / kMetersInAMile <= [assignment.radius floatValue] ) {
                        self.defaultAssignment = assignment;
                        [self toggleAssignment:YES];
                        return;
                    }
                }
            }
        }

        // No matching assignment found
        self.defaultAssignment = nil;
        
    }];
}

/**
 *  Displays assignment banner
 *
 *  @param show Takes BOOL to hide or show assignment banner
 */

- (void)toggleAssignment:(BOOL)show{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(show){
            self.assignmentView.alpha = show ? 0 : 1;
            self.assignmentView.frame = CGRectOffset(self.assignmentView.frame, 0, -3);
            self.assignmentView.hidden = !show;
        }
        
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

            self.assignmentView.alpha = show ? 1 : 0;
            self.assignmentView.frame = CGRectOffset(self.assignmentView.frame, 0, (show ? 3 : -3));
       
        } completion:^(BOOL finished) {
            
            if (!show) {
                self.defaultAssignment = nil;
            }
            
        }];
        
    });
}

/**
 *  Uploads controllers gallery
 *
 *  @param sender Sender property
 */

- (void)submitGalleryPost:(id)sender
{
    [self updateSocialTipView];
    
    //First check if the caption is valid
    if([self.captionTextView.text isEqualToString:WHATS_HAPPENING] || [self.captionTextView.text  isEqual: @""]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (![self.captionTextView isFirstResponder]) {
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = 0.8;
                animation.values = @[@(-8), @(8), @(-6), @(6), @(-4), @(4), @(-2), @(2), @(0)];
                [self.captionTextView.layer addAnimation:animation forKey:@"shake"];
            }
            
        });
      
        return;
    
    }
    //Check if there are less than the max amount of posts
    else if([self.gallery.posts count] > MAX_POST_COUNT){
    
        [self presentViewController:[FRSAlertViewManager
                                     alertControllerWithTitle:ERROR
                                     message:MAX_POST_ERROR
                                     action:nil]
                           animated:YES
                         completion:nil];
        
        return;
    
    }
    //Check if the user is logged in before proceeding, send to sign up otherwise
    else if (![[FRSDataManager sharedManager] currentUserIsLoaded]) {
        
        [self navigateToFirstRun];
        
        return;
    }
    
    /**
    *** All conditions passed for upload
    **/
    
    //Run the spinner animation to indicate that upload has started
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect spinnerFrame = CGRectMake(0, 0, 20, 20);
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
        self.spinner.center = CGPointMake(self.navigationController.toolbar.frame.size.width  / 2, self.navigationController.toolbar.frame.size.height / 2);
        self.spinner.color = [UIColor whiteColor];
        [self.spinner startAnimating];
        
        self.navigationController.toolbar.items[1].title = @"";
        [self.navigationController.toolbar addSubview:self.spinner];
        
    });
    
    [self configureControlsForUpload:YES];
    
    self.gallery.caption = self.captionTextView.text;
    
    [[FRSUploadManager sharedManager] uploadGallery:self.gallery withAssignment:self.defaultAssignment withResponseBlock:^(BOOL success, NSError *error) {
       
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.spinner stopAnimating];
//            [self.spinner removeFromSuperview];
//            self.navigationController.toolbar.items[1].title = GALLERY_TOOLBAR;
//        });
        
        if (!success || error) {
            
            [self configureControlsForUpload:NO];
            
            [self presentViewController:[FRSAlertViewManager
                                         alertControllerWithTitle:UPLOAD_ERROR_TITLE
                                         message:UPLOAD_ERROR_MESSAGE action:DISMISS]
                               animated:YES completion:nil];
            
        }
        else {
    
//            // TODO: Handle error conditions
//            NSString *crossPostString = [NSString stringWithFormat:@"Just posted a gallery to @fresconews: http://fresconews.com/gallery/%@", [[responseObject objectForKey:@"data"] objectForKey:@"_id"]];
//            
//            [self crossPostToTwitter:crossPostString];
//            
//            [self crossPostToFacebook:crossPostString];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_UPDATE_USER_GALLERIES];
            
            [[FRSUploadManager sharedManager] resetDraftGalleryPost];
            
            [self returnToTabBarWithPrevious:NO];
        
        }
        
    }];

}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateSocialTipView];
    
    if ([textView.text isEqualToString:WHATS_HAPPENING])
        textView.text = @"";
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""])
        textView.text = WHATS_HAPPENING;
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }

    [textView resignFirstResponder];
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    [self toggleToolbarAppearance];
    
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"captionStringInProgress"];
}

#pragma mark - UIToolBar Appearance

- (void)toggleToolbarAppearance {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        UIColor *textViewColor = [UIColor darkGrayColor];
        UIColor *toolbarColor = [UIColor greenToolbarColor];
        
        if ([self.captionTextView.text length] == 0 || [self.captionTextView.text isEqualToString:WHATS_HAPPENING]) {
            
            toolbarColor = [UIColor disabledToolbarColor];
            
            textViewColor = [UIColor lightGrayColor];
        }
        
        self.navigationController.toolbar.barTintColor = toolbarColor;
        
        [self.captionTextView setTextColor:textViewColor];
        
    });
}


#pragma mark - Notification Delegate

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            
                            CGRect viewFrame = self.view.frame;
                            
                            CGRect toolBarFrame = self.navigationController.toolbar.frame;
                            
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                
                                viewFrame.origin.y -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                                
                                toolBarFrame.origin.y -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                                
                                self.navigationController.toolbar.frame = toolBarFrame;
                                
                                self.view.frame = viewFrame;
                                
                            }
                            else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])  {
                                
                                viewFrame.origin.y = 64;
                                
                                toolBarFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 44;
                                
                                self.navigationController.toolbar.frame = toolBarFrame;
                                
                                self.view.frame = viewFrame;
                                
                            }
                            
                        } completion:nil];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    [self configureAssignmentForLocation:[locations lastObject]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
    
        UIAlertController *alertCon = [FRSAlertViewManager
                                       alertControllerWithTitle:@"Access to Location Disabled"
                                       message:@"Fresco uses your location in order to submit a gallery to an assignment. Please enable it through the Fresco app settings"
                                       action:DISMISS handler:nil];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }]];
        
        [self presentViewController:alertCon animated:YES completion:nil];
        
        [self.locationManager stopUpdatingLocation];
    }
}


@end
