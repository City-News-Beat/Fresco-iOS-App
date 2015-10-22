//
//  FRSAlertViewManager.m
//  Fresco
//
//  Created by Elmir Kouliev on 7/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSAlertViewManager.h"

@implementation FRSAlertViewManager

#pragma mark - UIAlertController Object Methods

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action{

    return [self alertControllerWithTitle:title message:message action:action handler:nil];
    
}

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action handler:(void (^)(UIAlertAction *))handler{
    
  
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:(action == nil ? @"Dismiss" : action)
                                              style:UIAlertActionStyleDefault
                                            handler:handler]];
    
    return alert;

}

@end
