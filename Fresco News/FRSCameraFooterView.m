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
@property (strong, nonatomic) UIView *nextButtonContainer;

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





#pragma mark = Animation

- (void)hide {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.captureModeSlider.alpha = 0;
        self.nextButtonContainer.alpha = 0;
        //self.flashButton.alpha = 0;
    } completion:nil];
}

- (void)show {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor frescoTransparentDarkColor];
        self.captureModeSlider.alpha = 1;
        self.nextButtonContainer.alpha = 1;
        //self.flashButton.alpha = 1;
    } completion:nil];
}


@end