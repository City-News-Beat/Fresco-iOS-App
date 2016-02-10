//
//  FRSTabbedNavigationTitleView.h
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSTabbedNavigationTitleViewDelegate;

@interface FRSTabbedNavigationTitleView : UIView

@property (weak, nonatomic) NSObject <FRSTabbedNavigationTitleViewDelegate> *delegate;

-(instancetype)initWithTabTitles:(NSArray *)tabTitles delegate:(id <FRSTabbedNavigationTitleViewDelegate>)delegate hasBackButton:(BOOL)hasBackButton;

@end

@protocol FRSTabbedNavigationTitleViewDelegate <NSObject>

-(void)tabbedNavigationTitleViewDidTapButtonAtIndex:(NSInteger)index;
-(void)tabbedNavigationTitleViewDidTapLeftBarItem;
-(void)tabbedNavigationTitleViewDidTapRightBarItem;

-(UIImage *)imageForLeftBarItem;
-(UIImage *)imageForRightBarItem;

@end