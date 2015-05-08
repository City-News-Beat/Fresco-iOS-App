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

@interface GalleryPostViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
// TODO: Add assignment view, which is set automatically based on radius
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;
@end

// TODO: On success, redirect user back to original tab

@implementation GalleryPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    [self setupToolbar];
    self.title = @"Create a Gallery Post";
    self.galleryView.gallery = self.gallery;
    self.captionTextView.delegate = self;
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

- (void)setupToolbar
{
    self.toolbarItems = [self toolbarItems];
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
    NSString *urlString = @"http://ec2-52-1-216-0.compute-1.amazonaws.com/api/gallery/assemble";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSMutableDictionary *postMetadata = [NSMutableDictionary new];
    for (NSInteger i = 0; i < self.gallery.posts.count; i++) {
        NSString *filename = [NSString stringWithFormat:@"file%@", @(i)];
        NSLog(@"filename: %@" , filename);

        postMetadata[filename] = @{ @"byline" : @"Test via Test", // TODO: Make optional
                                    @"source" : @"",
                                    @"type" : @"image",
                                    @"license" : @"Fresco",
                                    @"lat" : @10,
                                    @"lon" : @10 };
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postMetadata
                                                       options:(NSJSONWritingOptions)0
                                                         error:&error];

    NSDictionary *parameters = @{ @"owner" : @"id_bullshitID",
                                  @"caption" : self.captionTextView.text,
                                  @"tags" : @"[]",  // TODO: Make optional; generate on server
                                  @"articles" : @"[]", // TODO: Make optional
                                  @"posts" : jsonData };

#warning fix posting with new model
    /*
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger count = 0;
        for (FRSPost *post in self.gallery.posts) {
            NSString *filename = [NSString stringWithFormat:@"file%@", @(count)];
            NSLog(@"filename: %@" , filename);
            [formData appendPartWithFileData:UIImageJPEGRepresentation(post.largeImage.image, 1.0)
                                        name:filename
                                    fileName:filename
                                    mimeType:@"image/jpeg"];
            count++;
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
     */
}

// temporary ("return" to dismiss keyboard)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }

    [textView resignFirstResponder];
    return NO;
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            CGFloat height = 0;
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                height = -1 * [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                            }

                            self.topVerticalSpaceConstraint.constant = height;
                            self.bottomVerticalSpaceConstraint.constant = height;
                            [self.view layoutIfNeeded];
    } completion:nil];
}

@end
