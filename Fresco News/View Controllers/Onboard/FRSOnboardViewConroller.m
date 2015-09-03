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


}

- (IBAction)nextButtonTapped:(id)sender {
    
    [self.pagedViewController movedToViewAtIndex:self.pagedViewController.currentIndex];

}

- (void)updateStateWithIndex:(NSInteger)index{
    
    dispatch_async(dispatch_get_main_queue(), ^{

        //Set progress images to reflect currentIndex
        if (self.pagedViewController.currentIndex == 0){
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            self.progressImage.image = [UIImage imageNamed:@"progress-3-1"];
        }
        if (self.pagedViewController.currentIndex == 1){
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            self.progressImage.image = [UIImage imageNamed:@"progress-3-2"];
        }
        if (self.pagedViewController.currentIndex == 2){
            [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
            self.progressImage.image = [UIImage imageNamed:@"progress-3-3"];
        }
        
    });
    
}

@end
