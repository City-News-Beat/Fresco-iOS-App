//
//  FRSAlertViewManager.m
//  Fresco
//
//  Created by Elmir Kouliev on 7/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSAlertViewManager.h"

@implementation FRSAlertViewManager

#pragma mark - static methods

+ (FRSAlertViewManager *)sharedManager
{
    static FRSAlertViewManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[FRSAlertViewManager alloc] init];
    });
    
    return manager;
}


- (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:(action == nil ? @"Ok" : action)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    
    return alert;

}

@end
