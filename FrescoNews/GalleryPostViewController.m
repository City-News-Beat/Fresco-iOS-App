//
//  GalleryPostViewController.m
//  FrescoNews
//
//  Created by Joshua Lerner on 4/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryPostViewController.h"
#import "GalleryView.h"
#import <AFNetworking.h>
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "FRSUser.h"
#import "CameraViewController.h"
@import Parse;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
@import FBSDKCoreKit;
#import "AppDelegate.h"
#import "FRSDataManager.h"
#import "FirstRunViewController.h"
#import "CrossPostButton.h"
@import AssetsLibrary;
#import "UIImage+ALAsset.h"
#import "ALAsset+assetType.h"

@interface GalleryPostViewController () <UITextViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
@property (weak, nonatomic) IBOutlet UIView *assignmentView;
@property (weak, nonatomic) IBOutlet UILabel *assignmentLabel;
@property (weak, nonatomic) IBOutlet UIButton *linkAssignmentButton;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet CrossPostButton *twitterButton;
@property (weak, nonatomic) IBOutlet CrossPostButton *facebookButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterHeightConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *assignmentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *pressBelowLabel;
@property (weak, nonatomic) IBOutlet UIImageView *invertedTriangleImageView;

// Refactor
@property (strong, nonatomic) FRSAssignment *defaultAssignment;
@property (strong, nonatomic) NSArray *assignments;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation GalleryPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    self.title = @"Create a Gallery Post";
    self.galleryView.gallery = self.gallery;

    // TODO: Confirm permissions
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];

    self.captionTextView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *captionString = [defaults objectForKey:@"captionStringInProgress"];
    self.captionTextView.text = captionString.length ? captionString : @"What's happening?";

    if ([PFUser currentUser]) {
        self.twitterButton.hidden = NO;
        self.facebookButton.hidden = NO;
        self.twitterButton.selected = [defaults boolForKey:@"twitterButtonSelected"] && [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]];
        self.facebookButton.selected = [defaults boolForKey:@"facebookButtonSelected"] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
        self.twitterHeightConstraint.constant = self.navigationController.toolbar.frame.size.height;

        BOOL hideCrosspostingHelp = [[NSUserDefaults standardUserDefaults] boolForKey:@"galleryPreviouslyPosted"];
        self.pressBelowLabel.hidden = hideCrosspostingHelp;
        self.invertedTriangleImageView.hidden = hideCrosspostingHelp;
    }
    else {
        self.twitterButton.hidden = YES;
        self.facebookButton.hidden = YES;
        self.twitterHeightConstraint.constant = 0;
        self.pressBelowLabel.hidden = YES;
        self.invertedTriangleImageView.hidden = YES;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.captionTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
}

- (void)returnToTabBar
{
    [((CameraViewController *)self.presentingViewController) cancel];
}

- (void)returnToCamera:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)twitterButtonTapped:(CrossPostButton *)button
{
    if (!button.isSelected && ![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        // TODO: Try not to dismiss keyboard
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Linked to Twitter"
                                                        message:@"Go to Profile to link your Fresco account to Twitter"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    button.selected = !button.isSelected;
    [[NSUserDefaults standardUserDefaults] setBool:button.isSelected forKey:@"twitterButtonSelected"];
}

- (void)crossPostToTwitter:(NSString *)string
{
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
            NSLog(@"Error crossposting to Twitter: %@", connectionError);
        }
        else {
            NSLog(@"Success crossposting to Twitter: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
}

- (IBAction)facebookButtonTapped:(CrossPostButton *)button
{
    if (!button.isSelected && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // TODO: Try not to dismiss keyboard
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Linked to Facebook"
                                                        message:@"Go to Profile to link your Fresco account to Facebook"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    button.selected = !button.isSelected;
    [[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:@"facebookButtonSelected"];
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
                NSLog(@"Error crossposting to Facebook");
            }
            else {
                NSLog(@"Success crossposting to Facebook: Post id: %@", result[@"id"]);
            }
        }];
    }
}

- (IBAction)linkAssignmentButtonTapped:(id)sender
{
    if (self.defaultAssignment) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Assignment"
                                                        message:@"Are you sure you want remove this assignment?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Remove", nil];
                        
        [alert show];
    }
}

- (void)setDefaultAssignment:(FRSAssignment *)defaultAssignment
{
    _defaultAssignment = defaultAssignment;
    if (defaultAssignment) {
        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Taken for %@", defaultAssignment.title]];
        [titleString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0]}
                             range:(NSRange){10, [titleString length] - 10}];
        self.assignmentLabel.attributedText = titleString;
        [self.linkAssignmentButton setImage:[UIImage imageNamed:@"delete-small-white"] forState:UIControlStateNormal];
    }
    else if (self.assignments.count) {
        self.assignmentLabel.text = @"";
    }
    else {
        self.assignmentLabel.text = @"No assignments nearby";
    }
}

#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleButtonItem
{
    // TODO: Capture all UIToolbar touches
    return [[UIBarButtonItem alloc] initWithTitle:@"Send to Fresco"
                                            style:UIBarButtonItemStylePlain
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
    if (![FRSDataManager sharedManager].currentUser) {
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"firstRunViewController"] animated:YES];
        return;
    }

    [self configureControlsForUpload:YES];

    NSString *urlString = [VariableStore endpointForPath:@"gallery/assemble"];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    NSError *error;

    NSMutableDictionary *postMetadata = [NSMutableDictionary new];
    for (NSInteger i = 0; i < self.gallery.posts.count; i++) {
        NSString *filename = [NSString stringWithFormat:@"file%@", @(i)];

        FRSPost *post = self.gallery.posts[i];
        postMetadata[filename] = @{ @"type" : post.type,
                                    @"lat" : post.image.latitude,
                                    @"lon" : post.image.longitude };
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

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                       progress:&progress
                                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *uploadError) {
        if (uploadError) {
            NSLog(@"Error posting to Fresco: %@", uploadError);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configureControlsForUpload:NO];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed"
                                                                             message:@"Please try again later"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else {
            NSLog(@"Success posting to Fresco: %@ %@", response, responseObject);

            // TODO: Handle error conditions
            NSString *crossPostString = [NSString stringWithFormat:@"Just posted a gallery to @fresconews: http://fresconews.com/gallery/%@", [[responseObject objectForKey:@"data"] objectForKey:@"_id"]];
            [self crossPostToTwitter:crossPostString];
            [self crossPostToFacebook:crossPostString];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"galleryPreviouslyPosted"];

            // TODO: DRY
            [defaults setObject:nil forKey:@"captionStringInProgress"];
            [defaults setObject:nil forKey:@"defaultAssignmentID"];
            [defaults setObject:nil forKey:@"selectedAssets"];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:@"But please wait a moment before attempting to view this just-uploaded gallery in the Profile tab! We need time to process the images and/or videos."
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [self returnToTabBar];
                                                    }]];
            [self presentViewController:alert animated:YES completion:nil];
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
    [self.uploadProgressView setProgress:fractionCompleted animated:YES];
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
    if ([textView.text isEqualToString:@"What's happening?"]) {
        textView.text = @"";
    }
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
                    
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        self.defaultAssignment = nil;
        [UIView animateWithDuration:0.25 animations:^{
            self.assignmentViewHeightConstraint.constant = 0;
            self.assignmentView.hidden = YES;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];

    // TODO: Add support for expiring/expired assignments
    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:0 ofLocation:location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
        self.assignments = responseObject;
        self.defaultAssignment = [self.assignments firstObject];

        if (self.defaultAssignment) {
            self.assignmentViewHeightConstraint.constant = 40;
        }
        else {
            self.assignmentViewHeightConstraint.constant = 0;
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
}

@end
