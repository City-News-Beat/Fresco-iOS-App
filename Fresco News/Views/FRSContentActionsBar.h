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

-(void)actionButtonTitleNeedsUpdate;
-(void)handleHeartState:(BOOL)state;
-(void)handleRepostState:(BOOL)state;
-(void)handleHeartAmount:(NSInteger)amount;

@end

@protocol FRSContentActionBarDelegate <NSObject>

-(NSString *)titleForActionButton;

-(UIColor *)colorForActionButton;

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar;
-(void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar;
-(void)handleActionButtonTapped;

@end