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
        
        NSArray *controllers = @[viewController];
        
        if([self.parentViewController isKindOfClass:[FRSOnboardViewConroller class]]){
            
            FRSOnboardViewConroller *parentVC = (FRSOnboardViewConroller *)self.parentViewController;
            
            [parentVC updateStateWithIndex:self.currentIndex];
            
        }
        
        [self setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
            
            _runningNextPage = NO;
        
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

    NSUInteger index = ((OnboardPageCellController*) viewController).index;
    
    if (index == 0 || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((OnboardPageCellController*) viewController).index;
    
    index++;
    
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{

    if(!completed) return;
    
    NSUInteger index = [[self.viewControllers lastObject] index];
    
    self.currentIndex = index;
    
    if([self.parentViewController isKindOfClass:[FRSOnboardViewConroller class]]){
    
        FRSOnboardViewConroller *parentVC = (FRSOnboardViewConroller *)self.parentViewController;
        
        [parentVC updateStateWithIndex:self.currentIndex];
    
    }
}



#pragma mark - UIPageViewController DataSource

- (OnboardPageCellController *)viewControllerAtIndex:(NSUInteger)index
{
    
    if (index == 3) {
        return nil;
    }

    OnboardPageCellController *viewController = [[OnboardPageCellController alloc] initWithNibName:@"FRSOnboardViewController" bundle:nil];
    
    viewController.index = index;
        
    return viewController;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
