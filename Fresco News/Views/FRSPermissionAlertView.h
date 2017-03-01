//
//  FRSPermissionAlertView.h
//  Fresco
//
//  Created by Maurice Wu on 2/26/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSPermissionAlertView : UIView

@property (weak, nonatomic) NSObject<FRSAlertViewDelegate> *delegate;

- (instancetype)initWithLocationManagerDelegate:(id)delegate;
- (void)show;

@end
