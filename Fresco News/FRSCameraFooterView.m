//
//  FRSCameraFooterView.m
//  Fresco
//
//  Created by Omar Elfanek on 5/1/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCameraFooterView.h"
#import "UIView+Helpers.h"
#import "UIFont+Fresco.h"

@interface FRSCameraFooterView() <FRSCaptureModeSliderDelegate>;

@property (strong, nonatomic) UIButton *nextButton;
@property BOOL torchIsOn;
@property BOOL flashIsOn;

@end

@implementation FRSCameraFooterView

- (instancetype)initWithDelegate:(id)delegate {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        [self configureUI];
    }
    
    return self;
}

- (void)configureUI {
    [self configureFrame];
    [self configureNextButton];
    [self configureSlider];
    [self configureTipsButton];
    [self configureFlashButton];
}

- (void)configureFrame {
    CGSize window = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, (window.width * PHOTO_FRAME_RATIO), window.width, window.height - (window.width * PHOTO_FRAME_RATIO) + SLIDER_HEIGHT);
    self.backgroundColor = [UIColor frescoTransparentDarkColor];
}

#pragma mark - Capture Mode Slider
- (void)configureSlider {
    self.captureModeSlider = [[FRSCaptureModeSlider alloc] initWithFrame:CGRectMake(0, 0, SLIDER_WIDTH, SLIDER_HEIGHT) captureMode:FRSCaptureModeVideo];
    self.captureModeSlider.delegate = self;
    [self addSubview:self.captureModeSlider];
}

- (void)captureModeDidUpdate:(FRSCaptureMode)captureMode {
    if (captureMode == FRSCaptureModePhoto) {
        [self toggleCaptureModeForPhoto:YES];
    } else {
        [self toggleCaptureModeForPhoto:NO];
    }
    
    if (self.delegate) {
        [self.delegate captureModeDidUpdate:captureMode];
    }
    
    [self setAppropriateIconsForCaptureState];
}

#pragma mark - Footer States
- (void)toggleCaptureModeForPhoto:(BOOL)isPhoto {
    if (isPhoto) {
        self.backgroundColor = [UIColor frescoBackgroundColorDark];
    } else {
        self.backgroundColor = [UIColor frescoTransparentDarkColor];
    }
}


#pragma mark - Next Button
// TODO: Move this button into it's own class
- (void)configureNextButton {
    self.nextButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(SIDE_PAD, 0, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    self.nextButtonContainer.backgroundColor = [UIColor whiteColor];
    [self.nextButtonContainer centerVerticallyInView:self];
    self.nextButtonContainer.userInteractionEnabled = YES;
    [self addSubview:self.nextButtonContainer];
    self.nextButtonContainer.layer.cornerRadius = PREVIEW_WIDTH/2;
    [self.nextButtonContainer addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, PREVIEW_WIDTH - 8, PREVIEW_WIDTH - 8)];
    self.nextButton.contentMode = UIViewContentModeScaleAspectFill;
    self.nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.nextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.nextButton addTarget:self action:@selector(previewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton clipAsCircle];
    [self.nextButtonContainer addSubview:self.nextButton];
    
    UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(-4, -4, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    nextLabel.text = @"";
    nextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:.26];
    nextLabel.font = [UIFont notaBoldWithSize:15];
    nextLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    nextLabel.userInteractionEnabled = NO;
    nextLabel.textAlignment = NSTextAlignmentCenter;
    [self.nextButton addSubview:nextLabel];
}

- (void)previewButtonTapped {
    if (self.delegate) {
        [self.delegate didTapNextButton];
    }
}

- (void)updatePreviewButtonWithImage:(UIImage *)image {
    //TODO: This does not animate.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, PREVIEW_WIDTH - 8, PREVIEW_WIDTH - 8)];
        temp.image = image;
        [temp clipAsCircle];
        [self.nextButtonContainer addSubview:temp];

        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             temp.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [self.nextButton setImage:image forState:UIControlStateNormal];
                             [temp removeFromSuperview];
                         }];
    });
}

#pragma mark - Tips
- (void)configureTipsButton {
    self.tipsButton = [[UIButton alloc] initWithFrame:CGRectMake(12, -12-28, 28, 28)];
    [self.tipsButton setImage:[UIImage imageNamed:@"question-white"] forState:UIControlStateNormal];
    [self.tipsButton addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    [self.tipsButton addTarget:self action:@selector(presentTips) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.tipsButton];
}

- (void)presentTips {
    [self.delegate didTapTipsButton];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
            }
        }
    }
    
    return nil;
}

#pragma mark - Flash Button
- (void)configureFlashButton {
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - ICON_WIDTH*2, 0, ICON_WIDTH, ICON_WIDTH)];
    [self.flashButton centerVerticallyInView:self];
    [self.flashButton addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    self.flashButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.flashButton.clipsToBounds = YES;
    [self addSubview:self.flashButton];
    [self.flashButton addTarget:self action:@selector(flashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setAppropriateIconsForCaptureState];
}

- (void)flashButtonTapped {
    
    if (self.captureModeSlider.currentIndex == FRSCaptureModePhoto) {
        if (self.flashIsOn == NO) {
            [self flash:YES];
            [self.flashButton setImage:[UIImage imageNamed:@"flash-on"] forState:UIControlStateNormal];
        } else {
            [self flash:NO];
            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
        }
    } else {
        if (self.torchIsOn == NO) {
            [self torch:YES];
            [self.flashButton setImage:[UIImage imageNamed:@"torch-on"] forState:UIControlStateNormal];
        } else {
            [self torch:NO];
            [self.flashButton setImage:[UIImage imageNamed:@"torch-off"] forState:UIControlStateNormal];
        }
    }
}

- (void)torch:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (on) {
            [device setTorchMode:AVCaptureTorchModeOn];
            self.torchIsOn = YES;
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            self.torchIsOn = NO;
        }
        [device unlockForConfiguration];
    }
}

- (void)flash:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasFlash]) {
        [device lockForConfiguration:nil];
        if (on) {
            [device setFlashMode:AVCaptureFlashModeOn];
            self.flashIsOn = YES;
        } else {
            [device setFlashMode:AVCaptureFlashModeOff];
            self.flashIsOn = NO;
        }
        [device unlockForConfiguration];
    }
}

- (void)setAppropriateIconsForCaptureState {
    if (self.captureModeSlider.currentIndex == FRSCaptureModePhoto) {
        [UIView transitionWithView:self
                          duration:0.3
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [self.flashButton setImage:[UIImage imageNamed:@"flash-off"] forState:UIControlStateNormal];
                        }
                        completion:^(BOOL finished) {
                            self.flashButton.layer.shadowOpacity = 0.0;
                        }];
    } else {
        [UIView transitionWithView:self
                          duration:0.3
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [self.flashButton setImage:[UIImage imageNamed:@"torch-off"] forState:UIControlStateNormal];
                        }
                        completion:^(BOOL finished) {
                            self.flashButton.layer.shadowOpacity = 1.0;
                        }];
    }
}


#pragma mark - Animation
- (void)hide {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.captureModeSlider.alpha = 0;
        self.nextButtonContainer.alpha = 0;
        self.tipsButton.alpha = 0;
        self.flashButton.alpha = 0;
    } completion:nil];
}

- (void)show {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor frescoTransparentDarkColor];
        self.captureModeSlider.alpha = 1;
        self.nextButtonContainer.alpha = 1;
        self.tipsButton.alpha = 1;
        self.flashButton.alpha = 1;
    } completion:nil];
}


@end
