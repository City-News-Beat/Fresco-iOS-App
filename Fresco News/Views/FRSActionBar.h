//
//  FRSActionBar.h
//  Fresco
//
//  Created by Omar Elfanek on 2/23/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FRSActionBarDelegate;

@interface FRSActionBar : UIView

@property (weak, nonatomic) NSObject <FRSActionBarDelegate> *delegate;

- (instancetype)initWithOrigin:(CGPoint)origin delegate:(id<FRSActionBarDelegate>)delegate;

- (void)updateTitle;
- (void)handleHeartState:(BOOL)state;
- (void)handleRepostState:(BOOL)state;
- (void)handleHeartAmount:(NSInteger)amount;
- (void)handleRepostAmount:(NSInteger)amount;
- (void)setCurrentUser:(BOOL)isAuth;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end



@protocol FRSActionBarDelegate <NSObject>

- (NSString *)titleForActionButton;

//-(void)contentActionBarDidSelectActionButton:(FRSActionBar *)actionBar;
-(void)handleActionButtonTapped:(FRSActionBar *)actionBar;
-(void)handleLike:(FRSActionBar *)actionBar;
-(void)handleLikeLabelTapped:(FRSActionBar *)actionBar;
-(void)handleRepost:(FRSActionBar *)actionBar;
-(void)handleRepostLabelTapped:(FRSActionBar *)actionBar;
-(void)handleShare:(FRSActionBar *)actionbar;

@end
