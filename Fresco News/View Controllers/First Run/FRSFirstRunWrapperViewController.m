//
//  FRSFirstRunWrapperViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSFirstRunWrapperViewController.h"
#import "FirstRunPageViewController.h"
#import "FRSProgressView.h"

@interface FRSFirstRunWrapperViewController () <FRSProgressViewDelegate, FRSBackButtonDelegate>

/*
** Views and Viewcontrollers
*/

@property (strong, nonatomic) FRSProgressView *progressView;

@property (strong, nonatomic) FirstRunPageViewController *pagedViewController;

@property (weak, nonatomic) IBOutlet UIView *containerPageView;

@property (strong, nonatomic) FRSBackButton *backButton;

@end

@implementation FRSFirstRunWrapperViewController

- (void)viewDidLoad {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //First make the paged view controller
    self.pagedViewController = [[FirstRunPageViewController alloc]
                                initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                options:nil];
    
    //Add first run page view controller to parent view controller
    [self addChildViewController:self.pagedViewController];
    
    //Set bounds of paged view controller to bounds of subview in the xib
    self.pagedViewController.view.frame = self.containerPageView.frame;
    
    //Add paged view controller as subview to containerPageViewController
    [self.view addSubview:self.pagedViewController.view];
    
    //Set didMove for the paged view controller
    [self.pagedViewController didMoveToParentViewController:self];
    
    CGRect progressViewFrame = CGRectMake(0,
                                          [[UIScreen mainScreen] bounds].size.height - 65,
                                          [[UIScreen mainScreen] bounds].size.width,
                                          65);

    self.progressView = [[FRSProgressView alloc] initWithFrame:progressViewFrame
                                                  andPageCount:4
                                        withFirstIndexDisabled:YES];
    
    [self.view addSubview:self.progressView];
    
    self.backButton = [FRSBackButton createBackButton];
    self.backButton.delegate = self;
    self.backButton.alpha = 0;
    
    [self.view addSubview:self.backButton];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}

#pragma mark - FRSBackButton Delegate

- (void)backButtonTapped{
    
    NSInteger index = self.pagedViewController.currentIndex -1;

    [self.pagedViewController moveToViewAtIndex:index
                                  withDirection:UIPageViewControllerNavigationDirectionReverse];
    
    //Index 0 = the first page
    //Index 2 = the first page after signing up
    if((index == 0 || index == 2)){
        self.backButton.enabled = NO;
    }

}


#pragma mark - FRSProgressView Delegate

-(void)nextButtonTapped{
    
    //If we're on the first page or the last page
    if(self.pagedViewController.currentIndex == 0 || self.pagedViewController.currentIndex == 4){

        //Set has Launched Before to prevent onboard from ocurring again
        if (![[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE])
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_HAS_LAUNCHED_BEFORE];

        if(self.presentingViewController == nil){
            [self navigateToMainApp];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }

    }
    //If we're on any other page
    else{

        [self.pagedViewController shouldMoveToViewAtIndex:self.pagedViewController.currentIndex + 1];

    }

}

- (void)updateStateWithIndex:(NSInteger)index{
    
    
    [self.progressView updateProgressViewForIndex:self.pagedViewController.currentIndex
                                       fromIndex:self.pagedViewController.previousIndex];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat alpha;
        
        //Index 0 = the first page
        //Index 2 = the first page after signing up
        if(self.backButton.alpha > 0 && (index == 0 || index == 2)){
            alpha = 0.0f;
        }
        else{
            alpha = 1.0f;
            self.backButton.enabled = YES;
            self.backButton.hidden = NO;
        }
        
        [UIView animateWithDuration:.3 animations:^{
            self.backButton.alpha = alpha;
        } completion:^(BOOL finished) {
            if(alpha == 0)
                self.backButton.hidden = YES;
        }];
        
    });
    
}



@end
