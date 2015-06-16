//
//  ProfileHeaderViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ProfileHeaderViewController.h"
#import "FRSUser.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end

@implementation ProfileHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.frsUser.first, self.frsUser.last];
    [self.profileImageView setImageWithURL:[self.frsUser cdnProfileImageURL]];
}

@end
