//
//  FRSScrollingViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

typedef NS_ENUM(NSUInteger, UIScrollViewScrollDirection) {
    UIScrollViewScrollDirectionLeft = 0,
    UIScrollViewScrollDirectionRight,
    UIScrollViewScrollDirectionUp,
    UIScrollViewScrollDirectionDown
};

@interface FRSScrollingViewController : FRSBaseViewController <UIGestureRecognizerDelegate, UINavigationBarDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIBarButtonItem *search;

@property (nonatomic) UIScrollViewScrollDirection scrollDirection;

@property (nonatomic) NSInteger prevContentOffY;

@property (nonatomic) BOOL shouldHaveBackButton;

@property (nonatomic) float navBarHeight;

@property (nonatomic, retain) UIScrollView *pageScroller;

@property (nonatomic) float navBarYValue;

- (void)configureTableView;

- (void)expandNavBar:(NSArray *)barButtonItems;
- (void)expandNavBarBy:(float)value BarButtonItems:(NSArray *)barButtonItems;
- (void)condenseNavBarBy:(float)value BarButtonItems:(NSArray *)barButtonItems;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)determineScrollDirection:(UIScrollView *)scrollView;

- (void)hideNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated;
- (void)showNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated;

#pragma mark - Status Bar
- (void)statusBarTappedAction:(NSNotification *)notification;
- (void)addStatusBarNotification;
- (void)removeStatusBarNotification;

@end
