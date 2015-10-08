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
    
    self.delegate = self;
    self.dataSource = self;
    
    [self onboardAnimation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)movedToViewAtIndex:(NSInteger)index{
    
    NSLog(@"%ld",index);
    
    if (index < 2 && !self.runningNextPage) {
        
        _runningNextPage = YES;
        
        self.currentIndex ++;
        
        OnboardPageCellController *viewController = [self viewControllerAtIndex:self.currentIndex];
        
        if(viewController == nil) return;
        
        NSArray *controllers = @[viewController];
        
        //Update the dots on the next button
        if([self.parentViewController isKindOfClass:[FRSOnboardViewConroller class]]) {
        
            FRSOnboardViewConroller *parentVC = (FRSOnboardViewConroller *) self.parentViewController;
            
            [parentVC updateStateWithIndex:self.currentIndex];
            
        }
    
        [self setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
            
            [viewController performAnimation];
            
            if(finished) _runningNextPage = NO;
            
        }];
    }
    
    else{
        
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
        
        OnboardPageCellController *onBoardPageCellController = [self.viewControllers firstObject];
        
        [onBoardPageCellController performAnimation];
        
    });
}

@end

