//
//  FRSScrollingViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIScrollViewScrollDirection){
    UIScrollViewScrollDirectionLeft = 0,
    UIScrollViewScrollDirectionRight,
    UIScrollViewScrollDirectionUp,
    UIScrollViewScrollDirectionDown
};

@interface FRSScrollingViewController : UIViewController

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
