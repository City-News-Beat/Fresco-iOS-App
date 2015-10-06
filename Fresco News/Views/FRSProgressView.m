//
//  FRSProgressView.m
//  Fresco
//
//  Created by Omar Elfanek on 10/2/15.
//  Copyright © 2015 Fresco. All rights reserved.
//


#import "FRSProgressView.h"
#import "OnboardPageViewController.h"

static const CGFloat CircleWidth = 24.0f;

@interface FRSProgressView ()



/*
** Views and Viewcontrollers
*/

@property (strong, nonatomic) OnboardPageViewController *pagedViewController;


/*
** UI Elements
*/

- (IBAction)nextButtonTapped:(id)sender;

@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) UIView *circleView;

@property (strong, nonatomic) UIView *progressView;

@property (strong, nonatomic) UIView *emptyProgressView;

@property (strong, nonatomic) UIView *progressBar;

@end


@implementation FRSProgressView

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count{

    self = [super initWithFrame:frame];
    
    if(self){
        
        [self initNextButton];
        [self initProgressBar];
        
        for (NSInteger i = 0;  i < count; i++) {
            
            NSLog (@"%li",(long)i);
            
            [self createCircleView:self.circleView
                        withRadius:CircleWidth
                     withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2
                          withFill:YES];
            
        }

    }
    
    return self;
}

- (void) initProgressBar {
    
    self.emptyProgressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      0,
                                                                      self.nextButton.frame.origin.y - 3,
                                                                      self.frame.size.width,
                                                                      3
                                                                      )];
    self.emptyProgressView.backgroundColor = [UIColor frescoLightGreyColor];
    [self addSubview:self.emptyProgressView];
    
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      0,
                                                                      self.nextButton.frame.origin.y - 3,
                                                                      0,
                                                                      3
                                                                      )];
    self.progressView.backgroundColor = [UIColor radiusGoldColor];
    [self addSubview:self.progressView];
    

}


- (void)initNextButton {
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    self.nextButton.frame = CGRectMake(0,
                                       self.frame.size.height - 45,
                                       self.frame.size.width,
                                       45
                                       );
    
    [self.nextButton.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17]];
    [self.nextButton setTitleColor:[UIColor radiusGoldColor] forState:UIControlStateNormal];
    
    [self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton.backgroundColor = [UIColor whiteColor];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self addSubview:self.nextButton];

}

- (void)nextButtonTapped:(id)sender {
    
    NSLog(@"Next button tapped");
    
}


- (UIView *)createCircleView:(UIView *)view withRadius:(CGFloat)radius withXPosition:(CGFloat)xPosition withFill:(BOOL)isFilled {
    
    UIView *circleView = [UIView new];
    
    circleView.frame = CGRectMake(
                                  xPosition,
                                  self.emptyProgressView.frame.origin.y  - CircleWidth / 2,
                                  radius,
                                  radius
                                  );
    
    circleView.layer.cornerRadius = radius / 2;
    circleView.layer.borderWidth = 1;

    if (isFilled) {
        circleView.backgroundColor = [UIColor radiusGoldColor];
        circleView.layer.borderColor = [UIColor radiusDarkGoldColor].CGColor;
    } else {
        circleView.backgroundColor = [UIColor whiteColor];
        circleView.layer.borderColor = [UIColor frescoLightGreyColor].CGColor;
    }
    
    [self addSubview:circleView];
    
    return circleView;
}




- (void)animateProgressViewAtPercent:(CGFloat)percent{

    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect newFrame = self.progressView.frame;
        newFrame.size.width = self.frame.size.width * percent;
        
        self.progressView.frame = newFrame;
        
    } completion:nil];
}



@end



































