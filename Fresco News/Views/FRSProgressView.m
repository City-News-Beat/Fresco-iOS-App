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
** UI Elements
*/

@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) UIView *progressView;

@property (strong, nonatomic) UIView *emptyProgressView;

@property (strong, nonatomic) UIView *progressBar;

@property (strong, nonatomic) NSMutableArray *arrayOfEmptyCircles;
@property (strong, nonatomic) NSMutableArray *arrayOfFilledCircles;

@end

@implementation FRSProgressView

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count {

    self = [super initWithFrame:frame];
    
    if(self){
        
        [self initNextButton];
        [self initLine];
        
        //Init arrays
        self.arrayOfEmptyCircles = [[NSMutableArray alloc] init];
        self.arrayOfFilledCircles = [[NSMutableArray alloc] init];
        
        //Create circles
        for (NSInteger i = 0;  i < count; i++) {
            
            UIView *filledCircles = [self createFilledCircleViewWithRadius:CircleWidth
                                    withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2 ];
            
            UIView *emptyCircles = [self createEmptyCircleViewWithRadius:CircleWidth
                                    withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2 ];
            
        //Add circles to array
            [self.arrayOfFilledCircles addObject:filledCircles];
            [self.arrayOfEmptyCircles addObject:emptyCircles];
            
            
        }
        [self animateProgressViewAtPercent:1/((float)count +1)];

    }
    
    //Init first circle
    UIView *firstCircle = [self.arrayOfEmptyCircles objectAtIndex:0];
    firstCircle.alpha = 0;    
    
    return self;
    
}


- (void)initLine {
    
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
    
    [self.nextButton addTarget:self.delegate action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton.backgroundColor = [UIColor whiteColor];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self addSubview:self.nextButton];
    
}


- (UIView *)createFilledCircleViewWithRadius:(CGFloat)radius withXPosition:(CGFloat)xPosition {
    
    UIView *circleView = [UIView new];
    
    circleView.frame = CGRectMake(
                                  xPosition,
                                  self.emptyProgressView.frame.origin.y  - CircleWidth / 2,
                                  radius,
                                  radius
                                  );
    
    circleView.layer.cornerRadius = radius / 2;
    circleView.layer.borderWidth = 1;


    circleView.backgroundColor = [UIColor radiusGoldColor];
    circleView.layer.borderColor = [UIColor radiusDarkGoldColor].CGColor;

    
    [self addSubview:circleView];
    
    return circleView;
}


- (UIView *)createEmptyCircleViewWithRadius:(CGFloat)radius withXPosition:(CGFloat)xPosition {
    
    UIView *circleView = [UIView new];
    
    circleView.frame = CGRectMake(
                                  xPosition,
                                  self.emptyProgressView.frame.origin.y  - CircleWidth / 2,
                                  radius,
                                  radius
                                  );
    
    circleView.layer.cornerRadius = radius / 2;
    circleView.layer.borderWidth = 1;

    circleView.backgroundColor = [UIColor whiteColor];
    circleView.layer.borderColor = [UIColor frescoLightGreyColor].CGColor;
    
    [self addSubview:circleView];
    
    return circleView;
}


- (void)animateProgressViewAtPercent:(CGFloat)percent {

    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect newFrame = self.progressView.frame;
        newFrame.size.width = self.frame.size.width * percent;
        
        self.progressView.frame = newFrame;
        
    } completion:nil];
}

- (void)animateFilledCirclesFromIndex:(NSInteger)index {
    
    //Init animation
    UIView *secondFilledCircle = [self.arrayOfFilledCircles objectAtIndex:index];
    
    secondFilledCircle.transform = CGAffineTransformMakeScale(0, 0);
    
    
    //Init Arrays
    UIView *emptyCircleView = [self.arrayOfEmptyCircles objectAtIndex:index];
    UIView *filledCircleView = [self.arrayOfFilledCircles objectAtIndex:index];

/*
** Empty > Filled
*/
    
    [UIView animateWithDuration:0.25
                          delay:0.175
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         emptyCircleView.alpha = 0;
                         emptyCircleView.transform = CGAffineTransformMakeScale(.001, .001);
                         filledCircleView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{

                                              filledCircleView.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              //completion
                                          }];
                     }];
    
    
}
- (void)animateEmptyCirclesFromIndex:(NSInteger)index {

    
/*
 ** Filled > Empty
 */
    
    //Init Arrays
    UIView *emptyCircleView = [self.arrayOfEmptyCircles objectAtIndex:index];
    UIView *filledCircleView = [self.arrayOfFilledCircles objectAtIndex:index];
    
//    emptyCircleView.alpha = 0;
//    emptyCircleView.transform = CGAffineTransformMakeScale(.001, .001);
//    filledCircleView.transform = CGAffineTransformMakeScale(1, 1);
    


    
    //Filled > Empty
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        
                         filledCircleView.transform = CGAffineTransformMakeScale(.001, .001);
                         emptyCircleView.alpha = 1;
                         emptyCircleView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              emptyCircleView.transform = CGAffineTransformMakeScale (1,1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              //completion
                                          }];
                     }];
    
    
}


@end



































