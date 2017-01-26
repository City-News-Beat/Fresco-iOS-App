//
//  FRSUserView.h
//  Fresco
//
//  Created by Omar Elfanek on 1/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFollowButton.h"

@protocol FRSUserViewDelegate <NSObject>
- (void)userAvatarTapped;
@end

@interface FRSUserView : UIView <FRSFollowButtonDelegate>
- (instancetype)initWithUser:(FRSUser *)user;
@property (weak, nonatomic) NSObject<FRSUserViewDelegate> *delegate;
@property (strong, nonatomic) FRSFollowButton *followingButton;
@property CGFloat calculatedHeight;
@property (strong, nonatomic) FRSUser *user;
@end
