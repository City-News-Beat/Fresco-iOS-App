//
//  FirstRunPageViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

@import Parse;

#import "FirstRunPageViewController.h"
#import "FirstRunViewController.h"
#import "FirstRunRadiusViewController.h"
#import "FirstRunPermissionsViewController.h"
#import "FirstRunAccountViewController.h"
#import "FirstRunPersonalViewController.h"
#import "FirstRunRadiusViewController.h"
#import "FRSFirstRunWrapperViewController.h"
#import "FRSDataManager.h"
#import "UIViewController+Additions.h"

@interface FirstRunPageViewController()

@property (nonatomic, assign) BOOL inTransition;

@end

@implementation FirstRunPageViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options{
    
    if(self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options]){
        
        // Create page view controller
        self.view.backgroundColor = [UIColor frescoGreyBackgroundColor];
        
        FirstRunViewController *viewController = [[FirstRunViewController alloc] init];
        viewController.index = 0;

        NSArray *viewControllers = @[viewController];
        
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        recognizer.enabled = NO;
    }
    
    self.delegate = self;
    
}

#pragma mark - UIPageViewController Delegate

//These are both nil to disable swipe, unless if in the second view controller

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if([viewController isKindOfClass:[FirstRunAccountViewController class]])
       return [[FirstRunViewController alloc] initWithIndex:0];
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if([viewController isKindOfClass:[FirstRunViewController class]])
        return [[FirstRunAccountViewController alloc] initWithIndex:1];
    
    return nil;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    if(!completed) return;
    
    NSUInteger index = ((FRSBaseViewController *)[self.viewControllers firstObject]).index;
    
    self.previousIndex = self.currentIndex;
    
    self.currentIndex = index;

    [(FRSFirstRunWrapperViewController *)self.parentViewController updateStateWithIndex:self.currentIndex];
    
}

#pragma mark - UIPageViewController DataSource

/**
 *  Called to retrieve a view controller
 *
 *  @param index The specific view controller at this index
 *
 *  @return The view controller at the passed index
 */

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    FRSBaseViewController *vc;

    switch (index){
        
        case 0:
            vc = [[FirstRunViewController alloc] initWithIndex:index];
            break;
        case 1:
            vc = [[FirstRunAccountViewController alloc] initWithIndex:index];
            break;
        case 2:
            vc = [[FirstRunPersonalViewController alloc] initWithIndex:index];
            break;
        case 3:
            vc = [[FirstRunPermissionsViewController alloc] initWithIndex:index];
            break;
        case 4:
            vc = [[FirstRunRadiusViewController alloc] initWithIndex:index];
            break;

    }
    
    return vc;

}

#pragma mark - View Controller specific methods

- (void)moveToViewAtIndex:(NSInteger)index withDirection:(UIPageViewControllerNavigationDirection)direction{
    
    UIViewController *viewController = [self viewControllerAtIndex:index];

    if(viewController == nil)
        return;

    self.previousIndex = self.currentIndex;

    self.currentIndex  = index;

    NSArray *controllers = @[viewController];
    
    __weak typeof(self) weakSelf = self;

    [self setViewControllers:controllers direction:direction animated:YES completion:^(BOOL finished) {
        
        [(FRSFirstRunWrapperViewController *)weakSelf.parentViewController updateStateWithIndex:weakSelf.currentIndex];
        
    }];
}


- (void)shouldMoveToViewAtIndex:(NSInteger)index{
    
    if(index == 2){
    
        FirstRunAccountViewController *vc = self.viewControllers[0];
        
        [vc processLogin];
    
    }
    else if(index == 3){
        
        FirstRunPersonalViewController *vc = self.viewControllers[0];
        
        [vc saveInfo];
        
    }
    else if(index == 4){
        
        [self moveToViewAtIndex:index withDirection:UIPageViewControllerNavigationDirectionForward];
        
    }
    else if(index == 5){
        
        FirstRunRadiusViewController *vc = self.viewControllers[0];
        
        [vc save];
        
    }

}


@end