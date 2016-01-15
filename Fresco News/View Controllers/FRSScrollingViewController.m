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

@end

@implementation FRSScrollingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.shouldHaveBackButton){
        [super configureBackButtonAnimated:NO];
    }
    
    // Do any additional setup after loading the view.
}


-(void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64 - 49)];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger currentContentOffY = scrollView.contentOffset.y ;
    if (currentContentOffY > scrollView.contentSize.height - scrollView.frame.size.height) return; //The user is scrolling down, and is pulling past the furthest point.
    else if (currentContentOffY <= 0) return;
    
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
    
    NSInteger height = [UIScreen mainScreen].bounds.size.height - 20 - 49;
    if (self.hiddenTabBar) height += 49;
    
    CGRect scrollViewFrame = CGRectMake(0, 0, self.view.frame.size.width, height);
    
    if (animated){
        
        if (self.animatingShow) return;
        if (!self.scrollDirectionChanged) return;
        
        self.animatingShow = YES;
        self.animatingHide = NO;
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.navigationBar.frame = toFrame;
            scrollView.frame = scrollViewFrame;
            self.navigationItem.titleView.alpha = 1.0;
            
            if (self.shouldHaveBackButton){
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
        if (self.shouldHaveBackButton){
            [super configureBackButtonAnimated:NO];
        }
    }
}

-(void)hideNavBarForScrollView:(UIScrollView *)scrollView animated:(BOOL)animated {
    CGRect toFrame = CGRectMake(0, -22, [UIScreen mainScreen].bounds.size.width, 44);
    
    NSInteger height = [UIScreen mainScreen].bounds.size.height - 20 - 49;
    if (self.hiddenTabBar) height += 49;
    
    CGRect scrollViewFrame = CGRectMake(0, -44, self.view.frame.size.width, height);
    
    if (animated){
        
        if (self.animatingHide) return;
        if (!self.scrollDirectionChanged) return;
        
        self.animatingHide = YES;
        self.animatingShow = NO;
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.navigationBar.frame = toFrame;
            scrollView.frame = scrollViewFrame;
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
        scrollView.frame = scrollViewFrame;
        self.navigationController.navigationBar.frame = toFrame;
        [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem new] animated:NO];
    }
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
        if (self.scrollDirection == UIScrollViewScrollDirectionDown || !self.scrollDirection)
            self.scrollDirectionChanged = YES;
        else
            self.scrollDirectionChanged = NO;
        
        self.scrollDirection = UIScrollViewScrollDirectionUp;
    }
    else if (difference> 0){
        
        if (self.scrollDirection == UIScrollViewScrollDirectionUp || !self.scrollDirection)
            self.scrollDirectionChanged = YES;
        else
            self.scrollDirectionChanged = NO;
        
        self.scrollDirection = UIScrollViewScrollDirectionDown;
    }
    
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
