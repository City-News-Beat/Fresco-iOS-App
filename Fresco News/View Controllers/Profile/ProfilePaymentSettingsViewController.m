//
//  ProfilePaymentSettingsViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 9/17/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

@import AVFoundation;

#import "ProfilePaymentSettingsViewController.h"
#import "FRSDataManager.h"
#import "NSString+Validation.h"
#import "FRSSaveButton.h"
#import "FRSLabel.h"
#import <CardIO.h>
#import <BKCardNumberField.h>
#import <BKCardExpiryField.h>
#import <Stripe.h>

@interface ProfilePaymentSettingsViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, CardIOViewDelegate>

/*
** Container view for card scanner
*/

@property (nonatomic, strong) UIView *containerView;

/*
** CardIOView for camera viewport
*/

@property (nonatomic, strong, readwrite) CardIOView *cardIOView;

/*
** UITextField for card number
*/

@property (strong, nonatomic) BKCardNumberField *cardNumberField;

/*
** UITextField for expiration field
*/

@property (strong, nonatomic) BKCardExpiryField *expireField;

/*
** UITextField for CCV fiekd
*/

@property (strong, nonatomic) BKCardNumberField *CCVField;

/*
** UIButton for `Save Card` action
*/

@property (strong, nonatomic) FRSSaveButton *saveCardButton;


/*
** UILabel for user message
*/

@property (strong, nonatomic) UILabel *userMessage;

/*
** Set of all textfields
*/

@property (strong, nonatomic) NSArray *textFieldCollection;

@property (strong, nonatomic) UIDatePicker *dobbyPicker;

@property (strong, nonatomic) FRSLabel *dobbyPickerLabel;

@property (assign, nonatomic) BOOL pickerSelected;

@end


@implementation ProfilePaymentSettingsViewController

- (id)init{

    self = [super init];
    
    if(self){
        
        self.parentViewController.view.backgroundColor = [UIColor frescoGreyBackgroundColor];
        self.view.frame = [[UIScreen mainScreen] bounds];
        self.hidesBottomBarWhenPushed = YES;
        self.view.backgroundColor = [UIColor frescoGreyBackgroundColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowOrHide:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowOrHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    
    return self;
}

- (void)loadView{

    [super loadView];

    self.title = @"Add a debit card";

    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 256)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.clipsToBounds = YES;
    
    /* CardIO View */
    self.cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0, -120, self.view.frame.size.width, 500)];
    self.cardIOView.backgroundColor = [UIColor clearColor];
    [self.containerView  addSubview:self.cardIOView];
    
    /* Text Fields */
    [self configureTextFields];

    /* Save Card Button */
    self.saveCardButton = [[FRSSaveButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - 46 - 44, self.view.frame.size.width, 46) andTitle:@"Save Card"];
    
    /* DOB Picker */
    self.dobbyPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(
                                                                    0,
                                                                    self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - 44,
                                                                    self.view.frame.size.width,
                                                                    150)];
    self.dobbyPicker.datePickerMode = UIDatePickerModeDate;
    self.dobbyPicker.hidden = YES;
    self.dobbyPicker.backgroundColor = [UIColor whiteColor];
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.dobbyPicker.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    [self.dobbyPicker.layer addSublayer:topBorder];
    [self.dobbyPicker addTarget:self action:@selector(dobbyPickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    //Set the minimum date to 18 years, to allow only 18 years old to register
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [self.dobbyPicker setMaximumDate:maxDate];
    [self.dobbyPicker setMinimumDate:minDate];
    
    /* Message Label */
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x, CGRectGetMaxY(self.dobbyPickerLabel.frame) + 20, 0, 10)];
    userLabel.text = PAYMENT_MESSSAGE;
    userLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:11];
    userLabel.textColor = [UIColor textHeaderBlackColor];
    userLabel.textAlignment = NSTextAlignmentCenter;
    [userLabel sizeToFit];

    [self.view addSubview:userLabel];
    [self.view addSubview:self.saveCardButton];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.dobbyPicker];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.parentViewController.view.backgroundColor = [UIColor frescoGreyBackgroundColor];
    
    [self.saveCardButton addTarget:self action:@selector(saveCardAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    UITapGestureRecognizer *recg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    recg.delegate = self;
//    
//    [self.view addGestureRecognizer:recg];
    
    // Do any additional setup after loading the view.
    if (![CardIOUtilities canReadCardWithCamera]) {
        
        // Hide your "Scan Card" button, or take other appropriate action...
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusNotDetermined)
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
        else
            [self addDisabledCameraState];
    
    }
    else {
        self.cardIOView.delegate = self;
        self.cardIOView.hidden = NO;
    }
        
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    [CardIOUtilities preload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Functions

/*
** Configures all text fields
*/

- (void)configureTextFields{
    
    self.cardNumberField = [self textFieldWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(self.containerView.frame),
                                                               self.view.frame.size.width,
                                                               44) withPlaceHolder:@"0000 0000 0000 0000" withRightBorder:NO];
    self.cardNumberField.tag = 100;
    
    
    self.expireField = [self expireFieldWithFrame:CGRectMake(0,
                                                             CGRectGetMaxY(self.cardNumberField.frame),
                                                             self.view.frame.size.width / 2,
                                                             44)
                                  withPlaceHolder:@"00 / 00"];
    self.expireField.tag = 101;
    
    
    self.CCVField = [self textFieldWithFrame:CGRectMake(
                                                        CGRectGetMaxX(self.expireField.frame),
                                                        CGRectGetMaxY(self.cardNumberField.frame),
                                                        self.view.frame.size.width / 2,
                                                        44)
                             withPlaceHolder:@"CCV"
                             withRightBorder:YES];
    self.CCVField.tag = 102;
    
    
    self.dobbyPickerLabel = [[FRSLabel alloc] initWithFrame:CGRectMake(
                                                                 0,
                                                                 CGRectGetMaxY(self.CCVField.frame) + 12,
                                                                 self.view.frame.size.width,
                                                                  44)];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dobTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.dobbyPickerLabel addGestureRecognizer:tapGestureRecognizer];
    self.dobbyPickerLabel.userInteractionEnabled = YES;
    self.dobbyPickerLabel.text = @"Add date of birth";
    
    self.textFieldCollection = @[
                                 self.cardNumberField,
                                 self.expireField,
                                 self.CCVField,
                                 self.dobbyPickerLabel
                                 ];
    
    //Loop through text field collection and add text fields
    for(UIView *view in self.textFieldCollection)
        [self.view addSubview:view];

}

/*
** UI Config for disabled camera state
*/

- (void)addDisabledCameraState{

    [self.cardIOView removeFromSuperview];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.containerView.frame.size.height - 1, self.containerView.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    [self.containerView.layer addSublayer:bottomBorder];
    
    UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera"]];
    cameraView.frame = CGRectMake(0, 0, 80, 80);
    cameraView.contentMode = UIViewContentModeScaleAspectFit;
    cameraView.center = CGPointMake(self.containerView.center.x, self.containerView.center.y - 20);
    cameraView.userInteractionEnabled = YES;
    
    UILabel *disabledLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    disabledLabel.text = DISABLED_CAMERA_SCAN;
    disabledLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:11];
    disabledLabel.textColor = [UIColor textHeaderBlackColor];
    [disabledLabel sizeToFit];
    disabledLabel.center = CGPointMake(self.containerView.center.x,  CGRectGetMaxY(cameraView.frame) + 30);
    disabledLabel.userInteractionEnabled = YES;
    
    [cameraView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSettings:)]];
    [disabledLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSettings:)]];
    
    [self.containerView addSubview:cameraView];
    [self.containerView addSubview:disabledLabel];
    
}


/*
** Tap Gesture selector to hide keyboard when clicking outside teh text field
*/

- (void)dismissKeyboard {
    [self.view endEditing:YES];
    [self togglePicker:YES];
}

/*
** Sends app to the settings
*/

- (void)goToSettings:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

}

/*
** Runs check on form, and updates save button for respective state
*/

- (void)checkPaymentForm{
    
    if(self.cardNumberField.text.length >= 18 && self.expireField.text.length == 7 && self.CCVField.text.length >= 2 && self.pickerSelected)
        [self.saveCardButton updateSaveState:SaveStateEnabled];
    else
        [self.saveCardButton updateSaveState:SaveStateDisabled];

}

#pragma mark UI Actions

- (void)saveCardAction:(id)sender {
    
    [self.saveCardButton toggleSpinner];
    
    //Create the STPCard Object
    STPCard *card = [[STPCard alloc] init];
    card.number = self.cardNumberField.cardNumber;
    card.expMonth = self.expireField.dateComponents.month;
    card.expYear = self.expireField.dateComponents.year;
    card.cvc = self.CCVField.text;
    card.currency = @"usd";
    
    //Create the DOB values
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.dobbyPicker.date]; // Get necessary date components

    NSNumber *day = [NSNumber numberWithInteger:[components day]];
    NSNumber *year = [NSNumber numberWithInteger:[components year]];
    NSNumber *month =[NSNumber numberWithInteger:[components month]];

    [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken *token, NSError *error) {

        if (!error && token) {
            
            NSDictionary *params = @{
                                     @"token" : token.tokenId,
                                     @"dob_day" : day,
                                     @"dob_year" : year,
                                     @"dob_month" : month
                                     };
            
            [[FRSDataManager sharedManager] updateUserPaymentInfo:params block:^(id responseObject, NSError *error) {
            
                [self.saveCardButton toggleSpinner];
                
                if([responseObject valueForKeyPath:@"data.last4"] != nil){//Succeeded
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[responseObject valueForKeyPath:@"data.last4"] forKey:UD_LAST4];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                
                }
                else{ //Failed to update
                
                    [self presentViewController:[[FRSAlertViewManager sharedManager]
                                                 alertControllerWithTitle:@"Error saving payment info"
                                                 message:@"We couldn't save your payment info. Please try again later." action:DISMISS]
                                       animated:YES
                                     completion:nil];
                
                }
                
            }];
        }
        else {
            
            [self.saveCardButton toggleSpinner];
            
            [self presentViewController:[[FRSAlertViewManager sharedManager]
                                         alertControllerWithTitle:@"Error saving payment info"
                                         message:error.localizedDescription action:DISMISS]
                               animated:YES
                             completion:nil];

        }
        
    }];
    
}

#pragma mark - UIKeyboard Notificaitons

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.3
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            
                            CGRect viewFrame = self.view.frame;
                            
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]){
                                viewFrame.origin.y = -kbSize.height /4;
                                [self togglePicker:YES];
                            }
                            else if([notification.name isEqualToString:UIKeyboardWillHideNotification]){
                                viewFrame.origin.y = 64;
                            }

                            self.view.frame = viewFrame;
                            
                        } completion:nil];
}


#pragma mark - UIGestureRecognizer delegate

- (void)dobTapped:(id)sender{
    [self.view endEditing:YES];
    [self togglePicker:NO];
}

- (void)togglePicker:(BOOL)alwaysHide{

    //Present Picker
    if(self.dobbyPicker.hidden && !alwaysHide){
        
        self.dobbyPicker.hidden = NO;
        
        CGRect newFrame = CGRectMake(
                                     0,
                                     self.view.frame.size.height - self.dobbyPicker.frame.size.height,
                                     self.dobbyPicker.frame.size.width,
                                     self.dobbyPicker.frame.size.height);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                self.dobbyPicker.frame = newFrame;
                
            } completion:^(BOOL finished) {
                
                [self setDateOfBirthForPicker];
                
                if(!self.pickerSelected) self.pickerSelected = YES;
                
            }];
            
        });
        
    }
    //Hide Picker
    else{
        
        //Run check when hiding picker to see if form is ready
        [self checkPaymentForm];
        
        CGRect hiddenFrame = CGRectMake(0,
                                        self.dobbyPicker.frame.origin.y + self.dobbyPicker.frame.size.height,
                                        self.dobbyPicker.frame.size.width,
                                        self.dobbyPicker.frame.size.height);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                self.dobbyPicker.frame = hiddenFrame;
                
            } completion:^(BOOL finished) {
                
                self.dobbyPicker.hidden = YES;
                
            }];
            
        });
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]){ //It can work for any class you do not want to receive touch
        [self saveCardAction:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - UIPickerDelegate/DataSource

- (void)dobbyPickerChanged:(id)sender{

    [self setDateOfBirthForPicker];
    
}

- (void)setDateOfBirthForPicker{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
    
     self.dobbyPickerLabel.text = [NSString stringWithFormat:@"Date of birth: %@",  [dateFormatter stringFromDate:self.dobbyPicker.date]];

}

#pragma mark UITextField Delegate

- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string{
    
    [self checkPaymentForm];
    
    if(textField == self.cardNumberField && textField.text.length >= 18 && range.length == 0){
        
        UIResponder* nextResponder = [textField.superview viewWithTag:101];
        
        if(nextResponder) [nextResponder becomeFirstResponder];
        
    }
    else if(textField == self.expireField && textField.text.length >= 6 && range.length == 0){
        
        UIResponder* nextResponder = [textField.superview viewWithTag:102];
        
        if(nextResponder) [nextResponder becomeFirstResponder];
        
    }
    else if(textField == self.CCVField && textField.text.length >= 3 && range.length == 0){
        
        return NO;
        
    }
    
    return YES;
    
}

- (BKCardNumberField *)textFieldWithFrame:(CGRect)frame withPlaceHolder:(NSString *)placeHolder withRightBorder:(BOOL)rightBorder{
    
    BKCardNumberField *field = [[BKCardNumberField alloc] initWithFrame:frame];
    field.placeholder = placeHolder;
    field.keyboardType = UIKeyboardTypeNumberPad;
    field.backgroundColor = [UIColor whiteColor];
    [field setReturnKeyType:UIReturnKeyDone];
    
    field.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15];
    field.textColor = [UIColor textHeaderBlackColor];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 24)];
    field.leftView = paddingView;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.delegate = self;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, field.frame.size.height - 1, field.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    [field.layer addSublayer:bottomBorder];
    
    if(rightBorder){
        
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(CGRectGetMaxX(field.frame) -1, 0.0f, 1.0f, field.frame.size.height);
        rightBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
        [field.layer addSublayer:rightBorder];
        
    }
    
    return field;
    
}

- (BKCardExpiryField *)expireFieldWithFrame:(CGRect)frame withPlaceHolder:(NSString *)placeHolder{
    
    BKCardExpiryField *field = [[BKCardExpiryField alloc] initWithFrame:frame];
    field.placeholder = placeHolder;
    field.keyboardType = UIKeyboardTypeNumberPad;
    [field setReturnKeyType:UIReturnKeyDone];
    field.backgroundColor = [UIColor whiteColor];
    
    field.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15];
    field.textColor = [UIColor textHeaderBlackColor];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 24)];
    field.leftView = paddingView;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.delegate = self;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, field.frame.size.height - 1, field.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    [field.layer addSublayer:bottomBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(CGRectGetMaxX(field.frame) -1, 0.0f, 1.0f, field.frame.size.height);
    rightBorder.backgroundColor = [UIColor fieldBorderColor].CGColor;
    [field.layer addSublayer:rightBorder];
    
    field.delegate = self;
    
    return field;
    
}

#pragma mark CardIO Delegate

- (void)cardIOView:(CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)info {
    
    if (info) {
        
        // The full card number is available as info.cardNumber, but don't log that!
        self.cardNumberField.text = info.cardNumber;

        self.CCVField.text = info.cvv;
        
    }
    
    cardIOView.hidden = YES;

}

@end
