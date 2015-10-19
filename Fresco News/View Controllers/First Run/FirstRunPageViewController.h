//
//  FirstRunPageViewController.h
//  Fresco
//
//  Created by Elmir Kouliev on 10/1/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstRunPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

/**
 *  The current index the page view controller is on
 */
@property (assign, nonatomic) NSInteger currentIndex;

/**
 *  The previous index of the page view controller
 */
@property (assign, nonatomic) NSInteger previousIndex;

/**
*  Tells the PageViewController to move to a specific index
*
*  @param index The index to move to
*/

- (void)shouldMoveToViewAtIndex:(NSInteger)index;

@end
