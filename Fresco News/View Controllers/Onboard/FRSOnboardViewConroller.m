//
//  FRSOnboardVC.m
//  Fresco
//
//  Created by Omar El-Fanek on 9/1/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSOnboardViewConroller.h"
#import "OnboardPageViewController.h"
#import "OnboardPageCellController.h"
#import "UIColor+Additions.h"

@interface FRSOnboardViewConroller ()

/*
 ** Views and Viewcontrollers
 */

@property (strong, nonatomic) OnboardPageViewController *pagedViewController;

@property (strong, nonatomic) OnboardPageCellController *pagedCellController;

@property (weak, nonatomic) IBOutlet UIView *containerPageView;

/*
 ** UI Elements
 */

- (IBAction)nextButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) IBOutlet UIView *circleView1;

@property (strong, nonatomic) IBOutlet UIView *circleView2;

@property (strong, nonatomic) IBOutlet UIView *circleView3;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView1;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView2;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView3;

@property (strong, nonatomic) IBOutlet UIView *progressView;

@property (strong, nonatomic) IBOutlet UIView *emptyProgressView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *emptyProgressViewLeadingConstraint;

/*
 ** Misc.
 */

@property (assign) BOOL didComeFromIndex0;

@property (assign) BOOL didComeFromIndex1;

@property (assign) BOOL didComeFromIndex2;


@property (assign) BOOL didFinishAnimationAtIndex0;

@property (assign) BOOL didFinishAnimationAtIndex1;

@property (assign) BOOL didFinishAnimationAtIndex2;


@property (nonatomic, assign) BOOL animationIsRunning;

@property (nonatomic, assign) NSTimeInterval delay;

@end

@implementation FRSOnboardViewConroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //First make the paged view controller
    self.pagedViewController = [[OnboardPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    //Add onboard view controller to parent view controller
    [self addChildViewController:self.pagedViewController];
    
    //Set bounds of paged view controller to bounds of subview in the xib
    self.pagedViewController.view.frame = self.containerPageView.frame;
    
    //Add paged view controller as subview to containerPageViewController
    [self.view addSubview:self.pagedViewController.view];
    
    //Set didMove for the paged view controller
    [self.pagedViewController didMoveToParentViewController:self];
    

    [self circleInitialization];
    
    //Initialize Bools
    self.didComeFromIndex0 = NO;
    self.didComeFromIndex1 = NO;
    self.didComeFromIndex2 = NO;

    self.didFinishAnimationAtIndex0 = NO;
    self.didFinishAnimationAtIndex1 = NO;
    self.didFinishAnimationAtIndex2 = NO;
    
    
    //Make paged view controller cell
    self.pagedCellController = [[OnboardPageCellController alloc] init];
    self.pagedCellController.view.frame = self.pagedViewController.view.frame;
    NSLog (@"Page view controll subviews: %@", self.pagedCellController.view.subviews);
    
    self.pagedCellController.onboard1EarthImageView.alpha = 1;
    self.pagedCellController.onboard1AssignmentTopLeft.alpha = 1;
    self.pagedCellController.onboard1AssignmentTopRight.alpha = 1;
    self.pagedCellController.onboard1AssignmentBottomLeft.alpha = 1;
    self.pagedCellController.onboard1AssignmentBottomRight.alpha = 1;
    
}

- (void) circleInitialization {
    
    self.circleView2.alpha = 0;
    self.circleView3.alpha = 0;

    NSArray *circleViews = @[self.emptyCircleView1,
                             self.emptyCircleView2,
                             self.emptyCircleView3,
                             self.circleView1,
                             self.circleView2,
                             self.circleView3];
    
    NSArray *emptyCircleViews = [circleViews subarrayWithRange:NSMakeRange(0, 3)];

    NSArray *fullCircleViews = [circleViews subarrayWithRange:NSMakeRange(3, 3)];
    
    for (UIView *circleView in circleViews) {
        circleView.layer.cornerRadius = 12;
        circleView.layer.borderWidth = 3;
    }
    
    for (UIView *emptyCircleView in emptyCircleViews) {
        emptyCircleView.backgroundColor = [UIColor whiteColor];
        emptyCircleView.layer.borderColor = [[UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1] CGColor];
    }
    
    for (UIView *fullCircleView in fullCircleViews) {
        fullCircleView.backgroundColor = [UIColor radiusGoldColor];
        fullCircleView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
}

- (IBAction)nextButtonTapped:(id)sender {
    
    [self.pagedViewController movedToViewAtIndex:self.pagedViewController.currentIndex];
    
}

- (void)updateStateWithIndex:(NSInteger)index{

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // INDEX 0
        if (self.pagedViewController.currentIndex == 0){
            
            
            self.pagedCellController.onboard1EarthImageView.alpha = 1;
            self.pagedCellController.onboard1AssignmentTopLeft.alpha = 1;
            self.pagedCellController.onboard1AssignmentTopRight.alpha = 1;
            self.pagedCellController.onboard1AssignmentBottomLeft.alpha = 1;
            self.pagedCellController.onboard1AssignmentBottomRight.alpha = 1;
            
            
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            
            self.circleView1.transform = CGAffineTransformMakeScale(0, 0);
            
            [UIView animateWithDuration: 0.2
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 self.emptyProgressViewLeadingConstraint.constant = 0;
                                 [self.view layoutIfNeeded];
                    
                                 self.emptyCircleView1.alpha = 0.0;
                                 self.circleView1.alpha = 1.0;
                                 self.circleView1.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                 
                                 [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                                 
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration: 0.2
                                                       delay: 0.0
                                                     options: UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      
                                                      self.circleView1.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                      
                                                  }
                                                  completion:^(BOOL finished) {
    
                                                      [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                                                  }];
                                 
                             }];
            
            if ((self.didComeFromIndex1 = YES)) {
                
                if ((self.animationIsRunning = YES)){
                    
                    self.delay = 0.2f;
                    
                } else {
                    
                    self.delay = 0.0f;
                    
                }

                [UIView animateWithDuration: 0.2
                                      delay: 0.0
                                    options: UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     self.animationIsRunning = YES;
                                     self.emptyCircleView2.alpha = 1;
                                     self.emptyCircleView2.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                     self.circleView2.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                     if (finished){
                                         self.circleView2.alpha = 0;
                                         self.didFinishAnimationAtIndex0 = YES;
                                         self.animationIsRunning = NO;
                                         
                                    
                                     }
                                 }
                 
                 ];
            
            }
        }
        
        
        // INDEX 1
        
        if ((self.didFinishAnimationAtIndex1 = YES)){
        if (self.pagedViewController.currentIndex == 1){
            
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            self.circleView2.transform = CGAffineTransformMakeScale(0, 0);
            
            self.didComeFromIndex1 = YES;
            
            [UIView animateWithDuration: 0.2
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{

                                 self.emptyProgressViewLeadingConstraint.constant = 105;
                                 [self.view layoutIfNeeded];
                                 
                                 self.emptyCircleView2.transform = CGAffineTransformMakeScale(0.1, 0.1);
                             }
                             completion:nil];
            
            [UIView animateWithDuration: 0.2
                                  delay: 0.0 //self.delay
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.animationIsRunning = YES;
                                 
                                 self.emptyCircleView3.alpha = 1.0;
                                 self.circleView2.alpha = 1.0;
                                 self.circleView2.transform = CGAffineTransformMakeScale(1.3, 1.3);

                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration: 0.2
                                                       delay: 0.0
                                                     options: UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                            
                                                      self.circleView2.transform = CGAffineTransformMakeScale(1.0, 1.0);

                                                  }
                                                  completion:^(BOOL finished) {
                                                      self.animationIsRunning = NO;
                                                  }];
                             }];
            
            if ((self.didComeFromIndex2 = YES)) {

                if ((self.animationIsRunning = YES)){
                    
                    self.delay = 0.2f;
                    
                } else {
                    
                    self.delay = 0.0f;
                    
                }
                
                self.emptyCircleView3.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
                [UIView animateWithDuration: 0.2
                                      delay: 0.0 //self.delay
                                    options: UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     
                                     self.animationIsRunning = YES;
                                     
                                     self.emptyCircleView3.alpha = 1;
                                     self.emptyCircleView3.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                     self.circleView3.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                     self.circleView3.alpha = 0;

                                 }
                                 completion:^(BOOL finished) {
                                     if (finished){
                                         self.didFinishAnimationAtIndex1 = YES;
                                         self.animationIsRunning = NO;
                                         
                                     }
                                 }
                 ];
            }
        }
        }

        // INDEX 2
        if (self.pagedViewController.currentIndex == 2){
            [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
            self.circleView3.transform = CGAffineTransformMakeScale(0, 0);
            
            self.didComeFromIndex2 = YES;
            
            [UIView animateWithDuration: 0.2
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 self.emptyProgressViewLeadingConstraint.constant = 230;
                                 [self.view layoutIfNeeded];

                             }
                             completion:nil];
            
            [UIView animateWithDuration: 0.2
                                  delay: 0.0 //self.delay
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 self.animationIsRunning = YES;
                                 self.emptyCircleView3.transform = CGAffineTransformMakeScale(0.1, 0.1);

                                 self.emptyCircleView3.alpha = 1.0;
                                 self.circleView3.alpha = 1.0;
                                 self.circleView3.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                 
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration: 0.2
                                                       delay: 0.0
                                                     options: UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                     

                                                      self.circleView3.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }
                                                  completion:^(BOOL finished) {
                                                      self.animationIsRunning = NO;
                                                      self.emptyCircleView3.transform = CGAffineTransformMakeScale(0.1, 0.1);

                                                  }
                                                  ];
                             }];
        }
    });
}

@end
