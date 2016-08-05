//
//  FRSDebitCardViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDebitCardViewController.h"
#import "FRSTableViewCell.h"
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "FRSStripe.h"
#import "FRSAPIClient.h"
#import "FRSAlertView.h"

@interface FRSDebitCardViewController()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardGestureRecognizer;

@property (strong, nonatomic) NSString *CVV;

@property (strong, nonatomic) UIButton *rightAlignedButton;

@property (strong, nonatomic) FRSAlertView *alertView;
@property (strong, nonatomic) UIScrollView *contentScroller;
@property (strong, nonatomic) UIView *bankView;
@property (strong, nonatomic) UIButton *saveBankButton;
@property (strong, nonatomic) UITextField *accountNumberField;
@property (strong, nonatomic) UITextField *routingNumberField;
@property (strong, nonatomic) UIButton *debitButton;
@property (strong, nonatomic) UIButton *bankButton;
@end

@implementation FRSDebitCardViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureView];
    self.title = @"DEBIT CARD";
    
    [self configureBackButtonAnimated:NO];
    
    self.dismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.dismissKeyboardGestureRecognizer];
}


-(void)configureView{
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;
    
    self.debitButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 10 - titleView.frame.size.width/6 - 40, 6, 120, 30)];
    [self.debitButton setTitle:@"DEBIT CARD" forState:UIControlStateNormal];
    [self.debitButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.debitButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.debitButton addTarget:self action:@selector(debitTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.debitButton];
    
    self.bankButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 60 - 10 + titleView.frame.size.width/6 - 40, 6, 120, 30)];
    self.bankButton.alpha = 0.7;
    [self.bankButton setTitle:@"BANK ACCOUNT" forState:UIControlStateNormal];
    [self.bankButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.bankButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.bankButton addTarget:self action:@selector(bankTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.bankButton];

    _contentScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _contentScroller.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height-100);
    _contentScroller.bounces = TRUE;
    _contentScroller.pagingEnabled = TRUE;
    _contentScroller.delegate = self;
    
    _bankView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_contentScroller addSubview:_bankView];
    [self configureBankView];
    
    [self.view addSubview:_contentScroller];
    
    cardViewport = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - 44)];
    cardViewport.clipsToBounds = YES;
    [_contentScroller addSubview:cardViewport];
    
    [cardViewport addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, cardViewport.frame.size.height, self.view.frame.size.width, 88)];
    container.backgroundColor = [UIColor colorWithWhite:1 alpha:.92];
    [_contentScroller addSubview:container];
    
    cardNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    cardNumberTextField  = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - (32), 44)];
    cardNumberTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    cardNumberTextField.placeholder =  @"0000 0000 0000 0000";
    cardNumberTextField.textColor = [UIColor frescoDarkTextColor];
    cardNumberTextField.tintColor = [UIColor frescoBlueColor];
    cardNumberTextField.delegate = self;
    [cardNumberTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    [container addSubview:cardNumberTextField];
    
    cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    [cardNumberTextField setSecureTextEntry: YES];
    
    
    expirationDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    expirationDateTextField  = [[UITextField alloc] initWithFrame:CGRectMake(16, 44, [UIScreen mainScreen].bounds.size.width/2, 44)];
    expirationDateTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    expirationDateTextField.placeholder =  @"00 / 00";
    expirationDateTextField.textColor = [UIColor frescoDarkTextColor];
    expirationDateTextField.tintColor = [UIColor frescoBlueColor];
    expirationDateTextField.delegate = self;
    [expirationDateTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    [container addSubview:expirationDateTextField];
    
    expirationDateTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

    securityCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    securityCodeTextField  = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 , 44, [UIScreen mainScreen].bounds.size.width/2, 44)];
    securityCodeTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    securityCodeTextField.placeholder =  @"CVV";
    securityCodeTextField.textColor = [UIColor frescoDarkTextColor];
    securityCodeTextField.tintColor = [UIColor frescoBlueColor];
    securityCodeTextField.delegate = self;
    [securityCodeTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    [container addSubview:securityCodeTextField];
    
    securityCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    cardNumberTextField.delegate = self;
    securityCodeTextField.delegate = self;
    expirationDateTextField.delegate = self;
    
    UIImageView *cardNumberCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptedNot"]];
    cardNumberCheckIV.frame = CGRectMake(self.view.frame.size.width - 30, 10, 24, 24);
//    [container addSubview:cardNumberCheckIV];
    
    UIImageView *expirationDateCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptedNot"]];
    expirationDateCheckIV.frame = CGRectMake(self.view.frame.size.width/2 - 24 - 16, 54, 24, 24);
//    [container addSubview:expirationDateCheckIV];
    
    UIImageView *CVVcheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptedNot"]];
    CVVcheckIV.frame = CGRectMake(self.view.frame.size.width - 30, 54, 24, 24);
//    [container addSubview:CVVcheckIV];
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    top.alpha = 1;
    top.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:top];
    
    UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 0.5)];
    middle.alpha = 1;
    middle.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:middle];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 88, self.view.bounds.size.width, 0.5)];
    bottom.alpha = 1;
    bottom.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:bottom];
    
    self.rightAlignedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightAlignedButton addTarget:self action:@selector(saveCard) forControlEvents:UIControlEventTouchUpInside];
    self.rightAlignedButton.frame = CGRectMake(self.view.frame.size.width - 105, cardViewport.frame.size.height + 88, 105, 44);
    [self.rightAlignedButton setTitle:@"SAVE CARD" forState:UIControlStateNormal];
    [self.rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.rightAlignedButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    
    [_contentScroller addSubview:self.rightAlignedButton];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        self.debitButton.alpha = 1.0;
        self.bankButton.alpha = 0.7;
    }
    else if (scrollView.contentOffset.x == scrollView.frame.size.width) {
        self.bankButton.alpha = 1.0;
        self.debitButton.alpha = 0.7;
    }
}

-(void)configureBankView {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor whiteColor];
    
    _accountNumberField  = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - (32), 44)];
    _accountNumberField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    _accountNumberField.placeholder =  @"Account Number";
    _accountNumberField.textColor = [UIColor frescoDarkTextColor];
    _accountNumberField.tintColor = [UIColor frescoBlueColor];
    _accountNumberField.delegate = self;
    [_accountNumberField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    _accountNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [_accountNumberField setSecureTextEntry: NO];

    [container addSubview:_accountNumberField];
    [_bankView addSubview:container];
    container.frame = CGRectMake(0, 0, self.view.frame.size.width, _accountNumberField.frame.size.height * 2);
    
    _routingNumberField  = [[UITextField alloc] initWithFrame:CGRectMake(16, 44, [UIScreen mainScreen].bounds.size.width - (32), 44)];
    _routingNumberField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    _routingNumberField.placeholder =  @"Routing Number";
    _routingNumberField.textColor = [UIColor frescoDarkTextColor];
    _routingNumberField.tintColor = [UIColor frescoBlueColor];
    _routingNumberField.delegate = self;
    [_routingNumberField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    _routingNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [_routingNumberField setSecureTextEntry: NO];
    
    [container addSubview:_routingNumberField];
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    top.alpha = 1;
    top.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:top];
    
    UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 0.5)];
    middle.alpha = 1;
    middle.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:middle];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 88, self.view.bounds.size.width, 0.5)];
    bottom.alpha = 1;
    bottom.backgroundColor = [UIColor frescoLightTextColor];
    [container addSubview:bottom];
    
    self.saveBankButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveBankButton addTarget:self action:@selector(saveBankInfo) forControlEvents:UIControlEventTouchUpInside];
    self.saveBankButton.frame = CGRectMake(self.view.frame.size.width - 160, bottom.frame.origin.y+5, 160, 44);
    [self.saveBankButton setTitle:@"SAVE BANK ACCOUNT" forState:UIControlStateNormal];
    [self.saveBankButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.saveBankButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    
    [container addSubview:self.saveBankButton];
}

-(void)bankTapped {
    [_contentScroller setContentOffset:CGPointMake(_contentScroller.frame.size.width, 0) animated:YES];
    self.bankButton.alpha = 1.0;
    self.debitButton.alpha = 0.7;

}

-(void)debitTapped {
    [_contentScroller setContentOffset:CGPointMake(0, 0) animated:YES];
    self.debitButton.alpha = 1.0;
    self.bankButton.alpha = 0.7;
}

-(void)saveBankInfo {
    
    NSLog(@"SAVING BANK INFO");
    
    NSString *bankAccountNumber = _accountNumberField.text;
    NSString *routingNumber = _routingNumberField.text;
    
    STPBankAccountParams *params = [FRSStripe bankAccountWithNumber:bankAccountNumber routing:routingNumber name:Nil ssn:Nil type:FRSBankAccountTypeIndividual];
    [FRSStripe createTokenWithBank:params completion:^(STPToken *stripeToken, NSError *error) {
        NSLog(@"%@ %@", stripeToken, error);
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [CardIOUtilities preload];
    CardIOView *cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0, -185, self.view.frame.size.width, self.view.frame.size.height)];
    cardIOView.delegate = self;
    
    [cardViewport addSubview:cardIOView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)cardIOView:(CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)info {
    if (info) {
        NSString *cardNumber = info.cardNumber;
      //  NSString *name = info.cardholderName;
        NSInteger expirationYear = info.expiryYear;
        NSInteger expirationMonth = info.expiryMonth;
        NSString *cvv = info.cvv;
        
        if (cardNumber) {
            cardNumberTextField.text = cardNumber;
        }
        
        if (cvv) {
            securityCodeTextField.text = cvv;
        }
        
        if (expirationYear != 0 && expirationMonth != 0) {
            expirationDateTextField.text = [NSString stringWithFormat:@"%@%lu/%lu", (expirationMonth < 10) ? @"0" : @"", (long)expirationMonth, (long)expirationYear];
        }
        
        [cardIOView removeFromSuperview];
        CardIOView *cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0, -185, self.view.frame.size.width, self.view.frame.size.height)];
        cardIOView.delegate = self;
        
        [cardViewport addSubview:cardIOView];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == _routingNumberField || textField == _accountNumberField) {
        return TRUE;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _routingNumberField || textField == _accountNumberField) {
        return TRUE;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.view endEditing:YES];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    
    if (cardNumberTextField.isEditing) {
        NSLog(@"CARD NUMBER: %@", cardNumberTextField);
    } else if (expirationDateTextField.isEditing) {
        NSLog(@"EXP DATE: %@", expirationDateTextField);
    } else if (securityCodeTextField.isEditing) {
        NSLog(@"CVV: %@", securityCodeTextField);
    }

    
    
    if ((cardNumberTextField.text.length == 16) && (securityCodeTextField.text.length >=3)) {
        [self.rightAlignedButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.rightAlignedButton.userInteractionEnabled = YES;
    }
    
    if (_accountNumberField.text.length > 0 && _routingNumberField.text.length == 9) {
        [self.saveBankButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.saveBankButton.userInteractionEnabled = YES;
        self.saveBankButton.enabled = TRUE;
    }
    
    
    return YES;
}


-(void)saveCard {
    
    NSArray *components = [expirationDateTextField.text componentsSeparatedByString:@"/"];
    NSArray *expiration;
    
    if (components.count == 2) {
        expiration = @[@([components[0] intValue]), @([components[1] intValue])];
    }
    else {
        self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT CARD INFORMATION" message:@"Please make sure your expiration date info is correct and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.alertView show];

        return;
    }
    
    STPCardParams *params = [FRSStripe creditCardWithNumber:cardNumberTextField.text expiration:expiration cvc:securityCodeTextField.text];
    
    if (!params) {
        self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT CARD INFORMATION" message:@"Please check your card information and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.alertView show];

    }
    
    NSLog(@"CARD PARAMS: %@", params);
    
    [FRSStripe createTokenWithCard:params completion:^(STPToken *stripeToken, NSError *error) {
        NSLog(@"TOKEN: %@ \n TOKEN_ERROR:%@", stripeToken, error);
        [[FRSAPIClient sharedClient] createPaymentWithToken:stripeToken.tokenId completion:^(id responseObject, NSError *error) {
            //
            NSLog(@"RESP: %@ \n ERR:%@", responseObject, error);
            if (error) {
                self.alertView = [[FRSAlertView alloc] initWithTitle:@"CARD ERROR" message:@"We were unable to save your debit card information at this time. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                [self.alertView show];
            }
            else if (responseObject) {
                NSString *brand = [responseObject objectForKey:@"brand"];
                NSString *last4 = [responseObject objectForKey:@"last4"];
                
                if ([[responseObject valueForKey:@"valid"] boolValue]) {
                    NSString *creditCard = [NSString stringWithFormat:@"%@ %@", brand, last4];
                    [[[FRSAPIClient sharedClient] authenticatedUser] setValue:creditCard forKey:@"creditCardDigits"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    self.alertView = [[FRSAlertView alloc] initWithTitle:@"CARD ERROR" message:@"The card you entered was invalid. Please try again." actionTitle:@"TRY AGAIN" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                    [self.alertView show];
                }
            }
        }];
    }];
}

-(void)didPressButtonAtIndex:(NSInteger)index {
    
}

-(void)keyboardDidShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.35 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(0, -30, self.view.frame.size.width,self.view.frame.size.height);
    } completion:nil];
}


-(void)keyboardDidHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.35 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width,self.view.frame.size.height);
    } completion:nil];
}


-(void)dismissKeyboard {
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}


@end