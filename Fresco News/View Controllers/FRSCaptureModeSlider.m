//
//  FRSCaptureModeSlider.m
//  Fresco
//
//  Created by Omar Elfanek on 4/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCaptureModeSlider.h"
#import "UIFont+Fresco.h"

@interface FRSCaptureModeSlider ();
@property (weak, nonatomic) IBOutlet UIButton *interviewButton;
@property (weak, nonatomic) IBOutlet UIButton *panButton;
@property (weak, nonatomic) IBOutlet UIButton *wideButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property BOOL isFirstRun;
@property BOOL shouldHideNewFeaturesForABTesting;

@property NSInteger numberOfCaptureModes;

@end

@implementation FRSCaptureModeSlider

- (instancetype)initWithFrame:(CGRect)frame captureMode:(FRSCaptureMode)captureMode {
    self = [super initWithFrame:frame];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.frame = frame;
        
        self.isFirstRun = YES;
        [self setCaptureMode:captureMode];
        
        self.numberOfCaptureModes = self.shouldHideNewFeaturesForABTesting ? 2 : 5;
        
    }
    
    return self;
}


- (void)setCaptureMode:(FRSCaptureMode)captureMode {
    [UIView animateWithDuration:self.isFirstRun ? 0.0 : 0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self centerViewForCaptureMode:captureMode];
        [self highlightButtonForCaptureMode:captureMode];
    } completion:^(BOOL finished) {
        self.isFirstRun = NO;
    }];

    self.currentIndex = captureMode;

    // Update UI in the parent controller to reflect the photo/video states accordingly.
    if (self.delegate) {
        [self.delegate captureModeDidUpdate:captureMode];
    }
}


/**
 This method takes in a capture mode and highlights the corresponding button.

 @param captureMode FRSCaptureMode used to determine which button should be highlighted.
 */
- (void)highlightButtonForCaptureMode:(FRSCaptureMode)captureMode {

    [self resetAllButtonsToColor:(captureMode == FRSCaptureModePhoto ? [UIColor frescoLightTextColor] : [UIColor whiteColor]) font:[UIFont notaMediumWithSize:15]];
    
    switch (captureMode) {
        case FRSCaptureModeInterview:
            [self highlightButton:self.interviewButton];
            break;
        case FRSCaptureModePan:
            [self highlightButton:self.panButton];
            break;
        case FRSCaptureModeWide:
            [self highlightButton:self.wideButton];
            break;
        case FRSCaptureModeVideo:
            [self highlightButton:self.videoButton];
            break;
        case FRSCaptureModePhoto:
            [self.photoButton setTitleColor:[UIColor frescoMediumTextColor] forState:UIControlStateNormal];
            [self.photoButton.titleLabel setFont:[UIFont notaXBoldWithSize:15]];
            break;
            
        default:
            break;
    }
}


/**
 This method sets the passed in buttons text color and font weight to a selected state.

 @param button UIButton to be highlighted.
 */
- (void)highlightButton:(UIButton *)button {
    [button setTitleColor:[UIColor frescoOrangeColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont notaXBoldWithSize:15]];
}


/**
 This method resets all the buttons in the view to the unselected state.

 @param color UIColor The color for the buttons default state.
 @param font UIFont The font for the buttons default state.
 */
- (void)resetAllButtonsToColor:(UIColor *)color font:(UIFont *)font {
    [self.photoButton setTitleColor:color forState:UIControlStateNormal];
    [self.videoButton setTitleColor:color forState:UIControlStateNormal];
    [self.wideButton setTitleColor:color forState:UIControlStateNormal];
    [self.panButton setTitleColor:color forState:UIControlStateNormal];
    [self.interviewButton setTitleColor:color forState:UIControlStateNormal];

    [self.interviewButton.titleLabel setFont:font];
    [self.panButton.titleLabel setFont:font];
    [self.wideButton.titleLabel setFont:font];
    [self.videoButton.titleLabel setFont:font];
    [self.photoButton.titleLabel setFont:font];
}


/**
 This method centers the button at the given index in the center of the parent view.

 @param index FRSCaptureMode to be passed
 */
- (void)centerViewForCaptureMode:(FRSCaptureMode)index {
    
    index++; // Add 1 to the index to reflect the acturate position of the button.
    
    // Note: All the captureMode buttons in the nib are 100px wide and have 0px padding inbetween.
    // By adding the width of all the buttons to the left of the given index, and subtracting half the width of the final button (the button we want in the center),
    // we're able to take this value and subtract it by half the width of the screen to place the desired button in the center of the screen.
    
    NSInteger buttonWidth = 100;
    NSInteger offset = (buttonWidth * index) - buttonWidth/2;
    
    self.frame = CGRectMake([UIApplication sharedApplication].keyWindow.frame.size.width/2 - offset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}



#pragma mark - Gesture Recognizers
- (void)swipeLeft {
    if (self.currentIndex == CAPTURE_MODE_COUNT-1) return;


    [self setCaptureMode:self.currentIndex+1];
}

- (void)swipeRight {
    if (self.currentIndex == 0 ) return;
    if (self.shouldHideNewFeaturesForABTesting) {
        if (self.currentIndex == 3) return;
    }
    [self setCaptureMode:self.currentIndex-1];
}

#pragma mark - Button Actions

- (IBAction)interviewTapped:(id)sender {
    [self setCaptureMode:FRSCaptureModeInterview];
}

- (IBAction)panTapped:(id)sender {
    [self setCaptureMode:FRSCaptureModePan];
}

- (IBAction)wideTapped:(id)sender {
    [self setCaptureMode:FRSCaptureModeWide];
}

- (IBAction)videoTapped:(id)sender {
    [self setCaptureMode:FRSCaptureModeVideo];
}

- (IBAction)photoButton:(id)sender {
    [self setCaptureMode:FRSCaptureModePhoto];
}


#pragma mark - AB Testing

- (void)hideNewFeaturesForABTesting {
    self.shouldHideNewFeaturesForABTesting = YES;
    [self.interviewButton removeFromSuperview];
    [self.panButton removeFromSuperview];
    [self.wideButton removeFromSuperview];
}







@end
