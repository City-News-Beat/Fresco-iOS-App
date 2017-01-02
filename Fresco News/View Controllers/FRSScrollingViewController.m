//
//  FRSScrollingViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "UIFont+Fresco.h"

@interface FRSScrollingViewController () <UIScrollViewDelegate>

@property (nonatomic) BOOL animatingShow;
@property (nonatomic) BOOL animatingHide;

@property (nonatomic) BOOL scrollDirectionChanged;

@property (nonatomic) BOOL enabled;

@property (nonatomic) BOOL backButtonHidden;
@property (nonatomic) float prevDirectOffSetY;
@property (nonatomic) float prevNavBarY;

@end

@implementation FRSScrollingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (self.shouldHaveBackButton) {
        [super configureBackButtonAnimated:NO];
    }

    self.navBarHeight = 20;
    //NSLog(@"Nav Bar Height: %f", self.navBarHeight);

    self.enabled = YES;
    self.backButtonHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    NSMutableArray *barButtonItems = [NSMutableArray array];
    [barButtonItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [barButtonItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    [self expandNavBar:barButtonItems];
    [super viewWillAppear:animated];
}

- (void)configureTableView {

    NSInteger height = self.view.frame.size.height - 64;
    if (self.hiddenTabBar)
        height += 49;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -144, self.view.frame.size.width, height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pageScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 200)];
    self.pageScroller.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height + 200);
    self.pageScroller.pagingEnabled = YES;
    self.pageScroller.showsHorizontalScrollIndicator = NO;
    self.pageScroller.delaysContentTouches = FALSE;
    self.pageScroller.bounces = FALSE;
    [self.pageScroller addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentContentOffY = scrollView.contentOffset.y;
    NSInteger currentContentOffX = scrollView.contentOffset.x;
    NSInteger difference = currentContentOffY - self.prevContentOffY;
    if (!self.scrollDirectionChanged) {
        self.prevDirectOffSetY -= self.prevDirectOffSetY;
    }

    if (difference == 0 && self.scrollDirection == UIScrollViewScrollDirectionUp) {
        difference = -1;
    } else if (difference == 0 && self.scrollDirection == UIScrollViewScrollDirectionDown) {
        difference = 1;
    }

    NSInteger scrollDifference = currentContentOffY - self.prevDirectOffSetY;

    //NSLog(@"Scrolling");
    //NSLog(@"Difference: %ld", (long)difference);

    NSMutableArray *barButtonItems = [NSMutableArray array];
    [barButtonItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [barButtonItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];

    //NSLog(@"\n");

    //NSLog(@"Nav Bar Bounds Y: %f", navBarHeight);

    //NSLog(@"PREV NAV BAR Y: %f",self.prevNavBarY);
    //NSLog(@"BOUNDS Y: %f",self.navigationController.navigationBar.bounds.origin.y);

    if (currentContentOffY > 0) {
        //If the users scrolls down (scrollview condenses)
        float scrollingDifference = self.navigationController.navigationBar.frame.origin.y + (self.prevDirectOffSetY - difference);
        self.navBarYValue = scrollingDifference;

        //NSLog(@"%f",self.navigationController.navigationBar.frame.origin.y);
        //NSLog(@"Scrolling Difference %f",scrollingDifference);

        if ((scrollingDifference > -self.navBarHeight - 3) && self.scrollDirection == UIScrollViewScrollDirectionDown) {
            [self condenseNavBarBy:scrollingDifference BarButtonItems:barButtonItems];
        } else if (self.scrollDirection == UIScrollViewScrollDirectionDown) {
            [self collapseNavBar:barButtonItems];
        } else if ((scrollingDifference < self.navBarHeight) && self.scrollDirection == UIScrollViewScrollDirectionUp) {
            [self expandNavBarBy:scrollingDifference BarButtonItems:barButtonItems];
        } else if (self.scrollDirection == UIScrollViewScrollDirectionUp) {
            [self expandNavBar:barButtonItems];
        }
    }

    if (self.isBeingDismissed && self.tabBarController.tabBar.hidden) {
        CGRect newFrame = self.tabBarController.tabBar.frame;
        newFrame.origin.y = currentContentOffX - self.tabBarController.tabBar.frame.size.height;
        [self.tabBarController.tabBar setFrame:newFrame];
    }

    [self determineScrollDirection:scrollView];

    [self adjustFramesForDifference:difference forScrollView:scrollView];

    self.prevContentOffY = currentContentOffY;
}
/*

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"Is cancelled: %i", [context isCancelled]);
    }];
}

-(void)popViewController{
    NSLog(@"Popped");
    //[self.navigationController dismiss]
}
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    NSLog(@"POPPed");
}

-(void)setModalInPopover:(BOOL)modalInPopover{
    NSLog(@"POOOPED");
}


-(void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item{
    NSLog(@"It is popped");
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    NSLog(@"Transitioning");
}

-(void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC{
    NSLog(@"SEGUEING");
}*/

/*
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    NSLog(@"ANIMATING");
    return nil;
}*/

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    NSMutableArray *barButtonItems = [NSMutableArray array];
    [barButtonItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [barButtonItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    [self expandNavBar:barButtonItems];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSMutableArray *barButtonItems = [NSMutableArray array];
    [barButtonItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [barButtonItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    //NSLog(@"Y OFFSET: %f",scrollView.contentOffset.y);
    if (self.scrollDirection == UIScrollViewScrollDirectionDown && scrollView.contentOffset.y > self.navBarHeight * 2) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           [self collapseNavBar:barButtonItems];
                         }
                         completion:nil];
    } else if (self.scrollDirection == UIScrollViewScrollDirectionUp) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           [self expandNavBar:barButtonItems];
                         }
                         completion:nil];
    }
}

- (void)expandNavBar:(NSArray *)barButtonItems {
    [self.navigationController.navigationBar setFrame:CGRectMake(self.navigationController.navigationBar.frame.origin.x, self.navBarHeight, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    for (UIBarButtonItem *item in barButtonItems) {
        [item setTintColor:[item.tintColor colorWithAlphaComponent:1]];
    }
    self.navigationItem.titleView.alpha = 1.0;
    //[self.navigationItem.titleView setBounds:CGRectMake(self.navigationItem.titleView.bounds.origin.x, self.navBarHeight-4, self.navigationItem.titleView.bounds.size.width,5)];
}

- (void)collapseNavBar:(NSArray *)barButtonItems {
    [self.navigationController.navigationBar setFrame:CGRectMake(self.navigationController.navigationBar.frame.origin.x, -self.navBarHeight - 3, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    for (UIBarButtonItem *item in barButtonItems) {
        [item setTintColor:[item.tintColor colorWithAlphaComponent:0.0]];
    }
    self.navigationItem.titleView.alpha = 0.0;
    //[self.navigationItem.titleView setBounds:CGRectMake(self.navigationItem.titleView.bounds.origin.x, (self.navBarHeight/2)-4, self.navigationItem.titleView.bounds.size.width,5)];
}

- (void)expandNavBarBy:(float)value BarButtonItems:(NSArray *)barButtonItems {
    [self.navigationController.navigationBar setFrame:CGRectMake(self.navigationController.navigationBar.frame.origin.x, value, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    //Change nav buttons alpha & size
    for (UIBarButtonItem *item in barButtonItems) {
        [item setTintColor:[item.tintColor colorWithAlphaComponent:(value / (self.navBarHeight))]];
    }
    //Change titleview's alpha & y origin
    self.navigationItem.titleView.alpha = (value / (self.navBarHeight));
    //[self.navigationItem.titleView setFrame:CGRectMake(self.navigationItem.titleView.frame.origin.x, value+(self.navBarHeight/2)-4, self.navigationItem.titleView.frame.size.width,self.navigationItem.titleView.frame.size.height)];
}

- (void)condenseNavBarBy:(float)value BarButtonItems:(NSArray *)barButtonItems {
    [self.navigationController.navigationBar setFrame:CGRectMake(self.navigationController.navigationBar.frame.origin.x, value, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    for (UIBarButtonItem *item in barButtonItems) {
        [item setTintColor:[item.tintColor colorWithAlphaComponent:(value / (self.navBarHeight))]];
    }
    self.navigationItem.titleView.alpha = (value / (self.navBarHeight));
    //[self.navigationItem.titleView setFrame:CGRectMake(self.navigationItem.titleView.frame.origin.x, value+(self.navBarHeight/2)-4, self.navigationItem.titleView.frame.size.width,self.navigationItem.titleView.frame.size.height)];
}

- (void)adjustFramesForDifference:(NSInteger)difference forScrollView:(UIScrollView *)scrollView {
    if (!difference)
        return;

    if (self.scrollDirection == UIScrollViewScrollDirectionUp) { // The user is scrolling up and therefore the navigation bar should come back down.
        [self showNavBarForScrollView:scrollView animated:YES];
    } else if (self.scrollDirection == UIScrollViewScrollDirectionDown) { //The user is scrolling down and therefore the navigation bar should hide.
        [self hideNavBarForScrollView:scrollView animated:YES];
    }
}

- (void)showNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated {
    /*
    CGRect toFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    if (self.search != Nil) {
        [self.navigationItem setRightBarButtonItem:self.search animated:YES];
        self.search = Nil;
    }

    if (animated){
        
        if (self.animatingShow) {
            return;
        }
        if (!self.scrollDirectionChanged) {
            return;
        }
        
        self.animatingShow = YES;
        self.animatingHide = NO;
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.navigationBar.frame = toFrame;
            scrollView.frame = scrollViewFrame;
            self.navigationItem.titleView.alpha = 1.0;
            
            
            Need to check if back button already exists to avoid weird scrolling bug
            if (self.shouldHaveBackButton){
                [super configureBackButtonAnimated:YES];
            }
            
            if (self.shouldHaveBackButton && !self.scrollDirectionChanged){
                self.scrollDirectionChanged = FALSE;
                [super configureBackButtonAnimated:YES];
            }
            
        } completion:^(BOOL finished) {
            if (finished)
                self.animatingShow = NO;
        }];
    }
    else {
        scrollView.frame = scrollViewFrame;
        self.navigationController.navigationBar.frame = toFrame;
        if (self.shouldHaveBackButton && self.backButtonHidden){
            [super configureBackButtonAnimated:NO];
        }
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];*/
}

- (void)hideNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated {
    /*
    self.backButtonHidden = YES;
    
    CGRect toFrame = CGRectMake(0, -22, [UIScreen mainScreen].bounds.size.width, 44);
    
    if (animated){
        
        if (self.animatingShow) {
            return;
        }
        if (!self.scrollDirectionChanged) {
            return;
        }
        
        self.animatingHide = YES;
        self.animatingShow = NO;
        
        self.search = self.navigationItem.rightBarButtonItem;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.navigationBar.frame = toFrame;
            //scrollView.frame = scrollViewFrame;
            self.navigationItem.titleView.alpha = 0.0;
            if (self.shouldHaveBackButton){
                [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem new] animated:YES];
            }
        } completion:^(BOOL finished) {
            if (finished) {
                self.animatingHide = NO;
            }
        }];
    }
    else {
        //scrollView.frame = scrollViewFrame;
        self.navigationController.navigationBar.frame = toFrame;
        [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem new] animated:NO];
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
     self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];*/
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self determineScrollDirection:scrollView];
    //NSLog(@"Decelerating");
}
- (void)scrollViewWillEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidScroll:scrollView];
    //NSLog(@"Decelerating");
}

- (void)determineScrollDirection:(UIScrollView *)scrollView {

    CGFloat currentContentOffY = scrollView.contentOffset.y;
    NSInteger difference = currentContentOffY - self.prevContentOffY;

    if (difference < 0) {
        if (self.scrollDirection == UIScrollViewScrollDirectionDown || !self.scrollDirection) {
            self.scrollDirectionChanged = YES;
            self.prevDirectOffSetY = difference;
            self.prevNavBarY = self.navigationController.navigationBar.bounds.origin.y;
            //NSLog(@"Changed Direction!");
        } else {
            self.scrollDirectionChanged = NO;
        }

        self.scrollDirection = UIScrollViewScrollDirectionUp;
    } else if (difference > 0) {

        if (self.scrollDirection == UIScrollViewScrollDirectionUp || !self.scrollDirection) {
            self.scrollDirectionChanged = YES;
            self.prevDirectOffSetY = difference;
            self.prevNavBarY = self.navigationController.navigationBar.bounds.origin.y;
            //NSLog(@"Changed Direction!");
        } else {
            self.scrollDirectionChanged = NO;
        }

        self.scrollDirection = UIScrollViewScrollDirectionDown;
    }
}

#pragma mark - Status Bar

- (void)statusBarTappedAction:(NSNotification *)notification {
    if (self.enabled) {
        if (self.tableView.contentOffset.y >= 0) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              self.enabled = YES;
            });
        }
    }
    self.enabled = NO;
}

- (void)addStatusBarNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:kStatusBarTappedNotification
                                               object:nil];
}

- (void)removeStatusBarNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

@end
