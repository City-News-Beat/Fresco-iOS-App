//
//  FRSScrollingViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

typedef NS_ENUM(NSUInteger, UIScrollViewScrollDirection){
    UIScrollViewScrollDirectionLeft = 0,
    UIScrollViewScrollDirectionRight,
    UIScrollViewScrollDirectionUp,
    UIScrollViewScrollDirectionDown
};

@interface FRSScrollingViewController : FRSBaseViewController

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic) UIScrollViewScrollDirection scrollDirection;

@property (nonatomic) NSInteger prevContentOffY;

@property (nonatomic) BOOL shouldHaveBackButton;

-(void)configureTableView;

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

-(void)determineScrollDirection:(UIScrollView *)scrollView;

-(void)hideNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated;
-(void)showNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated;

#pragma mark - Status Bar
-(void)statusBarTappedAction:(NSNotification*)notification;
-(void)addStatusBarNotification;
-(void)removeStatusBarNotification;

@end
