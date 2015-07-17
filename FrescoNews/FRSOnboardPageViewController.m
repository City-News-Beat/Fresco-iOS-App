//
//  FRSOnboardPageViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSOnboardPageViewController.h"
#import "FRSOnboardViewController.h"
#import "FRSRootViewController.h"
#import "AppDelegate.h"

@interface FRSOnboardPageViewController()

@property (nonatomic, assign) BOOL runningNextPage;

@end

@implementation FRSOnboardPageViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options{

    if(self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options]){
    
        // Create page view controller
        self.dataSource = self;
    
        FRSOnboardViewController *viewController = [self viewControllerAtIndex:0];
        
        NSArray *viewControllers = @[viewController];

        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
    }
    
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FRSOnboardViewController Delegate

-(void)nextPageClicked:(NSInteger)index{
    
    if (index < 2 && !self.runningNextPage) {
        
        _runningNextPage = YES;
        
        FRSOnboardViewController *viewController = [self viewControllerAtIndex:(index +1)];
        
        NSArray *controllers = @[viewController];
        
        [self setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
            
            _runningNextPage = NO;
        
        }];
    }
    else{
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate setRootViewControllerToFirstRun];
        
    }
    
}

#pragma mark - UIPageViewController Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = ((FRSOnboardViewController*) viewController).index;
    
    if (index == 0 || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((FRSOnboardViewController*) viewController).index;
    
    index++;
    
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

#pragma mark - UIPageViewController DataSource

- (FRSOnboardViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    if (index == 3) {
        return nil;
    }

    FRSOnboardViewController *viewController = [[FRSOnboardViewController alloc] initWithNibName:@"FRSOnboardViewController" bundle:nil];
    
    viewController.index = index;
    
    viewController.frsTableViewCellDelegate = self;
    
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
