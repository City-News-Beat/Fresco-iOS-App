//
//  FRSProgressView.m
//  Fresco
//
//  Created by Omar Elfanek on 10/2/15.
//  Copyright © 2015 Fresco. All rights reserved.
//


#import "FRSProgressView.h"
#import "OnboardPageViewController.h"

@interface FRSProgressView ()


/*
 ** Views and Viewcontrollers
 */

@property (strong, nonatomic) OnboardPageViewController *pagedViewController;


/*
 ** UI Elements
 */

- (IBAction)nextButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) IBOutlet UIView *circleView;

@property (strong, nonatomic) IBOutlet UIView *progressView;

@property (strong, nonatomic) IBOutlet UIView *emptyProgressView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *emptyProgressViewLeadingConstraint;

@end


@implementation FRSProgressView


- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){
        
        self.backgroundColor = [UIColor clearColor];
        
        [self initNextButton];
        [self initProgressBar];
        
        /*
         
         for(NSInterger i = 0; i < pageCount ; i++){
         
         }
         
        */
        
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
    self.emptyProgressView.backgroundColor = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1];
    
    [self addSubview:self.emptyProgressView];
    
    
    
    
    // set right bounds to center of first circle view
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      0,
                                                                      self.nextButton.frame.origin.y - 3,
                                                                      self.frame.size.width,
                                                                      3
                                                                      )];
    self.progressView.backgroundColor = [UIColor radiusGoldColor];

    [self addSubview:self.progressView];
    
    
    
    

    
    [self createCircleView:self.circleView
                withRadius:24
             withXPosition:85
             withFillColor:YES];
    
    [self createCircleView:self.circleView
                withRadius:24
             withXPosition:175
             withFillColor:NO];
    
    [self createCircleView:self.circleView
                withRadius:24
             withXPosition:270
             withFillColor:NO];

    
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


- (UIView *)createCircleView:(UIView *)view
                  withRadius:(CGFloat)radius
               withXPosition:(CGFloat)xPosition
               withFillColor:(BOOL)isFilled {
    

    UIView *circleView = [UIView new];
    
    circleView.frame = CGRectMake(
                                  xPosition,
                                  self.emptyProgressView.frame.origin.y  - 20 / 2,
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


@end



























