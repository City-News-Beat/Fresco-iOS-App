//
//  FRSIndicatorDot.h
//  Fresco
//
//  Created by Omar Elfanek on 2/20/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSIndicatorDot : UIView

/**
 Adds a yellow indicator dot to the tab bar at the selected index.

 @param tabBar UITabBar that will be used to add the dot and calculate the x position.
 @param index NSInteger index where the dot will be placed.
 @param animated BOOL animates the dot into the view.
 */
+ (void)addDotToTabBar:(UITabBar *)tabBar atIndex:(NSInteger)index animated:(BOOL)animated;


/**
 Adds a yellow indicator dot to the tab bar at the given x position.
 
 @param tabBar UITabBar that will be used to add the dot and calculate the x position.
 @param position CGFloat x position where the dot will be placed.
 @param index NSInteger used to add a tag to the dot to easily identify it at a later time. (During removal for example).
 @param animated BOOL animates the dot into the view.
 */
+ (void)addDotToTabBar:(UITabBar *)tabBar atPosition:(CGFloat)position atIndex:(NSInteger)index animated:(BOOL)animated;


/**
 Removes the dot from its parent view using the dots tag.

 @param view UIView parent view where the dot lives.
 @param index NSInteger index of the dot that will be removed.
 */
+ (void)removeDotInView:(UIView *)view atIndex:(NSInteger)index;


@end
