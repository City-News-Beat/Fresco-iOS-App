//
//  FRSPermissionAlertView.h
//  Fresco
//
//  Created by Maurice Wu on 2/26/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
#import <Foundation/Foundation.h>

@class FRSAlertView;

@interface FRSPermissionAlertView : FRSAlertView

- (instancetype)initWithLocationManagerDelegate:(id)delegate;
- (void)show;

@end
