//
//  FRSSaveButton.h
//  Fresco
//
//  Created by Elmir Kouliev on 9/24/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SaveStateEnabled,
    SaveStateDisabled
} SaveState;

@interface FRSSaveButton : UIButton

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title;

/**
 *  Update the state of the button to either disabled or enabled
 *
 *  @param state The state othe button
 */

- (void)updateSaveState:(SaveState)state;

/**
 *  Toggles the state of the spinner between animation / not-animating
 */

- (void)toggleSpinner;
    
@end
