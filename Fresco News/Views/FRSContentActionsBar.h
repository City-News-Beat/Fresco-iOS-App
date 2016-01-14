//
//  FRSContentActionsBar.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSContentActionsBarDelegate <NSObject>

-(NSString *)titleForActionButton;

-(UIColor *)colorForActionButton;

-(void)handleActionButtonTapped;

@end


@interface FRSContentActionsBar : UIView

@property (weak, nonatomic) NSObject <FRSContentActionsBarDelegate> *delegate;

-(instancetype)initWithOrigin:(CGPoint)origin delegate:(id <FRSContentActionsBarDelegate>)delegate;

@end

