//
//  FRSIdentityViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSIdentityViewController.h"
#import "UIColor+Fresco.h"
#import "FRSAlertView.h"
#import "FRSUserManager.h"
#import "FRSPaymentManager.h"
#import <UXCam/UXCam.h>

@interface FRSIdentityViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainInfoView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UIView *ssnView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *unitField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) IBOutlet UITextField *socialField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *documentIDButton;
@property (weak, nonatomic) IBOutlet UIButton *saveIDInfoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssnViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssnViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveIdTopSpaceConstraint;

@property (strong, nonatomic) FRSAlertView *alert;
@property BOOL savingInfo;

@end

@implementation FRSIdentityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //    [self configureTableView];
    [self configureBackButtonAnimated:NO];
    [self configureDismissKeyboardGestureRecognizer];
    [self hideSensitiveViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureSpinner];

    [FRSTracker screen:@"Identity"];

    [self.navigationItem setTitle:@"IDENTIFICATION"];
    self.automaticallyAdjustsScrollViewInsets = NO;

    FRSUser *currentUser = [[FRSUserManager sharedInstance] authenticatedUser];
    NSArray *fieldsNeeded = currentUser.fieldsNeeded;

    for (NSString *neededField in fieldsNeeded) {
        if ([self isNameArea:neededField]) {
            showsNameArea = YES;
        }
        if ([self isAddressArea:neededField]) {
            showsAddressArea = YES;
        }
        if ([self isSSNArea:neededField]) {
            showsSocialSecurityArea = YES;
        }
        if ([self isDocumentIDArea:neededField]) {
            showDocumentButton = YES;
        }
    }

    if (([currentUser valueForKey:@"stripeFirst"] && ![[currentUser valueForKey:@"stripeFirst"] isEqual:[NSNull null]]) || ([currentUser valueForKey:@"dob_month"] && ![[currentUser valueForKey:@"dob_month"] isEqual:[NSNull null]])) {
        showsNameArea = YES;
    }
    if (([currentUser valueForKey:@"address_line1"] && ![[currentUser valueForKey:@"address_line1"] isEqual:[NSNull null]])) {
        showsAddressArea = YES;
    }

    if (!showsAddressArea) {
        self.addressViewHeightConstraint.constant = 0;
        self.addressViewTopSpaceConstraint.constant = 0;
        self.addressView.hidden = YES;
    } else {
        self.addressView.hidden = NO;
    }
    if (!showsSocialSecurityArea) {
        self.ssnViewHeightConstraint.constant = 0;
        self.ssnViewTopSpaceConstraint.constant = 0;
        self.ssnView.hidden = YES;
    } else {
        self.ssnView.hidden = NO;
    }
    if (!showDocumentButton) {
        self.documentIDButton.hidden = YES;
        self.saveIdTopSpaceConstraint.constant = 12;
    } else {
        self.documentIDButton.hidden = NO;
        [self addShadowToButton:self.documentIDButton];
        self.saveIdTopSpaceConstraint.constant = 12 + self.saveIDInfoButton.frame.size.height;
    }

    self.mainInfoView.hidden = !showsNameArea;

    if ([currentUser valueForKey:@"stripeFirst"]) {
        self.firstNameField.text = [currentUser valueForKey:@"stripeFirst"];
        self.firstNameField.enabled = FALSE;
        self.firstNameField.textColor = [UIColor frescoLightTextColor];
    }
    if ([currentUser valueForKey:@"stripeLast"]) {
        self.lastNameField.text = [currentUser valueForKey:@"stripeLast"];
        self.lastNameField.enabled = FALSE;
        self.lastNameField.textColor = [UIColor frescoLightTextColor];
    }
    if ([[currentUser valueForKey:@"dob_day"] intValue] != 0 && [[currentUser valueForKey:@"dob_month"] intValue] != 0 && [[currentUser valueForKey:@"dob_year"] intValue] != 0) {
        int day = [[currentUser valueForKey:@"dob_day"] intValue];
        int month = [[currentUser valueForKey:@"dob_month"] intValue];
        int year = [[currentUser valueForKey:@"dob_year"] intValue];

        NSString *birthday = [NSString stringWithFormat:@"%d/%d/%d", month, day, year];
        self.dateField.enabled = FALSE;
        self.dateField.text = birthday;
        self.dateField.textColor = [UIColor frescoLightTextColor];
    }

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 210, 320, 216)];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(startDateSelected:) forControlEvents:UIControlEventValueChanged];

    self.dateField.inputView = self.datePicker;

    if ([currentUser valueForKey:@"address_line1"]) {
        self.addressField.text = [currentUser valueForKey:@"address_line1"];
        self.addressField.enabled = FALSE;
        self.addressField.textColor = [UIColor frescoLightTextColor];
    }
    if ([currentUser valueForKey:@"address_line2"]) {
        self.unitField.text = [currentUser valueForKey:@"address_line2"];
        self.unitField.enabled = FALSE;
        self.unitField.textColor = [UIColor frescoLightTextColor];
    }
    if ([currentUser valueForKey:@"address_city"]) {
        self.cityField.text = [currentUser valueForKey:@"address_city"];
        self.cityField.enabled = FALSE;
        self.cityField.textColor = [UIColor frescoLightTextColor];
    }
    if ([currentUser valueForKey:@"address_state"]) {
        self.stateField.text = [currentUser valueForKey:@"address_state"];
        self.stateField.enabled = FALSE;
        self.stateField.textColor = [UIColor frescoLightTextColor];
    }
    if ([currentUser valueForKey:@"address_zip"]) {
        self.zipField.text = [currentUser valueForKey:@"address_zip"];
        self.zipField.enabled = FALSE;
        self.zipField.textColor = [UIColor frescoLightTextColor];
    }
    if ([currentUser valueForKey:@"ssn"]) {
        self.socialField.text = [currentUser valueForKey:@"ssn"];
        self.socialField.enabled = FALSE;
        self.socialField.textColor = [UIColor frescoLightTextColor];
    }
}

- (BOOL)isNameArea:(NSString *)field {
    if ([field isEqualToString:@"first_name"] || [field isEqualToString:@"last_name"] || [field isEqualToString:@"dob_month"] || [field isEqualToString:@"dob_day"] || [field isEqualToString:@"dob_year"]) {

        return TRUE;
    }

    return FALSE;
}

- (BOOL)isAddressArea:(NSString *)field {
    if ([field isEqualToString:@"address_line1"] || [field isEqualToString:@"address_line2"] || [field isEqualToString:@"address_city"] || [field isEqualToString:@"address_state"] || [field isEqualToString:@"address_zip"]) {
        return YES;
    }

    return NO;
}

- (BOOL)isSSNArea:(NSString *)field {
    if ([field isEqualToString:@"pid_last4"]) {
        self.socialField.placeholder = @"Last 4 Digits of Social Security Number";
        return YES;
    }
    if ([field isEqualToString:@"personal_id_number"]) {
        self.socialField.placeholder = @"Social Security Number";
        return YES;
    }
    return NO;
}

- (BOOL)isDocumentIDArea:(NSString *)field {
    if ([field isEqualToString:@"id_document"]) {
        return YES;
    }

    return NO;
}

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

- (void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 - 16, button.frame.size.height / 2 - 10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];
}

- (void)stopSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [spinner removeFromSuperview];
    [spinner startAnimating];
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField {
    if (IS_IPHONE_5) {
        if (textField == self.addressField || textField == self.unitField || textField == self.cityField || textField == self.stateField || textField == self.zipField || textField == self.socialField) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.scrollView.transform = CGAffineTransformMakeTranslation(0, -70);
                             }
                             completion:nil];
        }
    }
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField {
    if (IS_IPHONE_5) {
        if (textField == self.addressField || textField == self.unitField || textField == self.cityField || textField == self.stateField || textField == self.zipField || textField == self.socialField) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               self.scrollView.transform = CGAffineTransformMakeTranslation(0, 0);
                             }
                             completion:nil];
        }
    }
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    BOOL enableSaveButton = true;

    NSArray *mandatoryTextFieldArray = [[NSArray alloc] initWithObjects:_firstNameField, _lastNameField, _addressField, _cityField, _stateField, _zipField, _dateField, _socialField, nil];
    for (UITextField *textField in mandatoryTextFieldArray) {
        if ((textField.text.length == 0 || [textField.text isEqualToString:@""]) && textField.enabled) {
            enableSaveButton = false;
        }
    }

    self.saveIDInfoButton.enabled = enableSaveButton;
    if (enableSaveButton) {
        [self.saveIDInfoButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    } else {
        [self.saveIDInfoButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    }
}

- (IBAction)savedocumentIDInfo:(id)sender {
    UIAlertController *photoSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    FRSIdentityViewController *__weak weakSelf = self;
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take a New Photo"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                           [weakSelf showImagePickerControllerWithCamera:YES];
                                                         }];
    [photoSheet addAction:cameraAction];

    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Upload Photo"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                            [weakSelf showImagePickerControllerWithCamera:NO];
                                                          }];
    [photoSheet addAction:libraryAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action){
                                                         }];
    [photoSheet addAction:cancelAction];

    [self presentViewController:photoSheet animated:YES completion:nil];
}

- (IBAction)saveIDInfo:(id)sender {
    [self startSpinner:self.loadingView onButton:self.saveIDInfoButton];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDate = [formatter dateFromString:_dateField.text];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:birthDate];

    NSMutableDictionary *addressInfo = [[NSMutableDictionary alloc] init];

    if (_addressField.enabled && ![_addressField.text isEqualToString:@""]) {
        [addressInfo setObject:_addressField.text forKey:@"address_line1"];
    }
    if (_unitField.enabled && ![_unitField.text isEqualToString:@""]) {
        [addressInfo setObject:_unitField.text forKey:@"address_line2"];
    }
    if (_cityField.enabled && ![_cityField.text isEqualToString:@""]) {
        [addressInfo setObject:_cityField.text forKey:@"address_city"];
    }
    if (_stateField.enabled && ![_stateField.text isEqualToString:@""]) {
        [addressInfo setObject:_stateField.text forKey:@"address_state"];
    }
    if (_zipField.enabled && ![_zipField.text isEqualToString:@""]) {
        [addressInfo setObject:_zipField.text forKey:@"address_zip"];
    }
    if (_dateField.enabled && ![_dateField.text isEqualToString:@""]) {
        [addressInfo setObject:[NSNumber numberWithInteger:[components day]] forKey:@"dob_day"];
        [addressInfo setObject:[NSNumber numberWithInteger:[components month]] forKey:@"dob_month"];
        [addressInfo setObject:[NSNumber numberWithInteger:[components year]] forKey:@"dob_year"];
    }
    if (_firstNameField.enabled && ![_firstNameField.text isEqualToString:@""]) {
        [addressInfo setObject:_firstNameField.text forKey:@"first_name"];
    }
    if (_lastNameField.enabled && ![_lastNameField.text isEqualToString:@""]) {
        [addressInfo setObject:_lastNameField.text forKey:@"last_name"];
    }
    if (_socialField.enabled && ![_socialField.text isEqualToString:@""]) {
        if ([self.socialField.placeholder isEqualToString:@"Last 4 Digits of Social Security Number"]) {
            [addressInfo setObject:_socialField.text forKey:@"pid_last4"];
        }
    }

    self.savingInfo = true;

    if ([self.socialField.placeholder isEqualToString:@"Social Security Number"]) {
        [[FRSPaymentManager sharedInstance] updateIdentityWithDigestion:addressInfo
                                                                 andSsn:self.socialField.text
                                                             completion:^(id responseObject, NSError *error) {
                                                               self.savingInfo = false;

                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [self stopSpinner:self.loadingView onButton:self.saveIDInfoButton];
                                                               });

                                                               if (error) {
                                                                   NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                                   if (response && (response.statusCode == 500 || response.statusCode == 400)) {
                                                                       NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSASCIIStringEncoding];
                                                                       NSData *data = [errorString dataUsingEncoding:NSUTF8StringEncoding];
                                                                       id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                       NSDictionary *errorDict = json[@"error"];
                                                                       NSString *errorMessage = errorDict[@"msg"];
                                                                       FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
                                                                       [alert show];
                                                                   } else {
                                                                       [self presentGenericError];
                                                                   }
                                                               } else {
                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                               }
                                                             }];
    } else {
        [[FRSPaymentManager sharedInstance] updateIdentityWithDigestion:addressInfo
                                                             completion:^(id responseObject, NSError *error) {
                                                               self.savingInfo = false;

                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [self stopSpinner:self.loadingView onButton:self.saveIDInfoButton];

                                                                 if (error) {
                                                                     NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                                     if (response && (response.statusCode == 500 || response.statusCode == 400)) {
                                                                         NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSASCIIStringEncoding];
                                                                         NSData *data = [errorString dataUsingEncoding:NSUTF8StringEncoding];
                                                                         id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                         NSDictionary *errorDict = json[@"error"];
                                                                         NSString *errorMessage = errorDict[@"msg"];
                                                                         FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
                                                                         [alert show];
                                                                     } else {
                                                                         [self presentGenericError];
                                                                     }
                                                                 } else {
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }
                                                               });
                                                             }];
    }
}

- (void)startDateSelected:(UIDatePicker *)sender {
    NSDate *currentDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];

    NSString *stringFromDate = [formatter stringFromDate:currentDate];
    _dateField.text = stringFromDate;

    self.saveIDInfoButton.userInteractionEnabled = true;
    self.saveIDInfoButton.enabled = true;
    [self.saveIDInfoButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _lastNameField) {
        [textField resignFirstResponder];
        [self startDateSelected:self.datePicker];
        [_dateField becomeFirstResponder];
    } else if (textField == _addressField) {
        [textField resignFirstResponder];
        [_unitField becomeFirstResponder];
    } else if (textField == _unitField) {
        [textField resignFirstResponder];
        [_cityField becomeFirstResponder];
    } else if (textField == _cityField) {
        [textField resignFirstResponder];
        [_stateField becomeFirstResponder];
    } else if (textField == _stateField) {
        [textField resignFirstResponder];
        [_zipField becomeFirstResponder];
    } else if (textField == _zipField) {
        [self.view resignFirstResponder];
    }

    return NO;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                 NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
                                 UIImage *editedImage;

                                 // Handle a still image capture
                                 if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
                                     editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];

                                     if (!editedImage)
                                         return;

                                     NSData *imageData = UIImageJPEGRepresentation(editedImage, 1.0);
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       [[FRSPaymentManager sharedInstance] uploadStateIDWithParameters:imageData
                                                                                            completion:^(id responseObject, NSError *error) {
                                                                                              if (!error) {
                                                                                                  if ([[responseObject class] isSubclassOfClass:[NSDictionary class]]) {
                                                                                                      NSString *fileID = [responseObject valueForKey:@"id"];
                                                                                                      [[FRSPaymentManager sharedInstance] updateTaxInfoWithFileID:fileID
                                                                                                                                                       completion:^(id responseObject, NSError *error){
                                                                                                                                                       }];
                                                                                                  }
                                                                                              }
                                                                                            }];
                                     });
                                 }
                               }];
}

- (void)showImagePickerControllerWithCamera:(BOOL)withCamera {

    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.delegate = self;
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    cameraUI.allowsEditing = true;
    if (withCamera) {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:cameraUI animated:YES completion:nil];
}

// TODO: move to a UI helper class
- (void)addShadowToButton:(UIButton *)view {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 3);
    view.layer.shadowOpacity = 0.15;
    view.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.ssnView];
}

@end
