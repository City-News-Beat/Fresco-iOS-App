//
//  FRSCaptureModeSlider.m
//  Fresco
//
//  Created by Omar Elfanek on 4/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCaptureModeSlider.h"

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
    
    switch (captureMode) {
        case FRSCaptureModePhoto:
            
            break;
            
        case FRSCaptureModeVideo:
            
            break;
            
        case FRSCaptureModeWide:
            
            break;
        
        case FRSCaptureModePan:
            
            break;
        
        case FRSCaptureModeInterview:
            
            break;
            
        default:
            break;
    }
}

@end
