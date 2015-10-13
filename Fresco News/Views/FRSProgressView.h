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

- (void)updateNextButtonAtIndex:(NSInteger)index fromPageCount:(NSInteger)count;



@end
