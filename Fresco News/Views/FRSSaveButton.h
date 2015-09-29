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

- (void)updateSaveState:(SaveState)state;

- (void)toggleSpinner;
    
@end
