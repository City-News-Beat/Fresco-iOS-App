//
//  FRSModerationManager.m
//  Fresco
//
//  Created by User on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSModerationManager.h"
#import "FRSUserManager.h"
#import "FRSAppDelegate.h"

static NSString *const blockedUsersEndpoint = @"user/blocked";
static NSString *const blockUserEndpoint = @"user/%@/block";
static NSString *const unblockUserEndpoint = @"user/%@/unblock";
static NSString *const reportUserEndpoint = @"user/%@/report";
static NSString *const reportGalleryEndpoint = @"gallery/%@/report";

@interface FRSModerationManager () <FRSAlertViewDelegate>

@property (strong, nonatomic) FRSAlertView *suspendedAlert;

@end

@implementation FRSModerationManager

+ (instancetype)sharedInstance {
    static FRSModerationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSModerationManager alloc] init];
    });
    return instance;
}

- (void)blockUser:(NSString *)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:blockUserEndpoint, userID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)unblockUser:(NSString *)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unblockUserEndpoint, userID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}
- (void)reportUser:(NSString *)userID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:reportUserEndpoint, userID];
    [[FRSAPIClient sharedClient] post:endpoint withParameters:params completion:completion];
}

- (void)reportGallery:(FRSGallery *)gallery params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:reportGalleryEndpoint, gallery.uid];
    [[FRSAPIClient sharedClient] post:endpoint withParameters:params completion:completion];
}

- (void)fetchBlockedUsers:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:blockedUsersEndpoint withParameters:Nil completion:completion];
}

- (void)checkSuspended {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate reloadUser];

    if ([[FRSUserManager sharedInstance] authenticatedUser].suspended) {
        self.suspendedAlert = [[FRSAlertView alloc] initWithTitle:@"SUSPENDED" message:[NSString stringWithFormat:@"You’ve been suspended for inappropriate behavior. You will be unable to submit, repost, or comment on galleries for 14 days."] actionTitle:@"CONTACT SUPPORT" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.suspendedAlert show];
    }
}

- (void)didPressButtonAtIndex:(NSInteger)index {
    if (self.suspendedAlert) {
        switch (index) {
        case 0:
            [self presentSmooch];
            break;

        case 1:
            break;
        default:
            break;
        }
    }
}

- (void)presentSmooch {
    FRSUser *currentUser = [[FRSUserManager sharedInstance] authenticatedUser];
    if (currentUser.firstName) {
        [SKTUser currentUser].firstName = currentUser.firstName;
    }
    if (currentUser.email) {
        [SKTUser currentUser].email = currentUser.email;
    }
    if (currentUser.uid) {
        [[SKTUser currentUser] addProperties:@{ @"Fresco ID" : currentUser.uid }];
    }
    [Smooch show];
}

@end
