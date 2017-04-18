//
//  FRSFollowersFollowingViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 4/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFollowersFollowingViewController.h"
#import "FRSFollowManager.h"

@interface FRSFollowersFollowingViewController ()

@property (strong, nonatomic) FRSUser *user;

@end

@implementation FRSFollowersFollowingViewController

- (instancetype)initWithUser:(FRSUser *)user {
    self = [super init];
    
    if (self) {
        self.user = user;
        self.leftTitle = @"FOLLOWERS";
        self.rightTitle = @"FOLLOWING";
    }
    
    return self;
}

#pragma mark - Datasource

-(void)fetchLeftDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSFollowManager sharedInstance] getFollowersForUser:self.user completion:completion];
}

- (void)fetchRightDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSFollowManager sharedInstance] getFollowingForUser:self.user completion:completion];
}

- (void)loadMoreLeftUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSFollowManager sharedInstance] getFollowersForUser:self.user last:lastUserID completion:completion];
}

- (void)loadMoreRightUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSFollowManager sharedInstance] getFollowingForUser:self.user last:lastUserID completion:completion];
}

@end
