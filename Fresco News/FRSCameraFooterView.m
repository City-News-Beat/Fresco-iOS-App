//
//  FRSCameraFooterView.m
//  Fresco
//
//  Created by Omar Elfanek on 5/1/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSCameraFooterView.h"
#import "UIView+Helpers.h"

@interface FRSCameraFooterView();

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
}

- (void)configureFrame {
    CGSize window = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, (window.width * PHOTO_FRAME_RATIO), window.width, window.height - (window.width * PHOTO_FRAME_RATIO) + SLIDER_HEIGHT);
    self.backgroundColor = [UIColor frescoTransparentDarkColor];
}

- (void)configureNextButton {
    self.nextButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(SIDE_PAD, 0, PREVIEW_WIDTH, PREVIEW_WIDTH)];
    self.nextButtonContainer.backgroundColor = [UIColor whiteColor];
    [self.nextButtonContainer centerVerticallyInView:self];
    self.nextButtonContainer.userInteractionEnabled = YES;
    [self addSubview:self.nextButtonContainer];
    [self.nextButtonContainer clipAsCircle];
    [self.nextButtonContainer addDropShadowWithColor:[UIColor frescoShadowColor] path:nil];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, PREVIEW_WIDTH - 8, PREVIEW_WIDTH - 8)];
    self.nextButton.contentMode = UIViewContentModeScaleAspectFill;
    self.nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.nextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.nextButton addTarget:self action:@selector(previewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton clipAsCircle];
    [self.nextButtonContainer addSubview:self.nextButton];
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
        
        self.nextButtonContainer.alpha = 1.0;
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







@end
