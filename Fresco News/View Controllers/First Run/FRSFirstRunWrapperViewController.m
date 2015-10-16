//
//  FRSFirstRunWrapperViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSFirstRunWrapperViewController.h"
#import "FirstRunPageViewController.h"

@interface FRSFirstRunWrapperViewController ()

@property (weak, nonatomic) IBOutlet UIButton *navigationButton;

/*
** Views and Viewcontrollers
*/

@property (strong, nonatomic) FirstRunPageViewController *pagedViewController;


@property (weak, nonatomic) IBOutlet UIView *containerPageView;

@end

@implementation FRSFirstRunWrapperViewController

- (void)viewDidLoad {
    
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
}

/**
 *  Next Button at the buttom of the screen
 *
 */

- (IBAction)buttonNavigationButton:(UIButton *)sender {
    
    //If we're on the first page
    if(self.pagedViewController.currentIndex == 0){
        
        //Set has Launched Before to prevent onboard from ocurring again
        if (![[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE])
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_HAS_LAUNCHED_BEFORE];
        
        if(self.presentingViewController == nil){
            [self navigateToMainApp];
        }
        else{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    
    }
    //If we're on any other page
    else{
    
        [self.pagedViewController shouldMoveToViewAtIndex:self.pagedViewController.currentIndex + 1];
        
    }
    

}


@end
