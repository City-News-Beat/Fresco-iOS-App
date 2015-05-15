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
#import "CameraViewController.h"

@interface GalleryPostViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
// TODO: Add assignment view, which is set automatically based on radius
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterHeightConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;
@end

// TODO: On success, redirect user back to original tab

@implementation GalleryPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    self.title = @"Create a Gallery Post";
    self.galleryView.gallery = self.gallery;
    self.captionTextView.delegate = self;
    self.twitterHeightConstraint.constant = self.navigationController.toolbar.frame.size.height;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // TODO: Make a note of any caption the user started entering
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
}

- (void)returnToTabBar
{
    [((CameraViewController *)self.presentingViewController) cancel];
}

- (void)returnToCamera:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"Send to Fresco"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(submitGalleryPost:)];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title = [self titleButtonItem];
    UIBarButtonItem *space = [self spaceButtonItem];
    return @[space, title, space];
}

- (void)submitGalleryPost:(id)sender
{
    [self configureControlsForUpload:YES];

    NSString *urlString = [VariableStore endpointForPath:@"gallery/assemble"];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    NSError *error;

    NSMutableDictionary *postMetadata = [NSMutableDictionary new];
    for (NSInteger i = 0; i < self.gallery.posts.count; i++) {
        NSString *filename = [NSString stringWithFormat:@"file%@", @(i)];
        postMetadata[filename] = @{ @"byline" : @"Test via Test", // TODO: Make optional
                                    @"source" : @"",
                                    @"type" : @"image",
                                    @"license" : @"Fresco",
                                    @"lat" : @10,
                                    @"lon" : @10 };
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postMetadata
                                                       options:(NSJSONWritingOptions)0
                                                         error:&error];

    NSDictionary *parameters = @{ @"owner" : @"55284ea411fe08b11f004297",  // test Owner ID
                                  @"caption" : self.captionTextView.text,
                                  @"tags" : @"[]",  // TODO: Make optional; generate on server
                                  @"articles" : @"[]", // TODO: Make optional
                                  @"posts" : jsonData };

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:urlString
                                                                                             parameters:parameters
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger count = 0;
        for (FRSPost *post in self.gallery.posts) {
            NSString *filename = [NSString stringWithFormat:@"file%@", @(count)];
            NSLog(@"filename: %@" , filename);
            [formData appendPartWithFileData:UIImageJPEGRepresentation(post.image.image, 1.0)
                                        name:filename
                                    fileName:filename
                                    mimeType:@"image/jpeg"];
            count++;
        }
    } error:nil];

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                       progress:&progress
                                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *uploadError) {
        if (uploadError) {
            NSLog(@"Error: %@", uploadError);
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
            NSLog(@"Success: %@ %@", response, responseObject);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:nil
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
        NSLog(@"Progress... %f", progress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUploadProgress:progress.fractionCompleted];
        });
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UITextViewDelegate methods

// temporary ("return" to dismiss keyboard)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }

    [textView resignFirstResponder];
    return NO;
}

#pragma mark - Notification methods

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            CGFloat height;
                            CGRect frame = self.navigationController.toolbar.frame;

                            height = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
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

                            [self.view layoutIfNeeded];
    } completion:nil];
}

@end
