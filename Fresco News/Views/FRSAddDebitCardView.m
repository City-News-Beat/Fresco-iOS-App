//
//  FRSAddDebitCardView.m
//  Fresco
//
//  Created by Maurice Wu on 2/4/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAddDebitCardView.h"
#import "UIColor+Fresco.h"

@implementation FRSAddDebitCardView

- (void)setupUI {
    [self.securityCodeTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    [self.cardNumberTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    [self.expirationDateTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setupCardIO {
    [CardIOUtilities preload];
    CardIOView *cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width * 1.34)];

    cardIOView.delegate = self;
    [self.cardViewport addSubview:cardIOView];
    cardIOView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 4);
}

- (void)dismissKeyboard {
    [self.cardNumberTextField resignFirstResponder];
    [self.securityCodeTextField resignFirstResponder];
    [self.expirationDateTextField resignFirstResponder];
}

- (void)cardIOView:(CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)info {
    if (info) {
        NSString *cardNumber = info.cardNumber;
        NSInteger expirationYear = info.expiryYear;
        NSInteger expirationMonth = info.expiryMonth;
        NSString *cvv = info.cvv;

        if (cardNumber) {
            self.cardNumberTextField.text = cardNumber;
        }

        if (cvv) {
            self.securityCodeTextField.text = cvv;
        }

        if (expirationYear != 0 && expirationMonth != 0) {
            self.expirationDateTextField.text = [NSString stringWithFormat:@"%@%lu/%lu", (expirationMonth < 10) ? @"0" : @"", (long)expirationMonth, (long)expirationYear];
        }

        [cardIOView removeFromSuperview];
        CardIOView *cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0, 0, self.cardViewport.frame.size.width, self.cardViewport.frame.size.height)];
        cardIOView.delegate = self;

        [self.cardViewport addSubview:cardIOView];
    }
}

- (IBAction)saveDebitCard:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSaveDebitCardButtonPressed:expDate:cvv:)]) {
        [self.delegate didSaveDebitCardButtonPressed:self.cardNumberTextField.text expDate:self.expirationDateTextField.text cvv:self.securityCodeTextField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    if ((self.cardNumberTextField.text.length >= 15) && (self.securityCodeTextField.text.length >= 3) && (self.expirationDateTextField.text.length >= 5)) {
        self.saveButton.enabled = YES;
    }
    else {
        self.saveButton.enabled = NO;
    }

    if (textField == self.cardNumberTextField) {
        if (range.location > 20) {
            return NO;
        }
    }

    if (textField == self.expirationDateTextField) {
        if (range.location > 4) {
            return NO;
        }
        if (textField.text != Nil && ![textField.text isEqualToString:@""] && string) {
            NSString *proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
            if (proposedNewString != Nil && proposedNewString.length == 2 && textField.text.length <= 2) {
                proposedNewString = [proposedNewString stringByAppendingString:@"/"];
                textField.text = proposedNewString;
                return NO;
            }
        }
    }

    if (textField == self.securityCodeTextField) {
        if (range.location > 3) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [self endEditing:YES];
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.frame = CGRectMake(0, -64, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}

@end
