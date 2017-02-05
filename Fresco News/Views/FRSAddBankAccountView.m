//
//  FRSAddBankAccountView.m
//  Fresco
//
//  Created by User on 2/4/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAddBankAccountView.h"
#import "UIColor+Fresco.h"

@implementation FRSAddBankAccountView

- (void)setupUI {
    [self.accountNumberTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
    [self.routingNumberTextField addTarget:self action:@selector(textField:shouldChangeCharactersInRange:replacementString:) forControlEvents:UIControlEventEditingChanged];
}

- (void)dismissKeyboard {
    [self.accountNumberTextField resignFirstResponder];
    [self.routingNumberTextField resignFirstResponder];
}

- (IBAction)saveBankAccount:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSaveBankButtonPressed:routingNumber:)]) {
        [self.delegate didSaveBankButtonPressed:self.accountNumberTextField.text routingNumber:self.routingNumberTextField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    if (self.accountNumberTextField.text.length > 0 && self.routingNumberTextField.text.length == 9) {
        [self.saveButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        self.saveButton.userInteractionEnabled = YES;
        self.saveButton.enabled = YES;
    }
    
    if (textField == self.accountNumberTextField) {
        if (range.location > 16) {
            return NO;
        }
    }
    
    if (textField == self.routingNumberTextField) {
        if (range.location > 8) {
            return NO;
        }
    }
    
    return YES;
}

@end
