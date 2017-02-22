//
//  FRSDebitCardViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDebitCardViewController.h"
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"
#import "FRSStripe.h"
#import "FRSAlertView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "EndpointManager.h"
#import "FRSUserManager.h"
#import "FRSPaymentManager.h"
#import <UXCam/UXCam.h>
#import "FRSAddBankAccountView.h"
#import "FRSAddDebitCardView.h"

@interface FRSDebitCardViewController () <FRSAddDebitCardViewDelegate, FRSAddBankAccountViewDelegate>

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardGestureRecognizer;

@property (strong, nonatomic) NSString *CVV;

@property (strong, nonatomic) FRSAlertView *alertView;
@property (strong, nonatomic) UIScrollView *contentScroller;
@property (strong, nonatomic) UIButton *debitButton;
@property (strong, nonatomic) UIButton *bankButton;
@property (strong, nonatomic) FRSAddDebitCardView *addDebitCardView;
@property (strong, nonatomic) FRSAddBankAccountView *addBankAccountView;

@end

@implementation FRSDebitCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    self.addDebitCardView = [[[NSBundle mainBundle] loadNibNamed:@"FRSAddDebitCardView" owner:self options:nil] objectAtIndex:0];
    self.addBankAccountView = [[[NSBundle mainBundle] loadNibNamed:@"FRSAddBankAccountView" owner:self options:nil] objectAtIndex:0];
    self.addDebitCardView.delegate = self;
    self.addBankAccountView.delegate = self;
    [self.addDebitCardView setupUI];
    [self.addBankAccountView setupUI];

    [self configureView];
    self.title = @"DEBIT CARD";

    [self configureBackButtonAnimated:NO];

    self.dismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.dismissKeyboardGestureRecognizer];
    [self configureDismissKeyboardGestureRecognizer];

    [self hideSensitiveViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.addDebitCardView setupCardIO];

    if (self.shouldDisplayBankViewOnLoad) {
        [self configureBankFromNavigationController];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)configureView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.navigationItem.titleView = titleView;

    self.debitButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 10 - titleView.frame.size.width / 6 - 40, 6, 120, 30)];
    [self.debitButton setTitle:@"DEBIT CARD" forState:UIControlStateNormal];
    [self.debitButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.debitButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.debitButton addTarget:self action:@selector(debitTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.debitButton];

    self.bankButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width / 2 - 60 - 10 + titleView.frame.size.width / 6 - 40, 6, 120, 30)];
    self.bankButton.alpha = 0.7;
    [self.bankButton setTitle:@"BANK ACCOUNT" forState:UIControlStateNormal];
    [self.bankButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
    [self.bankButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.bankButton addTarget:self action:@selector(bankTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.bankButton];

    _contentScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _contentScroller.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height - 100);
    _contentScroller.bounces = YES;
    _contentScroller.pagingEnabled = YES;
    _contentScroller.delegate = self;

    [self.view addSubview:_contentScroller];

    [self.addDebitCardView setFrame:CGRectMake(0, 0, self.view.frame.size.width, _contentScroller.contentSize.height)];
    [self.addBankAccountView setFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, _contentScroller.contentSize.height)];
    [_contentScroller addSubview:self.addDebitCardView];
    [_contentScroller addSubview:self.addBankAccountView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        self.debitButton.alpha = 1.0;
        self.bankButton.alpha = 0.7;
    } else if (scrollView.contentOffset.x == scrollView.frame.size.width) {
        self.bankButton.alpha = 1.0;
        self.debitButton.alpha = 0.7;
    }

    [self.addDebitCardView dismissKeyboard];
    [self.addBankAccountView dismissKeyboard];
}

- (void)configureBankFromNavigationController {
    [_contentScroller setContentOffset:CGPointMake(_contentScroller.frame.size.width, 0) animated:NO];
    self.bankButton.alpha = 1.0;
    self.debitButton.alpha = 0.7;
}

- (void)bankTapped {
    [self.addDebitCardView dismissKeyboard];
    [_contentScroller setContentOffset:CGPointMake(_contentScroller.frame.size.width, 0) animated:YES];
    self.bankButton.alpha = 1.0;
    self.debitButton.alpha = 0.7;
}

- (void)debitTapped {
    [self.addBankAccountView dismissKeyboard];
    [_contentScroller setContentOffset:CGPointMake(0, 0) animated:YES];
    self.debitButton.alpha = 1.0;
    self.bankButton.alpha = 0.7;
}

- (void)createPaymentWithToken:(NSString *)stripeToken isDebitCard:(BOOL)debitCard {
    [[FRSPaymentManager sharedInstance] createPaymentWithToken:stripeToken
                                                    completion:^(id responseObject, NSError *error) {
                                                      if (error) {
                                                          NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                          if (response && response.statusCode == 500) {
                                                              NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSASCIIStringEncoding];
                                                              NSData *data = [errorString dataUsingEncoding:NSUTF8StringEncoding];
                                                              id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                              NSDictionary *errorDict = json[@"error"];
                                                              NSString *errorMessage = errorDict[@"msg"];
                                                              self.alertView = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:errorMessage actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                                          } else {
                                                              self.alertView = [[FRSAlertView alloc] initWithTitle:@"SAVE ID ERROR" message:error.localizedDescription actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                                          }
                                                          [self.alertView show];
                                                      } else if (responseObject) {
                                                          NSString *brand = [responseObject objectForKey:@"brand"];
                                                          NSString *last4 = [responseObject objectForKey:@"last4"];

                                                          if (debitCard) {
                                                              if ([[responseObject valueForKey:@"valid"] boolValue]) {
                                                                  NSString *creditCard = [NSString stringWithFormat:@"%@ %@", brand, last4];
                                                                  [[[FRSUserManager sharedInstance] authenticatedUser] setValue:creditCard forKey:@"creditCardDigits"];
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              } else {
                                                                  self.alertView = [[FRSAlertView alloc] initWithTitle:@"CARD ERROR" message:@"The card you entered was invalid. Please try again." actionTitle:@"TRY AGAIN" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                                                  [self.alertView show];
                                                              }
                                                          } else {
                                                              NSString *creditCard = [NSString stringWithFormat:@"%@ %@", brand, last4];

                                                              [[[FRSUserManager sharedInstance] authenticatedUser] setValue:creditCard forKey:@"creditCardDigits"];
                                                              [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }

                                                          [self stopSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];
                                                      }
                                                    }];
}

- (void)didSaveDebitCardButtonPressed:(NSString *)cardNumber expDate:(NSString *)expDate cvv:(NSString *)cvv {
    if (!self.loadingView) {
        [self configureSpinner];
    }

    [self startSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];

    NSArray *components = [expDate componentsSeparatedByString:@"/"];
    NSArray *expiration;

    if (components.count == 2) {
        expiration = @[ @([components[0] intValue]), @([components[1] intValue]) ];
    } else {
        self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT CARD INFORMATION" message:@"Please make sure your expiration date info is correct and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.alertView show];
        [self stopSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];
        return;
    }

    STPCardParams *params = [FRSStripe creditCardWithNumber:cardNumber expiration:expiration cvc:cvv];

    if (!params) {
        self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT CARD INFORMATION" message:@"Please check your card information and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.alertView show];
        [self stopSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];
        return;
    }

    [FRSStripe createTokenWithCard:params
                        completion:^(STPToken *stripeToken, NSError *error) {
                          if (error || !stripeToken) {
                              self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT CARD INFORMATION" message:error.localizedDescription actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                              [self.alertView show];
                              [self stopSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];
                              return;
                          }
                          [self createPaymentWithToken:stripeToken.tokenId isDebitCard:YES];
                        }];
}

- (void)didSaveBankButtonPressed:(NSString *)accountNumber routingNumber:(NSString *)routingNumber {
    if (!self.loadingView) {
        [self configureSpinner];
    }

    [self startSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];

    STPBankAccountParams *bankParams = [[STPBankAccountParams alloc] init];
    bankParams.accountNumber = accountNumber;
    bankParams.routingNumber = routingNumber;
    bankParams.currency = @"USD";
    bankParams.accountHolderType = STPBankAccountHolderTypeIndividual;
    bankParams.country = @"US";

    if (!bankParams) {
        self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT BANK INFORMATION" message:@"Please make sure your expiration date info is correct and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.alertView show];
        [self stopSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];
        return;
    }

    [[STPAPIClient sharedClient] createTokenWithBankAccount:bankParams
                                                 completion:^(STPToken *_Nullable token, NSError *_Nullable error) {
                                                   // created token
                                                   if (error || !token) {
                                                       // failed
                                                       self.alertView = [[FRSAlertView alloc] initWithTitle:@"INCORRECT BANK INFORMATION" message:error.localizedDescription actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                                       [self.alertView show];
                                                       [self stopSpinner:self.loadingView onButton:self.addDebitCardView.saveButton];

                                                       return;
                                                   }
                                                   [self createPaymentWithToken:token.tokenId isDebitCard:NO];
                                                 }];
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

- (void)dismissKeyboard {
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - UXCam

- (void)hideSensitiveViews {
    [UXCam occludeSensitiveView:self.addDebitCardView.cardNumberTextField];
    [UXCam occludeSensitiveView:self.addBankAccountView.routingNumberTextField];
    [UXCam occludeSensitiveView:self.addBankAccountView.accountNumberTextField];
}

@end

