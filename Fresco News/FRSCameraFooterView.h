//
//  FRSCameraFooterView.h
//  Fresco
//
//  Created by Omar Elfanek on 5/1/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSCaptureModeSlider.h"

#define PHOTO_FRAME_RATIO 4 / 3
#define SLIDER_HEIGHT 40
#define ICON_WIDTH 24
#define PREVIEW_WIDTH 56
#define APERTURE_WIDTH 72
#define SIDE_PAD 12

@protocol FRSCameraFooterViewDelegate <NSObject>

- (void)didTapNextButton;
- (void)didTapTipsButton;
- (void)captureModeDidUpdate:(FRSCaptureMode)captureMode;

@end

@interface FRSCameraFooterView : UIView

- (instancetype)initWithDelegate:(id)delegate;

@property (weak, nonatomic) NSObject<FRSCameraFooterViewDelegate> *delegate;
@property (strong, nonatomic) FRSCaptureModeSlider *captureModeSlider;

- (void)updatePreviewButtonWithImage:(UIImage *)image;

- (void)hide;
- (void)show;

@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *tipsButton;
@property (strong, nonatomic) UIView *nextButtonContainer;

- (void)flash:(BOOL)on;
- (void)torch:(BOOL)on;

@end
