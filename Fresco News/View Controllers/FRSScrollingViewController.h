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

-(void)configureTableView;

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
