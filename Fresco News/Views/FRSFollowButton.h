//
//  FRSFollowButton.h
//  Fresco
//
//  Created by Omar Elfanek on 1/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUser.h"

@protocol FRSFollowButtonDelegate <NSObject>
@end


@interface FRSFollowButton : UIButton

- (instancetype)initWithDelegate:(id<FRSFollowButtonDelegate>)delegate user:(FRSUser *)user;

@property (weak, nonatomic) NSObject<FRSFollowButtonDelegate> *delegate;



/**
 This method updates the image to reflect a follow or following state.
 
 @param following A boolean that determines if the button should display a following or not following state.
 */
-(void)updateIconForFollowing:(BOOL)following;

@end
