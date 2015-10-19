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

@property (nonatomic, assign) NSInteger pageCount;

/*
** UI Elements
*/

@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) UIView *progressView;

@property (strong, nonatomic) UIView *emptyProgressView;

@property (strong, nonatomic) UIView *progressBar;


@end

@implementation FRSProgressView

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count {

    self = [super initWithFrame:frame];
    
    if(self){
        
        self.pageCount = count;
        
        [self initNextButton];
        [self initLine];
        
        //Init arrays
        self.arrayOfEmptyCircles = [[NSMutableArray alloc] init];
        self.arrayOfFilledCircles = [[NSMutableArray alloc] init];
        
        //Create circles
        for (NSInteger i = 0;  i < count; i++) {
            
            UIView *filledCircle = [self createFilledCircleViewWithRadius:CircleWidth
                                    withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2 ];
            
            UIView *emptyCircle = [self createEmptyCircleViewWithRadius:CircleWidth
                                    withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2 ];
            
            //Add circles to array
            [self.arrayOfFilledCircles addObject:filledCircle];
            [self.arrayOfEmptyCircles addObject:emptyCircle];
            
            if(i == 0)
                emptyCircle.alpha = 0;
            
            
        }
        [self animateProgressViewAtPercent:1/((float)count +1)];

    }
    
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
    
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      0,
                                                                      self.nextButton.frame.origin.y - 3,
                                                                      0,
                                                                      3
                                                                      )];
    self.progressView.backgroundColor = [UIColor radiusGoldColor];
    
    [self addSubview:self.emptyProgressView];
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
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor radiusGoldColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self.delegate action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.backgroundColor = [UIColor whiteColor];
    
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

    CGRect newFrame = self.progressView.frame;
    newFrame.size.width = self.frame.size.width * percent;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        self.progressView.frame = newFrame;
        
    } completion:nil];
}


- (void)fillingCircleAtIndex:(NSInteger)index {

    dispatch_async(dispatch_get_main_queue(), ^{
    //Init animation
   
    UIView *filledCircleView = [self.arrayOfFilledCircles objectAtIndex:index];
    UIView *emptyCircleView = [self.arrayOfEmptyCircles objectAtIndex:index];
    
    filledCircleView.transform = CGAffineTransformMakeScale(0, 0);

    // Animate Empty > Filled
    [UIView animateWithDuration:0.2
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
                                              
                                          } completion:nil];
                     }];
    });
    
}

- (void)emptyingCircleAtIndex:(NSInteger)index {
    
    // Filled > Empty
    dispatch_async(dispatch_get_main_queue(), ^{

        UIView *emptyCircleView = [self.arrayOfEmptyCircles objectAtIndex:index];
        UIView *filledCircleView = [self.arrayOfFilledCircles objectAtIndex:index];
        
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
    });
}

- (void)updateNextButtonAtIndex:(NSInteger)index{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (index == self.pageCount-1){
        
            [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
        }
        else if (index < self.pageCount-1){
            
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
        }
        
    });
    
}


- (void)updateProgressViewAtIndex:(NSInteger)currentIndex fromIndex:(NSInteger)previousIndex{

    //Animate progress bar
    [self animateProgressViewAtPercent:((float)(currentIndex + 1) / (self.pageCount + 1))];
    
    if (currentIndex < previousIndex){
        
        [self emptyingCircleAtIndex:previousIndex];
        
    }
    else if (currentIndex > previousIndex){
        
        [self fillingCircleAtIndex:currentIndex];
    }
    
    else if (currentIndex == 0) {
        ((UIView *)[self.arrayOfFilledCircles objectAtIndex:0]).alpha = 1;
    }
    
    [self updateNextButtonAtIndex:currentIndex];

}



@end