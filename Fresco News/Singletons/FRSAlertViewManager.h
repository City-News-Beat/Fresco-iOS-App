//
//  FRSAlertViewManager.h
//  Fresco
//
//  Created by Elmir Kouliev on 7/28/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSAlertViewManager : NSObject

/**
 *  Returns a UIAlertController with specified params
 *
 *  @param title   The title of the alert
 *  @param message The message of the alert
 *  @param action  The string on the action button
 *
 *  @return A UIAlertController
 */

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action;

/**
 *  Returns a UIAlertController with specified params
 *
 *  @param title   The title of the alert
 *  @param message The message of the alert
 *  @param action  The string on the action button
 *  @param handler The response block for when the error is dismissed
 *  @return A UIAlertController
 */

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action handler:(void (^)(UIAlertAction *action))handler;

@end
