//
//  FRSConnectivityAlertView.h
//  Fresco
//
//  Created by Maurice Wu on 3/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSConnectivityAlertView : FRSAlertView

- (instancetype)initNoConnectionAlert;
- (instancetype)initNoConnectionBannerWithBackButton:(BOOL)backButton;

@end
