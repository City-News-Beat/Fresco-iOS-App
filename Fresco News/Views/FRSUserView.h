//
//  FRSUserView.h
//  Fresco
//
//  Created by Omar Elfanek on 1/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFollowButton.h"
#import "FRSUser.h"

@protocol FRSUserViewDelegate <NSObject>

- (void)userAvatarTapped;

@end

@interface FRSUserView : UIView <FRSFollowButtonDelegate>

@property (weak, nonatomic) NSObject<FRSUserViewDelegate> *delegate;
@property (strong, nonatomic) FRSFollowButton *followingButton;
@property CGFloat calculatedHeight;
@property (strong, nonatomic) FRSUser *user;

- (instancetype)initWithUser:(FRSUser *)user;

@end
