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

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count;


/**
 *  Initializes new progress view
 *
 *  @param frame    Frame for progress vierw
 *  @param count    Number of pages in progress view
 *  @param disabled If the first index is disabled
 *
 *  @return Returns FRSProgressView insance
 */

- (instancetype)initWithFrame:(CGRect)frame andPageCount:(NSInteger)count withFirstIndexDisabled:(BOOL)disabled;

/**
 *  Updates the progress view at the passed indices
 *
 *  @param currentIndex  The current index (The one just traveled to)
 *  @param previousIndex The previous index of the progress view (The one it just came from)
 */

- (void)updateProgressViewForIndex:(NSInteger)currentIndex fromIndex:(NSInteger)previousIndex;


@end
