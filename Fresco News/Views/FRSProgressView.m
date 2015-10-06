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


- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){

        
        [self createProgressBar:self.progressBar withCircles:8];

//        for(NSInterger i = 0; i < pageCount ; i++){
        
//         }
        
    }
    
    return self;
}

- (void) initProgressBar {
    
    // Empty progress view does not animate
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
        circleView.layer.borderColor = [UIColor frescoLightGreyColor].CGColor; // 1.
    }
    
    
    [self addSubview:circleView];
    
    return circleView;
}



//- (UIView *)createProgressBar:(UIView *)view
//                  withCircles:(CGFloat)circles {
//    
//    [self initNextButton];
//    [self initProgressBar];
//    
//    if (circles < 3 || circles > 6) {
//        NSLog (@"Value of CGFloat 'circles' in progress bar must be greater 2 and less than 6.");
//    }
//    
//    if (circles == 3) {
//
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 5
//                      withFill:YES];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 2.13
//                      withFill:NO];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 1.35
//                      withFill:NO];
//    }
//    
//    if (circles == 4) {
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 8
//                      withFill:YES];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 2.85
//                      withFill:NO];
//     
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 1.7
//                      withFill:NO];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 1.25
//                      withFill:NO];
//    }
//    
//    if (circles == 5) {
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 8
//                      withFill:YES];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 3.4
//                      withFill:NO];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 2.13
//                      withFill:NO];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 1.575
//                      withFill:NO];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 1.25
//                      withFill:NO];
//    }
//    
//    return view;
//    
//}




- (UIView *)createProgressBar:(UIView *)view withCircles:(NSInteger)circles {
    
    [self initNextButton];
    [self initProgressBar];
    
    
    
    for (NSInteger i = 0;  i < circles; i++) {
        
        NSLog (@"%li",(long)i);

        [self createCircleView:self.circleView
                    withRadius:CircleWidth
                 withXPosition:(375 * ((i + 1) / (float)(circles + 1))) - CircleWidth / 2
                      withFill:YES];
        
    }

//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 5
//                      withFill:YES];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 2.13
//                      withFill:NO];
//        
//        [self createCircleView:self.circleView
//                    withRadius:24
//                 withXPosition:self.frame.size.width / 1.35
//                      withFill:NO];
    
    return view;
    
}



- (void)animateProgressViewAtPercent:(CGFloat)percent{

    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect newFrame = self.progressView.frame;
        newFrame.size.width = self.frame.size.width * percent;
        
        self.progressView.frame = newFrame;
        
    } completion:nil];
}



@end



































