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
#import "FRSProgressView.h"

@interface FRSOnboardViewConroller () <FRSProgressViewDelegate>

/*
** Views and Viewcontrollers
*/

@property (strong, nonatomic) OnboardPageViewController *pagedViewController;

@property (weak, nonatomic) IBOutlet UIView *containerPageView;

@property (strong, nonatomic) FRSProgressView *frsProgressView;


/*
** UI Elements
*/

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, assign) int pageCount;

@end

@implementation FRSOnboardViewConroller

- (void)viewDidLoad {
    
    [super viewDidLoad];


    //First make the paged view controller
    self.pagedViewController = [[OnboardPageViewController alloc]
                                initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                options:nil];

    //Add onboard view controller to parent view controller
    [self addChildViewController:self.pagedViewController];
    
    //Set bounds of paged view controller to bounds of subview in the xib
    self.pagedViewController.view.frame = self.containerPageView.frame;

    //Add paged view controller as subview to containerPageViewController
    [self.view addSubview:self.pagedViewController.view];

    //Set didMove for the paged view controller
    [self.pagedViewController didMoveToParentViewController:self];

    

}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    self.pageCount = 3;
    
    self.frsProgressView = [[FRSProgressView alloc] initWithFrame:CGRectMake(
                                                                             0,
                                                                             [[UIScreen mainScreen] bounds].size.height - 65,
                                                                             [[UIScreen mainScreen] bounds].size.width,
                                                                             65) andPageCount:self.pageCount];
    
    [self.view addSubview:self.frsProgressView];
    
}

#pragma mark - FRSProgressView Delegate

-(void)nextButtonTapped{
    
    [self.pagedViewController movedToViewAtIndex:self.pagedViewController.currentIndex];

}


- (void)updateStateWithIndex:(NSInteger)index{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.frsProgressView animateProgressViewAtPercent: ((float)(index+1) / (self.pageCount + 1))];
   
    });
}


@end

