//
//  FRSSignUpAlertView.h
//  Fresco
//
//  Created by Maurice Wu on 3/8/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSSignUpAlertView : FRSAlertView

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

- (instancetype)initSignUpAlert;

@end
