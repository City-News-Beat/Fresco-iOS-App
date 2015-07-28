//
//  FRSAlertViewManager.h
//  Fresco
//
//  Created by Elmir Kouliev on 7/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSAlertViewManager : NSObject

+ (FRSAlertViewManager *)sharedManager;

- (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action;
@end
