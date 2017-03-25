//
//  UserManager.m
//  Fresco
//
//  Created by User on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserManager.h"
#import "FRSAuthManager.h"
#import "FRSHomeViewController.h"
#import "FRSAppDelegate.h"
#import "NSError+Fresco.h"

static NSString *const userEndpoint = @"user/";
static NSString *const setAvatarEndpoint = @"user/avatar";
static NSString *const updateUserEndpoint = @"user/update";
static NSString *const updateUserIdentityEndpoint = @"user/identity/update";
static NSString *const authenticatedUserEndpoint = @"user/me";
static NSString *const locationEndpoint = @"user/locate";
static NSString *const getTermsEndpoint = @"terms";
static NSString *const acceptTermsEndpoint = @"terms/accept";
static NSString *const settingsEndpoint = @"user/settings";
static NSString *const updateSettingsEndpoint = @"user/settings/update";
static NSString *const disableAccountEndpoint = @"user/disable/";

@implementation FRSUserManager

+ (instancetype)sharedInstance {
    static FRSUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSUserManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLocationUpdate:)
                                                     name:FRSLocationUpdateNotification
                                                   object:nil];
    }

    return self;
}

#pragma mark - Load/Update User

- (void)getUserWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:@"user/%@", user];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                completion(responseObject, error);
                                return;
                            }

                            if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                                completion(responseObject, error);
                            }

                            // shouldn't happen
                            completion(responseObject, error);
                          }];
}

- (void)updateLocalUser:(FRSAPIDefaultCompletionBlock)completion {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        return completion(nil, [NSError unAuthenticatedError]);
    }
    
    [[FRSAPIClient sharedClient] get:authenticatedUserEndpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                              if (error) {
                                  if (completion) completion(nil, error);
                              } else {
                                  if (completion) completion(responseObject, nil);
                              }
                          }];
}

- (void)updateUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient]
     post:updateUserEndpoint
     withParameters:digestion
     completion:^(id responseObject, NSError *error) {
         if(completion)
             completion(responseObject, error);
     }];
}

- (void)refreshCurrentUser:(FRSAPIDefaultCompletionBlock)completion {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        completion(nil, [NSError unAuthenticatedError]);
        return;
    }

    //Authenticated request to user/me
    [[FRSAPIClient sharedClient] get:authenticatedUserEndpoint withParameters:Nil completion:completion];
}

- (void)updateIdentityWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:updateUserIdentityEndpoint
                       withParameters:digestion
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)updateLegacyUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *mutableDigestion = [digestion mutableCopy];

    if ([[FRSAuthManager sharedInstance] passwordUsed]) {
        [mutableDigestion setObject:[[FRSAuthManager sharedInstance] passwordUsed] forKey:@"verify_password"];
    } else if ([[FRSAuthManager sharedInstance] socialUsed] && ![[FRSAuthManager sharedInstance] passwordUsed]) {
        [mutableDigestion addEntriesFromDictionary:[[FRSAuthManager sharedInstance] socialUsed]];
    }

    [[FRSUserManager sharedInstance] updateUserWithDigestion:mutableDigestion completion:completion];
}

- (void)postAvatarWithParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] postAvatar:setAvatarEndpoint
                             withParameters:parameters
                                   withData:parameters[@"avatar"]
                                   withName:@"avatar"
                               withFileName:@"photo.jpg"
                                 completion:completion];
}

- (FRSUser *)authenticatedUser {
    // predicate searching for users in store w/ loggedIn as TRUE/1
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isLoggedIn", @(TRUE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUser"];
    signedInRequest.predicate = signedInPredicate;

    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [self managedObjectContext]; // temp (replace with internal or above method

    // no need to sort response, because theoretically there is 1
    NSError *userFetchError;
    NSArray *authenticatedUsers = [context executeFetchRequest:signedInRequest error:&userFetchError];

    // no authenticated user, or we had trouble accessing data store
    if (userFetchError || [authenticatedUsers count] < 1) {
        return Nil;
    }

    // if we have multiple "authenticated" users in data store, we probs messed up big time
    if ([authenticatedUsers count] > 1) {
    }

    _authenticatedUser = [authenticatedUsers firstObject];

    return _authenticatedUser;
}

- (void)reloadUser {
    [self reloadUser:nil];
}

- (void)reloadUser:(FRSAPIDefaultCompletionBlock)completion {
    [self refreshCurrentUser:^(id responseObject, NSError *error) {
        // check against existing user
        if (error || responseObject[@"error"]) {
            // throw up sign in
            return;
        }
        
        [self.managedObjectContext performBlock:^{
            [self saveUserFields:responseObject andSynchronously:NO];
        }];

        [self refreshSettings];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(Nil, Nil);
            }
        });
        
    }];
}

- (void)saveUserFields:(NSDictionary *)responseObject andSynchronously:(BOOL)synchronously {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    FRSUser *authenticatedUser = [[FRSUserManager sharedInstance] authenticatedUser];
    if (!authenticatedUser) {
        authenticatedUser = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:[self managedObjectContext]];
    }

    // update user
    if (responseObject[@"id"] && ![responseObject[@"id"] isEqual:[NSNull null]]) {
        authenticatedUser.uid = responseObject[@"id"];
    }
    if (![responseObject[@"full_name"] isEqual:[NSNull null]]) {
        authenticatedUser.firstName = responseObject[@"full_name"];
    }
    if (responseObject[@"username"] && ![responseObject[@"username"] isEqual:[NSNull null]]) {
        authenticatedUser.username = responseObject[@"username"];
    }
    if (![responseObject[@"bio"] isEqual:[NSNull null]]) {
        authenticatedUser.bio = responseObject[@"bio"];
    }
    if (![responseObject[@"email"] isEqual:[NSNull null]]) {
        authenticatedUser.email = responseObject[@"email"];
    }
    authenticatedUser.isLoggedIn = @(TRUE);
    if (![responseObject[@"avatar"] isEqual:[NSNull null]]) {
        authenticatedUser.profileImage = responseObject[@"avatar"];
    }
    if (responseObject[@"location"] != Nil && ![responseObject[@"location"] isEqual:[NSNull null]]) {
        [authenticatedUser setValue:responseObject[@"location"] forKey:@"location"];
    }
    if (responseObject[@"followed_count"] != Nil && ![responseObject[@"followed_count"] isEqual:[NSNull null]]) {
        [authenticatedUser setValue:responseObject[@"followed_count"] forKey:@"followedCount"];
    }
    if (responseObject[@"following_count"] != Nil && ![responseObject[@"following_count"] isEqual:[NSNull null]]) {
        [authenticatedUser setValue:responseObject[@"following_count"] forKey:@"followingCount"];
    }
    if (responseObject[@"terms"] && ![responseObject[@"terms"] isEqual:[NSNull null]] && [responseObject[@"terms"][@"valid"] boolValue] == FALSE) {
        UITabBarController *tabBar = (UITabBarController *)appDelegate.tabBarController;
        UINavigationController *nav = [tabBar.viewControllers firstObject];
        FRSHomeViewController *homeViewController = [nav.viewControllers firstObject];
        [homeViewController presentTOS];
    }

    if (responseObject[@"blocked"] && ![responseObject[@"blocked"] isEqual:[NSNull null]]) {
        authenticatedUser.blocked = [responseObject[@"blocked"] boolValue];
    }

    if (responseObject[@"blocking"] && ![responseObject[@"blocking"] isEqual:[NSNull null]]) {
        authenticatedUser.blocking = [responseObject[@"blocking"] boolValue];
    }

    if (responseObject[@"suspended_until"] && ![responseObject[@"suspended_until"] isEqual:[NSNull null]]) {
        authenticatedUser.suspended = YES;
    } else {
        authenticatedUser.suspended = NO;
    }

    if (responseObject[@"disabled"] && ![responseObject[@"disabled"] isEqual:[NSNull null]]) {
        authenticatedUser.disabled = [responseObject[@"disabled"] boolValue];
    }

    if (responseObject[@"identity"] && ![responseObject[@"identity"] isKindOfClass:[[NSNull null] class]]) {

        if (responseObject[@"identity"][@"first_name"] != Nil && ![responseObject[@"identity"][@"first_name"] isEqual:[NSNull null]]) {
            [authenticatedUser setValue:responseObject[@"identity"][@"first_name"] forKey:@"stripeFirst"];
        }
        if (responseObject[@"identity"][@"last_name"] != Nil && ![responseObject[@"identity"][@"last_name"] isEqual:[NSNull null]]) {
            [authenticatedUser setValue:responseObject[@"identity"][@"last_name"] forKey:@"stripeLast"];
        }

        NSDictionary *identity = responseObject[@"identity"];

        NSString *birthDay = identity[@"dob_day"];
        NSString *birthMonth = identity[@"dob_month"];
        NSString *birthYear = identity[@"dob_year"];
        NSString *addressLineOne = identity[@"address_line1"];
        NSString *addressLineTwo = identity[@"address_line2"];
        NSString *addressZip = identity[@"address_zip"];
        NSString *addressCity = identity[@"address_city"];
        NSString *addressState = identity[@"address_state"];

        NSString *radius = [responseObject valueForKey:@"radius"];
        if (radius != Nil && ![radius isEqual:[NSNull null]]) {
            [[NSUserDefaults standardUserDefaults] setValue:radius forKey:settingsUserNotificationRadius];
            authenticatedUser.notificationRadius = @([radius floatValue]);
        }

        BOOL hasSavedFields = FALSE;
        if (birthDay != Nil && ![birthDay isEqual:[NSNull null]]) {
            [authenticatedUser setValue:birthDay forKey:@"dob_day"];
            hasSavedFields = TRUE;
        }
        if (birthMonth != Nil && ![birthMonth isEqual:[NSNull null]]) {
            [authenticatedUser setValue:birthMonth forKey:@"dob_month"];
            hasSavedFields = TRUE;
        }
        if (birthYear != Nil && ![birthYear isEqual:[NSNull null]]) {
            [authenticatedUser setValue:birthYear forKey:@"dob_year"];
            hasSavedFields = TRUE;
        }
        if (addressLineOne != Nil && ![addressLineOne isEqual:[NSNull null]]) {
            [authenticatedUser setValue:addressLineOne forKey:@"address_line1"];
            hasSavedFields = TRUE;
        }
        if (addressLineTwo != Nil && ![addressLineTwo isEqual:[NSNull null]]) {
            [authenticatedUser setValue:addressLineTwo forKey:@"address_line2"];
            hasSavedFields = TRUE;
        }
        if (addressZip != Nil && ![addressZip isEqual:[NSNull null]]) {
            [authenticatedUser setValue:addressZip forKey:@"address_zip"];
            hasSavedFields = TRUE;
        }
        if (addressCity != Nil && ![addressCity isEqual:[NSNull null]]) {
            [authenticatedUser setValue:addressCity forKey:@"address_city"];
            hasSavedFields = TRUE;
        }
        if (addressState != Nil && ![addressState isEqual:[NSNull null]]) {
            [authenticatedUser setValue:addressState forKey:@"address_state"];
            hasSavedFields = TRUE;
        }

        NSArray *fieldsNeeded = identity[@"fields_needed"];

        if (fieldsNeeded) {
            [authenticatedUser setValue:fieldsNeeded forKey:@"fieldsNeeded"];
            [authenticatedUser setValue:@(hasSavedFields) forKey:@"hasSavedFields"];
        }
    }
    
    @try {
        if(synchronously) {
            [appDelegate.coreDataController saveContextSynchornously];
        } else {
            [appDelegate.coreDataController saveContext];
        }
    } @catch (NSException *exception) {
        NSLog(@"Error saving context.");
    }
}

#pragma mark - Check User

- (void)checkEmail:(NSString *)email completion:(FRSAPIDefaultCompletionBlock)completion {
    [self check:email completion:completion];
}

- (void)checkUsername:(NSString *)username completion:(FRSAPIDefaultCompletionBlock)completion {
    [self check:username completion:completion];
}

- (void)check:(NSString *)check completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *checkEndpoint = [userEndpoint stringByAppendingString:[check stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[FRSAPIClient sharedClient] get:checkEndpoint
                      withParameters:Nil
                          completion:completion];
}

#pragma mark - Location

- (void)handleLocationUpdate:(NSNotification *)notification {
    if([notification.userInfo[@"location"] isKindOfClass:[CLLocation class]]) {
        [self updateUserLocation:(CLLocation *)notification.userInfo[@"location"] completion:nil];
    }
}

- (void)updateUserLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        if(completion) return completion(nil, [NSError unAuthenticatedError]);
    } else {
        NSLog(@"UPDATED USER LOCATION");
        [[FRSAPIClient sharedClient] post:locationEndpoint
                           withParameters:@{
                                            @"lat": [NSNumber numberWithDouble:(float)location.coordinate.latitude],
                                            @"lng": [NSNumber numberWithDouble:(float)location.coordinate.longitude]
                                            }
                               completion:completion];
    }
}


#pragma mark - Settings

- (void)fetchSettings:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:settingsEndpoint withParameters:Nil completion:completion];
}

- (void)updateSettings:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:updateSettingsEndpoint withParameters:params completion:completion];
}

- (void)updateSettingsWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:updateSettingsEndpoint withParameters:digestion completion:completion];
}

- (void)refreshSettings {
    [self fetchSettings:^(id responseObject, NSError *error) {
      if ([[responseObject class] isSubclassOfClass:[NSArray class]]) {
          for (NSDictionary *setting in responseObject) {
              if ([setting[@"type"] isEqualToString:@"notify-user-dispatch-new-assignment"]) {
                  if (setting[@"options"] && ![setting[@"option"] isEqual:[NSNull null]]) {
                      if ([setting[@"options"][@"send_push"] boolValue]) {
                          [[NSUserDefaults standardUserDefaults] setValue:@(TRUE) forKey:settingsUserNotificationToggle];
                      } else {
                          [[NSUserDefaults standardUserDefaults] setValue:@(FALSE) forKey:settingsUserNotificationToggle];
                      }
                      [[NSUserDefaults standardUserDefaults] synchronize];
                  }
              }
          }
      }
    }];
}

- (void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:disableAccountEndpoint withParameters:digestion completion:completion];
}

#pragma mark - Terms

- (void)getTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:getTermsEndpoint withParameters:Nil completion:completion];
}

- (void)acceptTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:acceptTermsEndpoint withParameters:Nil completion:completion];
}

#pragma mark - User Defaults

- (void)updateUserDefaultsWithResponseObject:(NSDictionary *)responseObject {
    NSDictionary *socialLinksDict = responseObject[@"user"][@"social_links"];
    
    if (socialLinksDict[@"facebook"] != [NSNull null]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:facebookConnected];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];
    }
    
    if (socialLinksDict[@"twitter"] != [NSNull null]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:twitterConnected];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];
    }
    
    if (responseObject[@"twitter_handle"] != [NSNull null]) {
        [[NSUserDefaults standardUserDefaults] setValue:responseObject[@"twitter_handle"] forKey:twitterHandle];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:twitterHandle];
    }
}


@end
