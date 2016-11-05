//
//  FRSTextView.m
//  Fresco
//
//  Created by Philip Bernstein on 8/24/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTextView.h"

@implementation FRSTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    // discard all recognizers but the one that activates links, by just not calling super
    // (in iOS 9.2.3 a short press for links is 0.12s, long press for selection is 0.75s)
    
    if ([gestureRecognizer isMemberOfClass:UILongPressGestureRecognizer.class] &&
        ((UILongPressGestureRecognizer*)gestureRecognizer).minimumPressDuration < 0.25) {
        
        ((UILongPressGestureRecognizer*)gestureRecognizer).minimumPressDuration = 0.0;
        [super addGestureRecognizer:gestureRecognizer];
    }
}


@end
