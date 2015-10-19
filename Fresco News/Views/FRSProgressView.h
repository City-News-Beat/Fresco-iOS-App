//
//  FRSProgressView.h
//  Fresco
//
//  Created by Omar Elfanek on 10/2/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSProgressViewDelegate <NSObject>

@required

/**
 *  Selector for touching the Progress View's button
 */

- (void)nextButtonTapped;

@end

@interface FRSProgressView : UIView

@property id<FRSProgressViewDelegate> delegate;

@property CGFloat *progressPercent;

@property (strong, nonatomic) NSMutableArray *arrayOfEmptyCircles;

@property (strong, nonatomic) NSMutableArray *arrayOfFilledCircles;

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count;

- (void)animateProgressViewAtPercent:(CGFloat)percent;

- (void)fillingCircleAtIndex:(NSInteger)index;

- (void)emptyingCircleAtIndex:(NSInteger)index;

- (void)updateNextButtonAtIndex:(NSInteger)index;

/**
 *  Updates the progress view at the pass indices
 *
 *  @param currentIndex  The current index (The one just traveled to)
 *  @param previousIndex The previous index of the progress view (The one it just came from)
 */

- (void)updateProgressViewAtIndex:(NSInteger)currentIndex fromIndex:(NSInteger)previousIndex;


@end
