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

static const CGFloat ProgressLineHeight = 3.0f;

typedef void(^myCompletion)(BOOL);

@interface FRSProgressView ()

@property (nonatomic, assign) NSInteger pageCount;

@property (assign, nonatomic) BOOL disabledFirstIndex;

@property CGFloat *progressPercent;

/**
 *  Holds all the empty circles
 */

@property (strong, nonatomic) NSMutableArray *emptyCircles;

/**
 *  Holds all the filled circles
 */

@property (strong, nonatomic) NSMutableArray *filledCircles;


/*
** UI Elements
*/

@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) UIView *progressView;

@property (strong, nonatomic) UIView *emptyProgressView;

@end

@implementation FRSProgressView

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count {
    
    return [self initWithFrame:frame andPageCount:count withFirstIndexDisabled:NO];
    
}

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count withFirstIndexDisabled:(BOOL)disabled{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        self.pageCount = count;
        self.disabledFirstIndex = disabled;
        
        [self initNextButton];
        [self initLine];
        
        //Init arrays
        self.emptyCircles = [[NSMutableArray alloc] init];
        self.filledCircles = [[NSMutableArray alloc] init];
        
        //Create circles
        for (NSInteger i = 0;  i < count; i++) {
            
            UIView *filledCircle = [self createFilledCircleViewWithRadius:CircleWidth
                                                            withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2 ];
            
            UIView *emptyCircle = [self createEmptyCircleViewWithRadius:CircleWidth
                                                          withXPosition:([[UIScreen mainScreen]bounds].size.width * ((i + 1) / (float)(count + 1))) - CircleWidth / 2 ];
            
            [self addSubview:filledCircle];
            [self addSubview:emptyCircle];
            
            //Add circles to array
            [self.filledCircles addObject:filledCircle];
            [self.emptyCircles addObject:emptyCircle];
            
            if(disabled){
                filledCircle.alpha = 0;
                emptyCircle.alpha = 0;
                emptyCircle.transform = CGAffineTransformMakeScale(.001, .001);
            }
            else if(i == 0)
                emptyCircle.alpha = 0;
            
            
        }
        
        if(!disabled)
            [self animateProgressViewAtPercent:1/((float)count +1)];
        
    }
    
    return self;

}

- (void)initLine {
    
    CGFloat lineHeight = self.disabledFirstIndex ? 1.0f : ProgressLineHeight;
    
    self.emptyProgressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      0,
                                                                      self.nextButton.frame.origin.y - lineHeight,
                                                                      self.frame.size.width,
                                                                      lineHeight
                                                                      )];
    
    self.emptyProgressView.backgroundColor = self.disabledFirstIndex ? [UIColor fieldBorderColor] : [UIColor frescoLightGreyColor];
    
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                 0,
                                                                 self.nextButton.frame.origin.y - lineHeight,
                                                                 0,
                                                                 lineHeight
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
    
    [self.nextButton setTitleColor:[UIColor radiusGoldColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self.delegate action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.backgroundColor = [UIColor whiteColor];
    
    if(self.disabledFirstIndex){
        [self.nextButton setTitle:NO_THANKS forState:UIControlStateNormal];
        [self.nextButton.titleLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_LIGHT size:17]];
    }
    else{
        [self.nextButton setTitle:NEXT forState:UIControlStateNormal];
        [self.nextButton.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17]];
    }
    
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
    
    return circleView;
}

/**
 *  Used to animate the progress view to a certain percentage
 *
 *  @param percent The percentage to which the progress view should move to (percentage is realtive to the parent views width)
 */

- (void)animateProgressViewAtPercent:(CGFloat)percent {

    CGRect newFrame = self.progressView.frame;
    newFrame.size.width = self.frame.size.width * percent;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        self.progressView.frame = newFrame;
        
    } completion:nil];
}


/**
 *  Fills circle by animating yellow circle in place of the white one
 *
 *  @param index The index to fill the circle at
 */

- (void)fillCircleAtIndex:(NSInteger)index {

    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Init animation
        UIView *filledCircleView = [self.filledCircles objectAtIndex:index];
        UIView *emptyCircleView = [self.emptyCircles objectAtIndex:index];
        
        //Unhide filled circle
        filledCircleView.hidden = NO;
        
        // Animate Empty -> Filled
        [UIView animateWithDuration:0.2
                              delay:0.175
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             emptyCircleView.alpha = 0;
                             emptyCircleView.transform = CGAffineTransformMakeScale(.1, .1);
                             
                             filledCircleView.alpha = 1;
                             filledCircleView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                             
                         } completion:^(BOOL finished) {
                             
                             //Hide after completion
                             emptyCircleView.hidden = YES;
                             
                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  
                                                  filledCircleView.transform = CGAffineTransformMakeScale(1, 1);
                                                  
                                              } completion:nil];
                         }];
    });
    
}

/**
 *  Empties a circle by removing the filled yellow one
 *
 *  @param index The index to empty the circle at
 */

- (void)emptyCircleAtIndex:(NSInteger)index {
    
    // Filled > Empty
    dispatch_async(dispatch_get_main_queue(), ^{

        UIView *emptyCircleView = [self.emptyCircles objectAtIndex:index];
        UIView *filledCircleView = [self.filledCircles objectAtIndex:index];
        
        emptyCircleView.hidden = NO;
        
        //Filled -> Empty
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             filledCircleView.alpha = 0;
                             filledCircleView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                             
                             emptyCircleView.alpha = 1;
                             emptyCircleView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             
                         } completion:^(BOOL finished) {
                             
                             filledCircleView.hidden = YES;

                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  
                                                  emptyCircleView.transform = CGAffineTransformMakeScale(1,1);
                                                  
                                              } completion:nil];
                         }];
    });
}

/**
 *  Toggles visibility of all empty cirlces in the progress view
 *
 *  @param show YES to show, NO to hide
 */

- (void)toggleCircles:(BOOL)show{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger index = 0;
        
        for (UIView *view in self.emptyCircles) {
            
            view.hidden = NO;
            
            index++;
            
            //We run this check in order to make the first bubble filled
            if(index == 1 && show){
                [self fillCircleAtIndex:0];
                continue;
            }
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 view.alpha = show ?  1 : 0;
                                 view.transform = show ? CGAffineTransformMakeScale(1.1, 1.1) : CGAffineTransformMakeScale(0.1, 0.1);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 view.hidden = !show;

                                 if(show){
                                 
                                     [UIView animateWithDuration:0.15
                                                           delay:0.0
                                                         options:UIViewAnimationOptionCurveEaseOut
                                                      animations:^{
                                                          
                                                          view.transform = CGAffineTransformMakeScale (1,1);
                                                          
                                                      } completion:nil];
                                     
                                 }

                             }];
        }	
    });
}

- (void)updateNextButtonAtIndex:(NSInteger)index{
    
    NSString *title;
    
    UIFont *font;
    
    if(index < 0 && self.disabledFirstIndex && ![self.nextButton.titleLabel.text isEqualToString:NO_THANKS]){
        title = NO_THANKS;
        font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:17];
    }
    else if(![self.nextButton.titleLabel.text isEqualToString:NEXT] && index < self.pageCount-1 && index >= 0){
        title = NEXT;
        font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17];
    }
    else if(![self.nextButton.titleLabel.text isEqualToString:DONE] && index == self.pageCount-1){
        title = DONE;
        font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17];
    }
    
    if(!title)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.2 animations:^{
        
            self.nextButton.titleLabel.alpha = 0;
        
        } completion:^(BOOL finished) {
            
            [self.nextButton setTitle:title forState:UIControlStateNormal];
            self.nextButton.titleLabel.font = font;
            
            [UIView animateWithDuration:.2 animations:^{
                
                self.nextButton.titleLabel.alpha = 1;
                
            } completion:nil];
            
        }];
    });
}


- (void)updateProgressViewForIndex:(NSInteger)currentIndex fromIndex:(NSInteger)previousIndex{

    //This condition tells us we have the first index disabled
    // and we are not at the "first" page of the progress view
    if(self.disabledFirstIndex && ((currentIndex == 1 && currentIndex > previousIndex) ||  currentIndex == 0)){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Update the title of the button
            [self updateNextButtonAtIndex:(currentIndex-1)];
            
            CGFloat lineHeight = (currentIndex == 0  ? 1.0f : ProgressLineHeight);
            
            //Construct new empty progress view frame
            CGRect emptyProgressViewFrame = self.emptyProgressView.frame;
            emptyProgressViewFrame.size.height = lineHeight;
            emptyProgressViewFrame.origin.y = self.nextButton.frame.origin.y - lineHeight;
            
            //Construct new progress view frame
            CGRect progressViewFrame = emptyProgressViewFrame;
            progressViewFrame.size.width = currentIndex == 0 ? 0 : (((float)(currentIndex) / (self.pageCount + 1))) * emptyProgressViewFrame.size.width;
            
            //Animate frame changes
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                self.progressView.alpha = currentIndex;
                self.progressView.frame = progressViewFrame;
                self.emptyProgressView.frame = emptyProgressViewFrame;
                
            } completion:^(BOOL finished) {
                
                if(currentIndex < previousIndex)
                    [self emptyCircleAtIndex:currentIndex];
                
                [self toggleCircles:(currentIndex == 1)];
                
            }];
        });
    }
    else{

        //Know current index down one because the first page is disabled
        if(self.disabledFirstIndex){
            
            currentIndex--;
            
            previousIndex--;
            
        }
        
        //Update the title of the button
        [self updateNextButtonAtIndex:currentIndex];
        
        if (currentIndex < previousIndex){
            
            [self emptyCircleAtIndex:previousIndex];
            
        }
        else if (currentIndex > previousIndex){
            
            [self fillCircleAtIndex:currentIndex];
        }
        
        //Animate the progress view to the percentage filled
        [self animateProgressViewAtPercent:((float)(currentIndex + 1) / (self.pageCount + 1))];
        
    }

}

-(void)disableUserInteraction:(BOOL)disable{
    self.nextButton.enabled = !disable;
}



@end