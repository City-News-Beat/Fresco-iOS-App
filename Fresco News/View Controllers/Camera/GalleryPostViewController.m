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
#import <AFNetworking.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "GalleryPostViewController.h"
#import "GalleryView.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "FRSTabBarController.h"
#import "CameraViewController.h"
#import "FRSDataManager.h"
#import "FirstRunViewController.h"
#import "CrossPostButton.h"
#import "UIImage+ALAsset.h"
#import "ALAsset+assetType.h"
#import "MKMapView+Additions.h"
#import "UIViewController+Additions.h"
#import "FRSRootViewController.h"

@interface GalleryPostViewController () <UITextViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
@property (weak, nonatomic) IBOutlet CrossPostButton *twitterButton;
@property (weak, nonatomic) IBOutlet CrossPostButton *facebookButton;

@property (weak, nonatomic) IBOutlet UIView *assignmentView;
@property (weak, nonatomic) IBOutlet UILabel *assignmentLabel;
@property (weak, nonatomic) IBOutlet UIButton *linkAssignmentButton;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterHeightConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *assignmentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *socialTipView;


// Refactor
@property (strong, nonatomic) FRSAssignment *defaultAssignment;
@property (strong, nonatomic) NSArray *assignments;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GalleryPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setFrescoNavigationBar];
    [self setupButtons];

    self.title = @"Create a Gallery";
    [self.galleryView setGallery:self.gallery isInList:YES];
    self.captionTextView.delegate = self;
    self.captionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // TODO: Confirm permissions
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.socialTipView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateSocialTipView)];
    
    [self.socialTipView addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.locationManager startUpdatingLocation];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *captionString = [defaults objectForKey:@"captionStringInProgress"];
    self.captionTextView.text = captionString.length ? captionString : WHATS_HAPPENING;

    if ([PFUser currentUser]) {
        self.twitterButton.hidden = NO;
        self.facebookButton.hidden = NO;
        self.twitterButton.selected = [defaults boolForKey:@"twitterButtonSelected"] && [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]];
        self.facebookButton.selected = [defaults boolForKey:@"facebookButtonSelected"] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
        self.twitterHeightConstraint.constant = self.navigationController.toolbar.frame.size.height;

        BOOL hideCrosspostingHelp = [defaults boolForKey:@"galleryPreviouslyPosted"];
        self.socialTipView.hidden = hideCrosspostingHelp;
    }
    else {
        self.twitterButton.hidden = YES;
        self.facebookButton.hidden = YES;
        self.twitterHeightConstraint.constant = 0;

        self.socialTipView.hidden = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"galleryPreviouslyPosted"];
    

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Turn off any video
    [self disableVideo];
    
    [self.captionTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 ** Disable any playing video
 */

- (void)disableVideo{
    
    [self.galleryView cleanUpVideoPlayer];
    
}

#pragma mark - UI Setup

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(returnToCamera:)];
}

- (void)configureControlsForUpload:(BOOL)upload
{
    self.uploadProgressView.hidden = !upload;
    self.view.userInteractionEnabled = !upload;
    self.navigationController.navigationBar.userInteractionEnabled = !upload;
    self.navigationController.toolbar.userInteractionEnabled = !upload;
    self.navigationController.interactivePopGestureRecognizer.enabled = !upload;
}

#pragma mark - Navigational Methods

- (void)returnToTabBar{
    
    FRSTabBarController *tabBarController = ((FRSRootViewController *)self.presentingViewController.presentingViewController).tbc;
    
    tabBarController.selectedIndex = 4;
    
    [tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (void)returnToCamera:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Outlet Actions

- (IBAction)twitterButtonTapped:(CrossPostButton *)button
{
    [self updateSocialTipView];
    
    if (!button.isSelected && ![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        UIAlertController *alertCon = [[FRSAlertViewManager sharedManager]
                                       alertControllerWithTitle:@"Whoops"
                                       message:@"It seems like you're not connected to Twitter, click \"Connect\" if you'd like to connect Fresco with Twitter"
                                       action:@"Cancel" handler:^(UIAlertAction *action) {
                                           button.selected = NO;
                                       }];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //Run Twitter link
            [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                
                if(error){
                    
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
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

- (IBAction)facebookButtonTapped:(CrossPostButton *)button
{
    [self updateSocialTipView];
    
    if (!button.isSelected && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        UIAlertController *alertCon = [[FRSAlertViewManager sharedManager]
                                       alertControllerWithTitle:@"Whoops"
                                       message:@"It seems like you're not connected to Facebook, click \"Connect\" if you'd like to connect Fresco with Facebook"
                                       action:@"Cancel" handler:^(UIAlertAction *action) {
                                           button.selected = NO;
                                       }];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //Run Facebook link
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
                
                if(error){
                
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Assignment"
                                                        message:@"Are you sure you want remove this assignment?"
                                                       delegate:self
                                              cancelButtonTitle:CANCEL
                                              otherButtonTitles:@"Remove", nil];
        
        [alert show];
    }
    else {
        [self showAssignment:NO];
    }
}


- (void)crossPostToTwitter:(NSString *)string {
    
    if (!self.twitterButton.selected) {
        return;
    }
    
    string = [NSString stringWithFormat:@"status=%@", string];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    tweetRequest.HTTPMethod = @"POST";
    tweetRequest.HTTPBody = [[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] dataUsingEncoding:NSUTF8StringEncoding];
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
    
    [NSURLConnection sendAsynchronousRequest:tweetRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            // TODO: Notify the user
            NSLog(@"Error crossposting to Twitter: %@", connectionError);
        }
        else {
            NSLog(@"Success crossposting to Twitter: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
}

- (void)updateSocialTipView {
 
    if (self.socialTipView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.socialTipView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
          self.socialTipView.hidden = YES;
        
        }];
    }
}

- (void)crossPostToFacebook:(NSString *)string
{
    if (!self.facebookButton.selected) {
        return;
    }

    if (YES /* TODO: Fix [[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"] */) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
                                           parameters: @{@"message" : string}
                                           HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error) {
                // TODO: Notify the user
                NSLog(@"Error crossposting to Facebook");
            }
            else {
                NSLog(@"Success crossposting to Facebook: Post id: %@", result[@"id"]);
            }
        }];
    }
}

- (void)setDefaultAssignment:(FRSAssignment *)defaultAssignment
{
    _defaultAssignment = defaultAssignment;
    [self configureAssignmentLabelForAssignment:defaultAssignment];
}

- (void)configureAssignmentLabelForAssignment:(FRSAssignment *)assignment
{
    self.linkAssignmentButton.hidden = NO;
    if (assignment) {
        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Taken for %@", assignment.title]];
        [titleString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0]}
                             range:(NSRange){10, [titleString length] - 10}];
        self.assignmentLabel.attributedText = titleString;
        [self.linkAssignmentButton setImage:[UIImage imageNamed:@"delete-small-white"] forState:UIControlStateNormal];
    }
}

- (void)configureAssignmentForLocation:(CLLocation *)location
{
    // TODO: Add support for expiring/expired assignments
    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:50 ofLocation:location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
        self.assignments = responseObject;

        // Find a photo that is within an assignment radius
        for (FRSPost *post in self.gallery.posts) {
            CLLocation *location = [post.image.asset valueForProperty:ALAssetPropertyLocation];
            if(location != nil){
                for (FRSAssignment *assignment in self.assignments) {
                    if ([assignment.locationObject distanceFromLocation:location] / kMetersInAMile <= [assignment.radius floatValue] ) {
                        self.defaultAssignment = assignment;
                        [self showAssignment:YES];
                        return;
                    }
                }
            }
        }

        // No matching assignment found
        self.defaultAssignment = nil;
    }];
}

- (void)showAssignment:(BOOL)show
{
    if (!show) {
        self.defaultAssignment = nil;
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.assignmentViewHeightConstraint.constant = show ? 40 : 0;
        self.assignmentView.hidden = !show;
        self.assignmentLabel.hidden = !show;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleButtonItem
{
    // TODO: Capture all UIToolbar touches
    return [[UIBarButtonItem alloc] initWithTitle:@"Send to Fresco"
                                            style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(submitGalleryPost:)];
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:nil
                                                         action:nil];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title = [self titleButtonItem];
    UIBarButtonItem *space = [self spaceButtonItem];
    return @[space, title, space];
}

- (void)submitGalleryPost:(id)sender
{
    [self updateSocialTipView];
    
    //First check if the caption is valid
    if([self.captionTextView.text isEqualToString:WHATS_HAPPENING] || [self.captionTextView.text  isEqual: @""]){
        
        if (![self.captionTextView isFirstResponder]) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.duration = 0.8;
            animation.values = @[@(-8), @(8), @(-6), @(6), @(-4), @(4), @(-2), @(2), @(0)];
            [self.captionTextView.layer addAnimation:animation forKey:@"shake"];
        }
      
        return;
    
    }
    
    //Check if the user is logged in before proceeding, send to sign up otherwise
    if (![[FRSDataManager sharedManager] currentUserIsLoaded]) {
        
        if(self.presentingViewController.presentingViewController){
        
            [self navigateToFirstRun];
        
        }
        
        return;
    }

    if([self.gallery.posts count] > MAX_POST_COUNT){
    
        [self presentViewController:[[FRSAlertViewManager sharedManager]
                                     alertControllerWithTitle:@"Error"
                                     message:@"Galleries can only contain up to 8 photos or videos." action:nil]
                           animated:YES completion:nil];
        
        return;
    
    }
    
    [self configureControlsForUpload:YES];
    
    NSString *urlString = [[FRSDataManager sharedManager] endpointForPath:@"gallery/assemble"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSProgress *progress = nil;
    NSError *error;

    NSMutableDictionary *postMetadata = [NSMutableDictionary new];
    
    for (NSInteger i = 0; i < self.gallery.posts.count; i++) {
        
        NSString *filename = [NSString stringWithFormat:@"file%@", @(i)];

        FRSPost *post = self.gallery.posts[i];
        
        NSTimeInterval postTime = round([post.createdDate timeIntervalSince1970] * 1000);
        
        postMetadata[filename] = @{ @"type" : post.type,
                                    @"lat" : post.image.latitude,
                                    @"lon" : post.image.longitude,
                                    @"timeCaptured" : [NSString stringWithFormat:@"%ld",(long)postTime]
                                };
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postMetadata
                                                       options:(NSJSONWritingOptions)0
                                                         error:&error];

    NSDictionary *parameters = @{ @"owner" : [FRSDataManager sharedManager].currentUser.userID,
                                  @"caption" : self.captionTextView.text ?: [NSNull null],
                                  @"posts" : jsonData,
                                  @"assignment" : self.defaultAssignment.assignmentId ?: [NSNull null] };

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:urlString
                                                                                             parameters:parameters
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger count = 0;
        
      for (FRSPost *post in self.gallery.posts) {
          
            NSString *filename = [NSString stringWithFormat:@"file%@", @(count)];
            NSData *data;
            NSString *mimeType;

            if (post.image.asset.isVideo) {
                ALAssetRepresentation *representation = [post.image.asset defaultRepresentation];
                UInt8 *buffer = malloc((unsigned long)representation.size);
                NSUInteger buffered = [representation getBytes:buffer fromOffset:0 length:(NSUInteger)representation.size error:nil];
                data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                mimeType = @"video/mp4";
            }
            else {
                data = UIImageJPEGRepresentation([UIImage imageFromAsset:post.image.asset], 1.0);
                mimeType = @"image/jpeg";
            }

            [formData appendPartWithFileData:data
                                        name:filename
                                    fileName:filename
                                    mimeType:mimeType];
            count++;
        }
                                                                                  
    } error:nil];

    [request setValue:[FRSDataManager sharedManager].frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                       progress:&progress
                                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *uploadError) {
        if (uploadError) {
            
            NSLog(@"Error posting to Fresco: %@", uploadError);
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self configureControlsForUpload:NO];
                
                [self presentViewController:[[FRSAlertViewManager sharedManager]
                                             alertControllerWithTitle:@"Failed"
                                             message:@"Please try again later" action:nil]
                                   animated:YES completion:nil];
                
            });
        }
        else {
            
            NSLog(@"Success posting to Fresco: %@ %@", response, responseObject);
            
            @try{
                
                // TODO: Handle error conditions
                NSString *crossPostString = [NSString stringWithFormat:@"Just posted a gallery to @fresconews: http://fresconews.com/gallery/%@", [[responseObject objectForKey:@"data"] objectForKey:@"_id"]];
                
                [self crossPostToTwitter:crossPostString];
                
                [self crossPostToFacebook:crossPostString];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_UPDATE_USER_GALLERIES];
                
                [[FRSDataManager sharedManager] resetDraftGalleryPost];
                
                [self returnToTabBar];
                
            }
            @catch(NSException *exception){
                NSLog(@"%@", exception);
            }


        }
    }];

    [uploadTask resume];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)showUploadProgress:(CGFloat)fractionCompleted
{
    
    [UIView animateWithDuration:1 animations:^{
        [self.uploadProgressView setProgress:fractionCompleted animated:YES];
    }];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        // NSLog(@"Progress... %f", progress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUploadProgress:progress.fractionCompleted];
        });
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UITextViewDelegate methods


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

- (void)toggleToolbarAppearance {
    
    UIColor *textViewColor = [UIColor darkGrayColor];
    UIColor *toolbarColor = [UIColor greenToolbarColor];
    
    if ([self.captionTextView.text length] == 0 || [self.captionTextView.text isEqualToString:WHATS_HAPPENING]) {
        
        toolbarColor = [UIColor disabledToolbarColor];
        
        textViewColor = [UIColor lightGrayColor];
    }
    self.navigationController.toolbar.barTintColor = toolbarColor;
    
    [self.captionTextView setTextColor:textViewColor];
}

- (void)textViewDidChange:(UITextView *)textView
{

    [self toggleToolbarAppearance];
    
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"captionStringInProgress"];
}

#pragma mark - Notification methods

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    
    
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            CGFloat height = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                            CGRect frame = self.navigationController.toolbar.frame;

                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                height *= -1;
                                frame.origin.y += height;
                                self.navigationController.toolbar.frame = frame;
                            }
                            else {
                                frame.origin.y += height;
                                self.navigationController.toolbar.frame = frame;
                                height = 0;
                            }

                            self.topVerticalSpaceConstraint.constant = height;
                            self.bottomVerticalSpaceConstraint.constant = height;
                            self.twitterVerticalConstraint.constant = -2 * height;
                            [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self showAssignment:NO];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    [self configureAssignmentForLocation:[locations lastObject]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // Undefined behavior
    [self.locationManager stopUpdatingLocation];
}

@end
