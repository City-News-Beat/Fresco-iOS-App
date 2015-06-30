//
//  FirstRunSignUpViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FirstRunSignUpViewController.h"
#import "FRSDataManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import FBSDKLoginKit;
@import FBSDKCoreKit;

@interface FirstRunSignUpViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *addPhotoImageView;
@property (weak, nonatomic) IBOutlet UITextField *textfieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldLastName;
@property (strong, nonatomic) UIImage *selectedImage;
@property (nonatomic) NSURL *socialImageURL;

@end

@implementation FirstRunSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.addPhotoImageView setUserInteractionEnabled:YES];
    [self.addPhotoImageView addGestureRecognizer:singleTap];

    // this creates the circular mask around the image
    self.addPhotoImageView.layer.cornerRadius = self.addPhotoImageView.frame.size.width / 2;
    self.addPhotoImageView.clipsToBounds = YES;

}


-(void)tapDetected{

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    self.addPhotoImageView.image = self.selectedImage;
    
    //self.addPhotoImageView.layer.cornerRadius = self.addPhotoImageView.frame.size.width / 2;
    
    self.addPhotoImageView.clipsToBounds = YES;
    
    // Code here to work with media
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [self setFacebookInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                            self.bottomVerticalSpaceConstraint.constant = -1 * height;
                            [self.view layoutIfNeeded];
                        } completion:nil];
}

- (IBAction)actionNext:(id)sender {
    
    // save this to allow backing to the VC
    self.firstName = [self.textfieldFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.lastName = [self.textfieldLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSData *imageData = nil;
    
    if(self.selectedImage){
        
        imageData = UIImageJPEGRepresentation(self.selectedImage, 0.5);
    }
    
    // both fields must be populated
    if (([self.firstName length] && [self.lastName length])) {
        
        NSMutableDictionary *updateParams = [NSMutableDictionary dictionaryWithDictionary:@{ @"firstname" : self.firstName, @"lastname" : self.lastName}];
        
        if (self.socialImageURL)
            [updateParams setObject:[self.socialImageURL absoluteString] forKey:@"avatar"];
        
        [[FRSDataManager sharedManager] updateFrescoUserWithParams:updateParams withImageData:imageData block:^(id responseObject, NSError *error) {
            if (!error) {
                [self performSegueWithIdentifier:@"showPermissions" sender:self];
            }
            else
                NSLog(@"Error: %@", error);
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter both first and last name"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Social data
- (void)setFacebookInfo
{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        return;
    
   NSDictionary *params = @{@"fields": @"first_name,last_name,id"};
    

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:params
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            self.firstName = [result objectForKey:@"first_name"];
            self.lastName = [result objectForKey:@"last_name"];

            self.textfieldFirstName.text = self.firstName;
            self.textfieldLastName.text = self.lastName;
            
            // grab the image url
            NSString *urlString = [NSString stringWithFormat:@"%@/%@.png", [VariableStore sharedInstance].cdnFacebookBaseURL, [result valueForKeyPath:@"id"]];
            if (urlString) {
                self.socialImageURL = [NSURL URLWithString:urlString];
                [self.addPhotoImageView setImageWithURL:self.socialImageURL];
            }
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textfieldFirstName isFirstResponder] && [touch view] != self.textfieldFirstName) {
        [self.textfieldFirstName resignFirstResponder];
    }
    
    if ([self.textfieldLastName isFirstResponder] && [touch view] != self.textfieldLastName) {
        [self.textfieldLastName resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showPermissions"]) {
    }
}
@end
