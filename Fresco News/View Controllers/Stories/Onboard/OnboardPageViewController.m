//
//  FRSOnboardPageViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "OnboardPageViewController.h"
#import "OnboardPageCellController.h"
#import "FRSRootViewController.h"
#import "FRSDataManager.h"
#import "FRSOnboardViewConroller.h"

@interface OnboardPageViewController()

@property (nonatomic, assign) BOOL runningNextPage;

@end

@implementation OnboardPageViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options{

    if(self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options]){
    
        // Create page view controller
        self.dataSource = self;
        
        self.view.backgroundColor = [UIColor whiteBackgroundColor];

        OnboardPageCellController *viewController = [self viewControllerAtIndex:0];
        
        NSArray *viewControllers = @[viewController];

        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
    }
    
    return self;

}

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    self.dataSource = self;
    
    [self onboardAnimation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)movedToViewAtIndex:(NSInteger)index{
    
    if (index < 2 && !self.runningNextPage) {
        
        _runningNextPage = YES;
        
        self.currentIndex ++;
        
        OnboardPageCellController *viewController = [self viewControllerAtIndex:self.currentIndex];
        
        if(viewController == nil) return;
        
        NSArray *controllers = @[viewController];
        
        if([self.parentViewController isKindOfClass:[FRSOnboardViewConroller class]]){
            
            FRSOnboardViewConroller *parentVC = (FRSOnboardViewConroller *)self.parentViewController;
            
            [parentVC updateStateWithIndex:self.currentIndex];
            
        }
        
        [self setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
            
            if(finished) _runningNextPage = NO;
        
        }];
    }
    
    else{
        
        //put into parent vc that handles everything
        
        if(![[FRSDataManager sharedManager] isLoggedIn]){
        
            [((FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController) setRootViewControllerToFirstRun];
            
        }
        else{
        
            [((FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController) setRootViewControllerToTabBar];
            
        }
        
    }
    
}

#pragma mark - UIPageViewController Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = ((OnboardPageCellController*) viewController).animationState;
    
    if (index == 0 || (index == NSNotFound)) {
        
        return nil;
    }
    
    index--;
    
    
    
    return [self viewControllerAtIndex:index];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((OnboardPageCellController*) viewController).animationState;
    
    index++;
    
    if (index == 3) {
        return nil;
    }
    
    
    return [self viewControllerAtIndex:index];
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{

    if(!completed) return;
    
    NSUInteger index = ((OnboardPageCellController *)[self.viewControllers firstObject]).animationState;
    
    self.currentIndex = index;
    
    if([self.parentViewController isKindOfClass:[FRSOnboardViewConroller class]]){
    
        FRSOnboardViewConroller *parentVC = (FRSOnboardViewConroller *)self.parentViewController;
        
        [parentVC updateStateWithIndex:self.currentIndex];
        
        [self onboardAnimation];
    
    }

}



#pragma mark - UIPageViewController DataSource

- (OnboardPageCellController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index == 3) {
        return nil;
    }

    OnboardPageCellController *viewController = [[OnboardPageCellController alloc] initWithAnimationState:index];
    
    return viewController;
}



- (void)onboardAnimation {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.currentIndex == 0) {
            
            [self animateOnboard1];
            
            NSLog (@"index: 0");
        }
        
        if (self.currentIndex == 1) {
            
            OnboardPageCellController *onBoardPageCellController = [self.viewControllers firstObject];

            onBoardPageCellController.cloud.alpha = 1;
            onBoardPageCellController.upload.alpha = 1;
            onBoardPageCellController.camera.alpha = 1;
            
//            onBoardPageCellController.assignmentBottomLeft.alpha = 0;
//            onBoardPageCellController.assignmentBottomRight.alpha = 0;
//            onBoardPageCellController.assignmentTopLeft.alpha = 0;
//            onBoardPageCellController.assignmentTopRight.alpha = 0;
            


            NSLog (@"index: 1");
        }
        
        
        if (self.currentIndex == 2) {
            
            OnboardPageCellController *onBoardPageCellController = [self.viewControllers firstObject];

            onBoardPageCellController.greyCloud.alpha = 1;
            onBoardPageCellController.television.alpha = 1;
            onBoardPageCellController.newspaper.alpha = 1;
            onBoardPageCellController.uploadLeft.alpha = 1;
            onBoardPageCellController.uploadRight.alpha = 1;
            onBoardPageCellController.cash1.alpha = 1;
            onBoardPageCellController.cash2.alpha = 1;
            onBoardPageCellController.cash3.alpha = 1;
            
            NSLog (@"index: 2");
        }
        
    });
}



- (void)animateOnboard1 {
    
    OnboardPageCellController *onBoardPageCellController = [self.viewControllers objectAtIndex:0];
    
    onBoardPageCellController.assignmentTopLeft.alpha = 1;
    onBoardPageCellController.assignmentBottomLeft.alpha = 1;
    onBoardPageCellController.assignmentTopRight.alpha = 1;
    onBoardPageCellController.assignmentBottomRight.alpha = 1;
    
    onBoardPageCellController.assignmentTopLeft.transform = CGAffineTransformMakeScale(0, 0);
    onBoardPageCellController.assignmentBottomLeft.transform = CGAffineTransformMakeScale(0, 0);
    onBoardPageCellController.assignmentTopRight.transform = CGAffineTransformMakeScale(0, 0);
    onBoardPageCellController.assignmentBottomRight.transform = CGAffineTransformMakeScale(0, 0);
    
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         onBoardPageCellController.earth.alpha = 1;
                         onBoardPageCellController.earth.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                     }
     
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.25
                                               delay:-0.1
                          
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              onBoardPageCellController.assignmentTopLeft.alpha = 1;
                                              onBoardPageCellController.assignmentTopLeft.transform = CGAffineTransformMakeScale(1.15, 1.15);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                              [UIView animateWithDuration:0.15
                                                                    delay:0.0
                                               
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   onBoardPageCellController.assignmentTopLeft.transform = CGAffineTransformMakeScale(1, 1);
                                                                   
                                                                   
                                                               }
                                               
                                                               completion:^(BOOL finished) {
                                                                   
                                                               }];
                                              
                                          }];
                         
                     }];
    
    // BUBBLE 2
    
    [UIView animateWithDuration:0.25
                          delay:0.15
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         onBoardPageCellController.assignmentTopRight.transform = CGAffineTransformMakeScale(1.15, 1.15);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              onBoardPageCellController.assignmentTopRight.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
    
    
    // BUBBLE 3
    
    [UIView animateWithDuration:0.25
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         onBoardPageCellController.assignmentBottomLeft.transform = CGAffineTransformMakeScale(1.15, 1.15);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              onBoardPageCellController.assignmentBottomLeft.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
    
    
    // BUBBLE 4
    
    [UIView animateWithDuration:0.25
                          delay:0.65
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         onBoardPageCellController.assignmentBottomRight.transform = CGAffineTransformMakeScale(1.15, 1.15);
                         
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              onBoardPageCellController.assignmentBottomRight.transform = CGAffineTransformMakeScale(1, 1);
                                              
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
}

- (void)animateOnboard2 {
}









@end
