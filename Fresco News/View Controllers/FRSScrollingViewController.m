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



@end

@implementation FRSScrollingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Some Title";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont notaBoldWithSize:20];
    [titleLabel sizeToFit];
    titleLabel.center = self.view.center;
    titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 0, titleLabel.frame.size.width, 44);
    
    self.navigationController.navigationBar.topItem.titleView = titleLabel;
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
    
    CGRect toFrame;
    CGRect scrollViewFrame;
    
    if (self.scrollDirection == UIScrollViewScrollDirectionUp){ // The user is scrolling up and therefore the navigation bar should come back down.
        toFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
        scrollViewFrame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 49);
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.navigationBar.frame = toFrame;
            scrollView.frame = scrollViewFrame;
            self.navigationController.navigationBar.topItem.titleView.alpha = 1.0;
        } completion:^(BOOL finished) {
            nil;
        }];
    }
    else if (self.scrollDirection == UIScrollViewScrollDirectionDown){ //The user is scrolling down and therefore the navigation bar should hide.
        toFrame = CGRectMake(0, -22, [UIScreen mainScreen].bounds.size.width, 44);
        scrollViewFrame = CGRectMake(0, -44, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 49);
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.navigationBar.frame = toFrame;
            scrollView.frame = scrollViewFrame;
            self.navigationController.navigationBar.topItem.titleView.alpha = 0.0;
        } completion:^(BOOL finished) {
            nil;
        }];
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
        self.scrollDirection = UIScrollViewScrollDirectionUp;
    }
    else if (difference> 0){
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
