//
//  FRSAddBankAccountView.h
//  Fresco
//
//  Created by User on 2/4/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSAddBankAccountViewDelegate <NSObject>
- (void)didSaveBankButtonPressed:(NSString *)accountNumber routingNumber:(NSString *)routingNumber;
@end

@interface FRSAddBankAccountView : UIView

@property (nonatomic, weak) IBOutlet UITextField *accountNumberTextField;
@property (nonatomic, weak) IBOutlet UITextField *routingNumberTextField;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) NSObject<FRSAddBankAccountViewDelegate> *delegate;

- (void)setupUI;
- (void)dismissKeyboard;

@end
