//
//  FRSAddDebitCardView.h
//  Fresco
//
//  Created by Maurice Wu on 2/4/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"

@protocol FRSAddDebitCardViewDelegate <NSObject>
- (void)didSaveDebitCardButtonPressed:(NSString *)cardNumber expDate:(NSString *)expDate cvv:(NSString *)cvv;
@end

@interface FRSAddDebitCardView : UIView <UITextFieldDelegate, CardIOViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *cardViewport;
@property (nonatomic, weak) IBOutlet UITextField *cardNumberTextField;
@property (nonatomic, weak) IBOutlet UITextField *expirationDateTextField;
@property (nonatomic, weak) IBOutlet UITextField *securityCodeTextField;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) NSObject<FRSAddDebitCardViewDelegate> *delegate;

- (void)setupUI;
- (void)setupCardIO;
- (void)dismissKeyboard;

@end
