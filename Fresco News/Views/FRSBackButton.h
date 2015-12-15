//
//  FRSBackButton.h
//  Fresco
//
//  Created by Omar El-Fanek on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSBackButtonDelegate <NSObject>

@required

- (void)backButtonTapped;

@end

@interface FRSBackButton : UIButton

@property id<FRSBackButtonDelegate> delegate;

/**
 *  Creates an FRSBackButton
 *
 *  @return returns the back button
 */

+ (FRSBackButton *)createBackButton;
+ (FRSBackButton *)createLightBackButtonWithTitle:(NSString *)title;

@end