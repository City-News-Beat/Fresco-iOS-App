//
//  FirstRunPageViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FirstRunPageViewController.h"
#import "FirstRunViewController.h"
#import "FirstRunRadiusViewController.h"
#import "FirstRunPermissionsViewController.h"
#import "FirstRunAccountViewController.h"
#import "FirstRunPersonalViewController.h"
#import "FirstRunRadiusViewController.h"
#import "FRSFirstRunWrapperViewController.h"
#import "UIViewController+Additions.h"

@implementation FirstRunPageViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options{
    
    if(self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options]){
        
        // Create page view controller
        self.dataSource = self;
        
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
    self.dataSource = self;
    
}

- (void)shouldMoveToViewAtIndex:(NSInteger)index{
    
    UIViewController *viewController = [self viewControllerAtIndex:index];
    
    if(viewController == nil) return;
    
    self.previousIndex = self.currentIndex;
    
    self.currentIndex  = index;
    
    NSArray *controllers = @[viewController];
                                        
    [self setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [(FRSFirstRunWrapperViewController *)self.parentViewController updateStateWithIndex:self.currentIndex];

}

#pragma mark - UIPageViewController Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = ((FRSBaseViewController *)viewController).index - 1;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = ((FRSBaseViewController *)viewController).index + 1;
    
    return [self viewControllerAtIndex:index];
    
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
    
    if(index == 0){
        FirstRunViewController *vc = [[FirstRunViewController alloc] init];
        vc.index = index;
        return vc;
    }
    else if(index == 1){
        FirstRunAccountViewController *vc = [[FirstRunAccountViewController alloc] init];
        vc.index = index;
        
        return vc;
    }
    else if(index == 2){
     
        FirstRunPersonalViewController *vc = [[FirstRunPersonalViewController alloc] init];
        vc.index = index;
        return vc;

    }
    else if(index == 3){
        FirstRunPermissionsViewController *vc = [[FirstRunPermissionsViewController alloc] init];
        vc.index = index;
        return vc;
    }
    else if(index == 4){
        FirstRunRadiusViewController *vc = [[FirstRunRadiusViewController alloc] init];
        vc.index = index;
        return vc;
    }
    
    return nil;

}




@end