//
//  FirstRunPageViewController.h
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstRunPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (assign, nonatomic) NSInteger currentIndex;

- (void)shouldMoveToViewAtIndex:(NSInteger)index;

@end
