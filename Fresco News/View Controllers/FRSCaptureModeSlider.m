//
//  FRSCaptureModeSlider.m
//  Fresco
//
//  Created by Omar Elfanek on 4/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCaptureModeSlider.h"

@interface FRSCaptureModeSlider ();
@property NSInteger currentIndex;
@end

@implementation FRSCaptureModeSlider

- (instancetype)initWithFrame:(CGRect)frame captureMode:(FRSCaptureMode)captureMode {
    self = [super initWithFrame:frame];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
        
        [self setCaptureMode:captureMode];
    }
    
    return self;
}

- (void)setCaptureMode:(FRSCaptureMode)captureMode {
    [self centerViewForCaptureMode:captureMode];
    self.currentIndex = captureMode;
}



- (void)centerViewForCaptureMode:(FRSCaptureMode)index {
    
    index++; // Add 1 to the index to reflect the acturate position of the button.
    
    // Note: All the captureMode buttons in the nib are 100px wide and have 0px padding inbetween.
    // By adding the width of all the buttons to the left of the given index, and subtracting half the width of the final button (the button we want in the center),
    // we're able to take this value and subtract it by half the width of the screen to place the desired button in the center of the screen.
    
    NSInteger buttonWidth = 100;
    NSInteger offset = (buttonWidth * index) - buttonWidth/2;
    
    self.frame = CGRectMake([UIApplication sharedApplication].keyWindow.frame.size.width/2 - offset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}



- (void)swipeLeft {
    if (self.currentIndex == CAPTURE_MODE_COUNT-1) return;

    [self setCaptureMode:self.currentIndex+1];
}

- (void)swipeRight {
    if (self.currentIndex == 0 ) return;

    [self setCaptureMode:self.currentIndex-1];
}

@end
