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

@end

@implementation FRSScrollingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.shouldHaveBackButton){
        [super configureBackButtonAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    self.enabled = YES;
    self.backButtonHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        
}

-(void)appWillResignActive:(NSNotification*)notification {
    
    self.navigationItem.titleView.alpha = 1.0;
    
    if (self.shouldHaveBackButton){
        [super configureBackButtonAnimated:YES];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

-(void)configureTableView{
    
    NSInteger height = self.view.frame.size.height - 49;
    if (self.hiddenTabBar) height += 49;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, height)];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);

    self.pageScroller = [[UIScrollView alloc] initWithFrame:self.tableView.frame];
    self.pageScroller.contentSize = CGSizeMake(self.view.frame.size.width * 2, height);
    self.pageScroller.pagingEnabled = YES;
    self.pageScroller.showsHorizontalScrollIndicator = NO;
    [self.pageScroller addSubview:self.tableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger currentContentOffY = scrollView.contentOffset.y ;
    if (currentContentOffY > scrollView.contentSize.height - scrollView.frame.size.height) {
        return; //The user is scrolling down, and is pulling past the furthest point.
    }
    else if (currentContentOffY <= 0) {
        return;
    }
    
    NSInteger difference = currentContentOffY - self.prevContentOffY;
    
    [self determineScrollDirection:scrollView];
    
    [self adjustFramesForDifference:difference forScrollView:scrollView];
    
    self.prevContentOffY = currentContentOffY;
}

-(void)adjustFramesForDifference:(NSInteger)difference forScrollView:(UIScrollView *)scrollView{
    if (!difference) return;
    
    if (self.scrollDirection == UIScrollViewScrollDirectionUp){ // The user is scrolling up and therefore the navigation bar should come back down.
        [self showNavBarForScrollView:scrollView animated:YES];
    }
    else if (self.scrollDirection == UIScrollViewScrollDirectionDown){ //The user is scrolling down and therefore the navigation bar should hide.
        [self hideNavBarForScrollView:scrollView animated:YES];
    }
}

-(void)showNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated{
    
    CGRect toFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    NSInteger height = [UIScreen mainScreen].bounds.size.height - 20 - 49;
    if (self.hiddenTabBar) height += 49;
    if (self.actionBarVisible) height -= 44;
    CGRect scrollViewFrame = CGRectMake(0, 0, self.view.frame.size.width, height);

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
            //scrollView.frame = scrollViewFrame;
            self.navigationItem.titleView.alpha = 1.0;
            
            
            //Need to check if back button already exists to avoid weird scrolling bug
            if (self.shouldHaveBackButton){
                [super configureBackButtonAnimated:YES];
            }
            
//            if (self.shouldHaveBackButton && !self.scrollDirectionChanged){
//                self.scrollDirectionChanged = FALSE;
//                [super configureBackButtonAnimated:YES];
//            }
            
        } completion:^(BOOL finished) {
            if (finished)
                self.animatingShow = NO;
        }];
    }
    else {
       // scrollView.frame = scrollViewFrame;
        self.navigationController.navigationBar.frame = toFrame;
        if (self.shouldHaveBackButton && self.backButtonHidden){
            [super configureBackButtonAnimated:NO];
        }
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)hideNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated {
    
    self.backButtonHidden = YES;
    
    CGRect toFrame = CGRectMake(0, -22, [UIScreen mainScreen].bounds.size.width, 44);
    
    NSInteger height = [UIScreen mainScreen].bounds.size.height - 20 - 49;
    if (self.hiddenTabBar) height += 49;
    if (self.actionBarVisible) height  -= 44;
    
    CGRect scrollViewFrame = CGRectMake(0, -44, self.view.frame.size.width, height);
    
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
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //    CGRect toFrame;
    //
    //    if (scrollView.contentOffset.y <= 0){
    //        toFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    //        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    //            self.navigationController.navigationBar.frame = toFrame;
    //        } completion:^(BOOL finished) {
    //            nil;
    //        }];
    //    }
}

-(void)determineScrollDirection:(UIScrollView *)scrollView{
    
    CGFloat currentContentOffY = scrollView.contentOffset.y;
    NSInteger difference = currentContentOffY - self.prevContentOffY;
    
    if (difference < 0){
        if (self.scrollDirection == UIScrollViewScrollDirectionDown || !self.scrollDirection) {
            self.scrollDirectionChanged = YES;
        }
        else {
            self.scrollDirectionChanged = NO;
        }
        
        self.scrollDirection = UIScrollViewScrollDirectionUp;
    }
    else if (difference> 0){
        
        if (self.scrollDirection == UIScrollViewScrollDirectionUp || !self.scrollDirection) {
            self.scrollDirectionChanged = YES;
        }
        else {
            self.scrollDirectionChanged = NO;
        }
        
        self.scrollDirection = UIScrollViewScrollDirectionDown;
    }
    
}


#pragma mark - Status Bar

-(void)statusBarTappedAction:(NSNotification*)notification{
    if (self.enabled){
        if (self.tableView.contentOffset.y >= 0) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.enabled = YES;
            });
        }
    }
    self.enabled = NO;
}

-(void)addStatusBarNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:kStatusBarTappedNotification
                                               object:nil];
}

-(void)removeStatusBarNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

@end
