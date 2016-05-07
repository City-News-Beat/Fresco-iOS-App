//
//  FRSProfileViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"

@interface FRSProfileViewController : FRSScrollingViewController
{
    UILabel *titleLabel;
}

-(instancetype)initWithUser:(FRSUser *)user;
@property (nonatomic, retain) FRSUser *representedUser;
@property BOOL authenticatedProfile;
@end
