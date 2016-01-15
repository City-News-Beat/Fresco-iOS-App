//
//  FRSContentActionsBar.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSContentActionBarDelegate;

@interface FRSContentActionsBar : UIView

@property (weak, nonatomic) NSObject <FRSContentActionBarDelegate> *delegate;

-(instancetype)initWithOrigin:(CGPoint)origin delegate:(id <FRSContentActionBarDelegate>)delegate;

@end

@protocol FRSContentActionBarDelegate <NSObject>

-(NSString *)titleForActionButton;

-(UIColor *)colorForActionButton;

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar;

@end