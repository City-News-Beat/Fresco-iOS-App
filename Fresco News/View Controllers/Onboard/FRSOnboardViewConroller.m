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

@property (strong, nonatomic) OnboardPageCellController *onboardViewController;

@property (strong, nonatomic) OnboardPageViewController *pagedViewController;

@property (weak, nonatomic) IBOutlet UIView *containerPageViewController;

/*
 ** UI
 */

@property (strong, nonatomic) IBOutlet UIImageView *progressImage;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSArray *progressImages;

- (IBAction)nextButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *circleView1;

@property (strong, nonatomic) IBOutlet UIView *circleView2;

@property (strong, nonatomic) IBOutlet UIView *circleView3;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView1;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView2;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView3;

@property (strong, nonatomic) IBOutlet UIView *filledProgressView2;
@property (strong, nonatomic) IBOutlet UIView *filledProgressView2base;

@property (strong, nonatomic) IBOutlet UIView *filledProgressView3;

@end


@implementation FRSOnboardViewConroller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        
        // Create the data model for progress images
        self.progressImages = @[
                                @"progress-3-1.png",
                                @"progress-3-1.png",
                                @"progress-3-1.png"
                                ];
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //First make the paged view controller
    self.pagedViewController = [[OnboardPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    //Add onboard view controller to parent vc
    [self addChildViewController:self.pagedViewController];
    
    //Set bounds of pageVC to bounds of subview in the xib
    self.pagedViewController.view.frame = self.containerPageViewController.frame;
    
    //Add pageVC as subview to containerPageViewController
    [self.view addSubview:self.pagedViewController.view];
    
    //Set didMove for the pagedVC
    [self.pagedViewController didMoveToParentViewController:self];
    
    
    //***//***//***//
    
    //Filled in circles
    self.circleView1.layer.cornerRadius = 12;
    self.circleView1.backgroundColor = [UIColor radiusGoldColor];
    self.circleView1.layer.borderWidth = 3;
    self.circleView1.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.circleView2.alpha = 0;
    self.circleView2.layer.cornerRadius = 12;
    self.circleView2.backgroundColor = [UIColor radiusGoldColor];
    self.circleView2.layer.borderWidth = 3;
    self.circleView2.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.circleView3.alpha = 0;
    self.circleView3.layer.cornerRadius = 12;
    self.circleView3.backgroundColor = [UIColor radiusGoldColor];
    self.circleView3.layer.borderWidth = 3;
    self.circleView3.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
    
    //Empty circles
    self.emptyCircleView1.layer.cornerRadius = 12;
    self.emptyCircleView1.backgroundColor = [UIColor whiteColor];
    self.emptyCircleView1.layer.borderWidth = 3;
    self.emptyCircleView1.layer.borderColor = [[UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1] CGColor];
    
    self.emptyCircleView2.layer.cornerRadius = 12;
    self.emptyCircleView2.backgroundColor = [UIColor whiteColor];
    self.emptyCircleView2.layer.borderWidth = 3;
    self.emptyCircleView2.layer.borderColor = [[UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1] CGColor];
    
    self.emptyCircleView3.layer.cornerRadius = 12;
    self.emptyCircleView3.backgroundColor = [UIColor whiteColor];
    self.emptyCircleView3.layer.borderWidth = 3;
    self.emptyCircleView3.layer.borderColor = [[UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1] CGColor];
    
    //Progress Bar
    self.filledProgressView3.alpha = 0;
    self.filledProgressView2base.alpha = 0;
    
}

- (IBAction)nextButtonTapped:(id)sender {
    
    [self.pagedViewController movedToViewAtIndex:self.pagedViewController.currentIndex];
    
}

- (void)updateStateWithIndex:(NSInteger)index{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Set progress images to reflect currentIndex
        if (self.pagedViewController.currentIndex == 0){
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            NSLog (@"Current Index: %lu", self.pagedViewController.currentIndex);
        }
        
        
        if (self.pagedViewController.currentIndex == 1){
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            
            self.circleView2.transform = CGAffineTransformMakeScale(0, 0);
            
            [UIView animateWithDuration: 0.3
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 self.filledProgressView2.frame = CGRectOffset(self.filledProgressView2.frame, 110, 0);
                                 
                                 self.emptyCircleView2.transform = CGAffineTransformMakeScale(0.1, 0.1);
                             }
                             completion:^(BOOL finished) {
                                 self.filledProgressView2.alpha = 0;
                                 self.filledProgressView2base.alpha = 1;
                             }];
            
            [UIView animateWithDuration: 0.3
                                  delay: 0.25
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 self.emptyCircleView2.alpha = 0.0;
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
                                                      
                                                  }];
                             }];
            
            NSLog (@"Current Index: %lu", self.pagedViewController.currentIndex);
        }
        
        if (self.pagedViewController.currentIndex == 2){
            [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
            self.circleView3.transform = CGAffineTransformMakeScale(0, 0);
            
            
            [UIView animateWithDuration: 0.3
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.filledProgressView3.alpha = 1;t
                                  self.filledProgressView3.frame = CGRectOffset(self.filledProgressView3.frame, 110, 0);
                                 
                                 self.emptyCircleView3.transform = CGAffineTransformMakeScale(0.1, 0.1);
                             }
                             completion:nil];
            
            [UIView animateWithDuration: 0.3
                                  delay: 0.25
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 self.emptyCircleView3.alpha = 0.0;
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
                                                      
                                                  }];
                             }];
            
            
            NSLog (@"Current Index: %lu", self.pagedViewController.currentIndex);
        }
        
    });
    
}

@end
