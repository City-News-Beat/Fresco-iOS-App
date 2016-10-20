//
//  FRSAPIClient.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h"
#import "Fresco.h"
#import "FRSPost.h"
#import "FRSRequestSerializer.h"
#import "FRSAppDelegate.h"
#import "FRSOnboardingViewController.h"
#import "FRSTracker.h"
#import "FRSTabBarController.h"
#import "FRSAppDelegate.h"

@implementation FRSAPIClient
@synthesize socialUsed = _socialUsed, passwordUsed = _passwordUsed, emailUsed = _emailUsed, authenticatedUser = _authenticatedUser;
/*
 Singleton
 */

+(instancetype)sharedClient {
    static FRSAPIClient *client = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        client = [[FRSAPIClient alloc] init];
    });
    
    return client;
}

-(id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLocationUpdate:)
                                                     name:FRSLocationUpdateNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)setPasswordUsed:(NSString *)passwordUsed {
    _passwordUsed = passwordUsed;
}

-(void)setEmailUsed:(NSString *)emailUsed {
    _emailUsed = emailUsed;
}

-(void)updateLegacyUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *mutableDigestion = [digestion mutableCopy];
    
    if (self.passwordUsed) {
        [mutableDigestion setObject:self.passwordUsed forKey:@"verify_password"];
    }
    else if (self.socialUsed && !self.passwordUsed) {
        [mutableDigestion addEntriesFromDictionary:self.socialUsed];
    }
    
    NSLog(@"DIGESTION: %@", mutableDigestion);
    
    [self updateUserWithDigestion:mutableDigestion completion:completion];
}

-(NSString *)passwordUsed {
    return _passwordUsed;
}

-(NSString *)emailUsed {
    return _emailUsed;
}

-(NSDictionary *)socialUsed {
    return _socialUsed;
}

-(void)setSocialUsed:(NSDictionary *)socialUsed {
    NSLog(@"SOCIAL USED: %@", socialUsed);
    
    _socialUsed = socialUsed;
}

-(void)handleError:(NSError *)error {
    switch (error.code/100) {
        case 5:
            // server error
            break;
        case 4:
            // client error
            switch (error.code) {
                case 401:
                    
                    break;
                case 403:
                    
                    break;
                case 404:
                    
                    break;
                case 405:
                    
                    break;
                default:
                    break;
            }
            break;
        
        case 3:
            // redirection
            break;
            
            //test
        case 2:
            // prolly not an error
            break;
            
        default:
            break;
    }
}

-(void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion {
    self.passwordUsed = password;
    
    [self post:loginEndpoint withParameters:@{@"username":user, @"password":password, @"installation":[[FRSAPIClient sharedClient] currentInstallation]} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        if (!error) {
            [self handleUserLogin:responseObject];
        }
    }];
}

/*
    Sign in: all expect user to have an account, either returns a token, a challenge (i.e. 'create an account') or incorrect details
 */
-(void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *twitterAccessToken = session.authToken;
    NSString *twitterAccessTokenSecret = session.authTokenSecret;
    NSDictionary *authDictionary = @{@"platform" : @"twitter", @"token" : twitterAccessToken, @"secret" : twitterAccessTokenSecret};
    self.socialUsed = authDictionary;
    
    [self post:socialLoginEndpoint withParameters:authDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        // handle cacheing of authentication
        if (!error) {
            [self handleUserLogin:responseObject];
        }
        
        
    }];
}

-(void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *facebookAccessToken = token.tokenString;
    NSDictionary *authDictionary = @{@"platform" : @"facebook", @"token" : facebookAccessToken};
    self.socialUsed = authDictionary;
    
    [self post:socialLoginEndpoint withParameters:authDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error); // burden of error handling falls on sender
        
        // handle internal cacheing of authentication
        if (!error) {
            [self handleUserLogin:responseObject];
        }
        
        NSLog(@"FACEBOOK SIGN IN: %@", error);

    }];
}

-(void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    // email
    // username
    // password
    // twitter_handle
    // social_links
    // installation
    
    if (digestion[@"password"]) {
        self.passwordUsed = digestion[@"password"];
    }
    else {
        self.socialUsed = digestion[@"social_links"];
    }
    
    [self post:signUpEndpoint withParameters:digestion completion:^(id responseObject, NSError *error) {
        
        if ([responseObject objectForKey:@"token"] && ![responseObject objectForKey:@"err"]) {
            [self saveToken:[responseObject objectForKey:@"token"] forUser:clientAuthorization];
            NSString *userID = responseObject[@"user"][@"id"];
            
        }
        
        completion(responseObject, error);
    }];
}

-(void)linkTwitter:(NSString *)token secret:(NSString *)secret completion:(FRSAPIDefaultCompletionBlock)completion {
    if (token && secret) {
        [self post:addSocialEndpoint withParameters:@{@"platform":@"twitter", @"token":token, @"secret":secret} completion:^(id responseObject, NSError *error) {
            completion(responseObject, error);
        }];
    }
    else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:@{@"message":@"Incorrect Twitter credentials"}]);
    }
}

-(void)linkFacebook:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    if (token) {
        [self post:addSocialEndpoint withParameters:@{@"platform":@"facebook", @"token":token} completion:^(id responseObject, NSError *error) {
            completion(responseObject, error);
        }];
    }
    else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:@{@"message":@"Incorrect Twitter credentials"}]);
    }
}

-(void)unlinkFacebook:(FRSAPIDefaultCompletionBlock)completion {
    [self post:deleteSocialEndpoint withParameters:@{@"platform":@"facebook"} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)unlinkTwitter:(FRSAPIDefaultCompletionBlock)completion {
    [self post:deleteSocialEndpoint withParameters:@{@"platform":@"twitter"} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)checkEmail:(NSString *)email completion:(FRSAPIDefaultCompletionBlock)completion {
    [self check:email completion:completion];
}
-(void)checkUsername:(NSString *)username completion:(FRSAPIDefaultCompletionBlock)completion {
    [self check:username completion:completion];
}

-(void)check:(NSString *)check completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *checkEndpoint = [userEndpoint stringByAppendingString:[check stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    [self get:checkEndpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)getNotificationsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    
    [self get:notificationEndpoint withParameters:@{} completion:^(id responseObject, NSError *error) {
        
//        NSArray *feed = [responseObject objectForKey:@"feed"];
//        NSMutableArray *notificationIDs = [[NSMutableArray alloc] init];
//        
        completion(responseObject, error);

//        for (int i=0; i<feed.count; i++) {
//            [notificationIDs addObject:[[[responseObject objectForKey:@"feed"] objectAtIndex:i] objectForKey:@"id"]];
//        }
//        [self post:@"user/notifications/see" withParameters:@{@"notification_ids": notificationIDs} completion:^(id responseObject, NSError *error) {
//        }];
    }];
}

-(void)getNotificationsWithLast:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion {
    if (!last) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:Nil]);
    }
    
    [self get:notificationEndpoint withParameters:@{@"last":last} completion:^(id responseObject, NSError *error) {
        
        //        NSArray *feed = [responseObject objectForKey:@"feed"];
        //        NSMutableArray *notificationIDs = [[NSMutableArray alloc] init];
        //
        completion(responseObject, error);
        
        //        for (int i=0; i<feed.count; i++) {
        //            [notificationIDs addObject:[[[responseObject objectForKey:@"feed"] objectAtIndex:i] objectForKey:@"id"]];
        //        }
        //        [self post:@"user/notifications/see" withParameters:@{@"notification_ids": notificationIDs} completion:^(id responseObject, NSError *error) {
        //        }];
    }];

}

-(void)updateUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    
    // ** WARNING ** Don't update users info just to update it, update it only if new (i.e. changing email to identical email has resulted in issues with api v1)
    // full_name: User's full name
    // bio: User's profile bio
    // avatar: User's avatar URL
    // installation
    // social links
    
    [self post:updateUserEndpoint withParameters:digestion completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        NSLog(@"DIGESTION: %@", digestion);
        NSLog(@"RESPONSE: %@", responseObject);
        NSLog(@"ERROR: %@", error);
    }];
}

-(void)updateIdentityWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:@"user/identity/update" withParameters:digestion completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        NSLog(@"DIGESTION: %@", digestion);
        NSLog(@"RESPONSE: %@", responseObject);
        NSLog(@"ERROR: %@", error);
    }];
}

-(void)updateSettingsWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:settingsUpdateEndpoint withParameters:digestion completion:completion];
}

-(void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:disableAccountEndpoint withParameters:digestion completion:completion];
}

-(FRSUser *)authenticatedUser {
    
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


// all the info needed for "social_links" field of registration/signin
-(NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken {
    // side note, twitter_handle is outside social links, needs to be handled outside this method
    NSMutableDictionary *socialDigestion = [[NSMutableDictionary alloc] init];
    
    if (twitterSession) {
        // add twitter to digestion
        if (twitterSession.authToken && twitterSession.authTokenSecret) {
            NSDictionary *twitterDigestion = @{@"token":twitterSession.authToken, @"secret": twitterSession.authTokenSecret};
            [socialDigestion setObject:twitterDigestion forKey:@"twitter"];
            [FRSTracker track:@"Signups with Twitter"];
        }
    }
    
    if (facebookToken) {
        // add facebook to digestion
        if (facebookToken.tokenString) {
            NSDictionary *facebookDigestion = @{@"token":facebookToken.tokenString};
            [socialDigestion setObject:facebookDigestion forKey:@"facebook"];
            [FRSTracker track:@"Signups with Facebook"];
        }
    }
    
    return socialDigestion;
}


// all info needed for "installation" field of registration/signin
-(NSDictionary *)currentInstallation {
    
    NSMutableDictionary *currentInstallation = [[NSMutableDictionary alloc] init];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
    
    if (deviceToken != Nil || [deviceToken isEqual:[NSNull null]]) {
        currentInstallation[@"device_token"] = deviceToken;
    }
    else {
        
        currentInstallation[@"device_token"] = [[FRSAPIClient sharedClient] random64CharacterString]; // no installation without push info, apparently
    }
    
    NSString *sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"SESSION_ID"];
    
    if (sessionID) {
        currentInstallation[@"device_id"] = sessionID;
    }
    else {
        sessionID = [self randomString];
        currentInstallation[@"device_id"] = sessionID;
        [[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:@"SESSION_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    currentInstallation[@"platform"] = @"ios";
    
    NSString *appVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    if (appVersion) {
        currentInstallation[@"app_version"] = appVersion;
    }

    
    /*
     If we ever choose to move towards a UTC+X approach in timezones, as opposed to the unix timestamp that includes the current timezone, this is how we would do it.
     
    NSInteger secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSInteger hoursFromGMT = secondsFromGMT / 60; // GMT = UTC
    NSString *timeZone = [NSString stringWithFormat:@"UTC+%d", (int)hoursFromGMT]; 
    */
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSString *timeZone = [dateFormat stringFromDate:[NSDate date]];
    
    if (timeZone) {
        currentInstallation[@"timezone"] = timeZone;
    }
    
    NSString *localeString = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    
    if (localeString) {
        currentInstallation[@"locale_identifier"] = localeString;
    }

    
    return currentInstallation;
}


-(NSString *)randomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:15];
    
    for (int i=0; i<15; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(NSString *)random64CharacterString {
    NSString *letters = @"abcdefABCDEF0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:64];
    
    for (int i=0; i<64; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)handleUserLogin:(id)responseObject {
    if ([responseObject objectForKey:@"token"] && ![responseObject objectForKey:@"err"]) {
        [self saveToken:[responseObject objectForKey:@"token"] forUser:clientAuthorization];
    }
    
    [self reevaluateAuthorization];
    [self updateLocalUser];
}

-(void)updateLocalUser {
    if (![self isAuthenticated]) {
        return;
    }
    
    [self get:authenticatedUserEndpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        if (error) {
            return;
        }
        
        // set up FRSUser object with this info, set authenticated to true
        
        NSString *userID = responseObject[@"id"];
        NSString *email = responseObject[@"email"];
        NSString *name = responseObject[@"full_name"];
        
        if (userID != Nil && ![userID isEqual:[NSNull null]]) {
            [[Mixpanel sharedInstance] registerSuperProperties:@{@"fresco_id": userID}];
        }
        if (email != Nil && ![email isEqual:[NSNull null]]) {
            [[Mixpanel sharedInstance] registerSuperProperties:@{@"email": email}];
        }
        if (name != Nil && ![name isEqual:[NSNull null]]) {
            [[Mixpanel sharedInstance] registerSuperProperties:@{@"name": name}];
        }
        if (userID && ![userID isEqual:[NSNull null]]) {
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel createAlias:userID forDistinctID:mixpanel.distinctId];
            [mixpanel identify:userID];
        }
        
        [FRSTracker track:@"Logins"];
    }];
}

-(void)disconnectPlatform:(NSString *)platform completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:deleteSocialEndpoint withParameters:@{@"platform":platform} completion:completion];
}

-(void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:userFeed, user.uid];
    NSLog(@"%@", endpoint);
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
       
        NSLog(@"ERROR: %@", error);

    }];
}

-(void)pingLocation:(NSDictionary *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    if (![self isAuthenticated]) {
        return;
    }
    
    [self post:locationEndpoint withParameters:location completion:^(id responseObject, NSError *error) {
        
    }];
}

-(void)handleLocationUpdate:(NSNotification *)userInfo {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUserLocation:userInfo.userInfo completion:^(NSDictionary *response, NSError *error) {
            if (!error) {
               // NSLog(@"Sent Location");
            }
            else {
                NSLog(@"Location Error: %@ %@", response, error);
            }
        }];
    });
}

/*
 
 Fetch assignments w/in radius of user location, calls generic method w/ parameters & endpoint
 
 */

-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion{
    
    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"Point" forKey:@"type"];
    [geoData setObject:location forKey:@"coordinates"];
    
    NSDictionary *params = @{
                             @"geo" : geoData,
                             @"radius" : @(radius),
                            };
    
    NSLog(@"PARAMS: %@", params);
    
    [self get:assignmentsEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
    
}

-(void)showErrorWithMessage:(NSString *)message onCancel:(FRSAPIBooleanCompletionBlock)onCancel onRetry:(FRSAPIBooleanCompletionBlock)onRetry {
    
}

-(void)getAssignmentsWithinRadius:(float)radius ofLocations:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"MultiPoint" forKey:@"type"];

    
    NSMutableDictionary *coordinates = [[NSMutableDictionary alloc] init];
    
    int counter = 0;
    for (CLLocation *loc in location) {
        NSArray *coordinateLocation = @[@(loc.coordinate.longitude), @(loc.coordinate.latitude)];
        [coordinates setObject:coordinateLocation forKey:[NSNumber numberWithInt:counter]];
        counter++;
    }
    
    [geoData setObject:coordinates forKey:@"coordinates"];
    
    NSDictionary *params = @{
                             @"geo" : geoData,
                             @"radius" : @(radius)
                            };
    

    [self get:assignmentsEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];

}

#pragma mark - Gallery Fetch

/*
 
 Fetch galleries w/ limit, calls generic method w/ parameters & endpoint
 
 */

-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
    NSDictionary *params = @{
                        @"limit" : [NSNumber numberWithInteger:limit],
                        @"last" : (offset != Nil) ? offset : @"",
                    };
    
    if (!offset) {
        params = @{
                   @"limit" : [NSNumber numberWithInteger:limit],
                   };
    }
    
    [self get:highlightsEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)deleteComment:(NSString *)commentID fromGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:deleteCommentEndpoint, gallery.uid];
    NSDictionary *params = @{@"comment_id":commentID};
    
    [self post:endpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)fetchGalleriesInStory:(NSString *)storyID completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
    NSString *endpoint = [NSString stringWithFormat:storyGalleriesEndpoint, storyID];
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {        
        completion(responseObject, error);
    }];
}

-(void)getRecentGalleriesFromLastGalleryID:(NSString *)galleryID completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
}

-(void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void(^)(NSArray *stories, NSError *error))completion {
    
    NSDictionary *params = @{
                             @"limit" : [NSNumber numberWithInteger:limit],
                             @"last" : (offsetID != Nil) ? offsetID : @""
                            };
    
    if (!offsetID) {
        params = @{
                    @"limit" : [NSNumber numberWithInteger:limit],
                  };
    }
    
    [self get:storiesEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)createPaymentWithToken:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {

    if (!token) {
        completion(Nil, Nil);
    }
    
    [self post:createPayment withParameters:@{@"token":token, @"active":@(TRUE)} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)startLocator {
    [FRSLocator sharedLocator];
}

-(void)updateUserLocation:(NSDictionary *)inputParams completion:(void(^)(NSDictionary *response, NSError *error))completion
{
    if (![self isAuthenticated]) {
        return;
    }
    
    [self post:locationEndpoint withParameters:inputParams completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
        
}

-(void)fetchFollowing:(void(^)(NSArray *galleries, NSError *error))completion {
    FRSUser *authenticatedUser = [self authenticatedUser];
    
    if (!authenticatedUser) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.fresco" code:404 userInfo:@{@"error":@"no user u dingus"}]);
    }
    
    NSString *endpoint = [NSString stringWithFormat:followingFeed, authenticatedUser.uid];
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)fetchLikesFeedForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likeFeed, user.uid];
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:galleryUnlikeEndpoint, gallery.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [gallery setValue:@(TRUE) forKey:@"liked"];
    }];
}
-(void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:storyUnlikeEndpoint, story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [story setValue:@(FALSE) forKey:@"liked"];
    }];
}


-(AFHTTPRequestOperationManager *)managerWithFrescoConfigurations {
    
    if (!self.requestManager) {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        self.requestManager = manager;
        self.requestManager.requestSerializer = [[FRSRequestSerializer alloc] init];
        [self.requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        self.requestManager.responseSerializer = [[FRSJSONResponseSerializer alloc] init];
    }
    
    [self reevaluateAuthorization];
    
    return self.requestManager;
}

-(void)createGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSDictionary *params = [gallery jsonObject];
    NSLog(@"CREATION: %@", params);
    
    [self post:createGalleryEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        NSLog(@"CREATION ERROR: %@", error);
    }];
}

-(void)addTwitter:(TWTRSession *)twitterSession completion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *twitterDictionary = [[NSMutableDictionary alloc] init];
    [twitterDictionary setObject:@"Twitter" forKey:@"platform"];
    
    if (twitterSession.authToken && twitterSession.authTokenSecret) {
        [twitterDictionary setObject:twitterSession.authToken forKey:@"token"];
        [twitterDictionary setObject:twitterSession.authTokenSecret forKey:@"secret"];
    }
    else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:401 userInfo:Nil]);
        return;
    }
    
    [self post:addSocialEndpoint withParameters:twitterDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)getFollowersForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followersEndpoint, user.uid];
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}
-(void)addFacebook:(FBSDKAccessToken *)facebookToken completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *tokenString = facebookToken.tokenString;
    
    if (!tokenString) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:401 userInfo:Nil]);
        return;
    }
    
    NSDictionary *facebookDictionary = @{@"platform":@"Facebook", @"token":tokenString};
    
    [self post:addSocialEndpoint withParameters:facebookDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

/*
    Keychain-Based interaction & authentication
 */

// user/me
-(void)refreshCurrentUser:(FRSAPIDefaultCompletionBlock)completion {
    
    if (![self isAuthenticated]) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.fresco" code:404 userInfo:Nil]); // no authenticated user, 404
        return;
    }
    
    [self reevaluateAuthorization]; // specific check on bearer
    
    // authenticated request to user/me (essentially user/ozetadev w/ more fields)
    [self get:authenticatedUserEndpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)reevaluateAuthorization {
    if (![self isAuthenticated]) {
        // set client token
        [self.requestManager.requestSerializer setValue:[self clientAuthorization] forHTTPHeaderField:@"Authorization"];
    }
    else { // set bearer token if we haven't already
        // set bearer client token
        NSString *currentBearerToken = [self authenticationToken];
        if (currentBearerToken) {
            currentBearerToken = [NSString stringWithFormat:@"Bearer %@", currentBearerToken];
            
            [self.requestManager.requestSerializer setValue:currentBearerToken forHTTPHeaderField:@"Authorization"];
            [self startLocator];
        }
        else { // something went wrong here (maybe pass to error handler)
            [self.requestManager.requestSerializer setValue:[self clientAuthorization] forHTTPHeaderField:@"Authorization"];
        }
    }
    _managerAuthenticated = TRUE;
}

-(NSString *)authenticationToken {
    
    NSArray *allAccounts = [SAMKeychain accountsForService:serviceName];
    
    if ([allAccounts count] == 0) {
        return Nil;
    }
    
    
    NSDictionary *credentialsDictionary = [allAccounts firstObject];
    NSString *accountName = credentialsDictionary[kSAMKeychainAccountKey];
    
    return [SAMKeychain passwordForService:serviceName account:accountName];
}

-(void)logout {
    NSArray *allAccounts = [SAMKeychain allAccounts];
    
    for (NSDictionary *account in allAccounts) {
        NSString *accountName = account[kSAMKeychainAccountKey];
        [SAMKeychain deletePasswordForService:serviceName account:accountName];
    }

}

-(void)saveToken:(NSString *)token forUser:(NSString *)userName {
    [SAMKeychain setPasswordData:[token dataUsingEncoding:NSUTF8StringEncoding] forService:serviceName account:userName];
}

-(NSString *)tokenForUser:(NSString *)userName {
    return [SAMKeychain passwordForService:serviceName account:userName];
}

-(BOOL)isAuthenticated {
    
    if ([[SAMKeychain allAccounts] count]) {
        return TRUE;
    }
    
    return FALSE;
}

-(NSString *)clientAuthorization {
    return [NSString stringWithFormat:@"Basic %@", clientAuthorization];
}

/*
    Generic HTTP methods for use within class
 */
-(void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager GET:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject, Nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(Nil, error);
        [self handleError:error];
    }];
}

-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion
{
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager POST:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        completion(responseObject, Nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(Nil, error);
        [self handleError:error];
    }];
}

-(void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion
{
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];

    [manager POST:endPoint parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSString *paramNameForImage = @"avatar";
        [formData appendPartWithFileData:parameters[@"avatar"] name:paramNameForImage fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject, Nil);
         
     } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
         completion(Nil, error);
         [self handleError:error];
     }];
}

/*
    One-off tools for use within class
 */

-(NSNumber *)fileSizeForURL:(NSURL *)url {
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [url getResourceValue:&fileSizeValue
                   forKey:NSURLFileSizeKey
                    error:&fileSizeError];
    
    return fileSizeValue;
}

-(void)checkUser:(NSString *)user completion:(FRSAPIBooleanCompletionBlock)completion {
    
    NSString *endpoint = [NSString stringWithFormat:@"user/%@", user];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        if (error) {
            completion(TRUE, error);
            return;
        }
        
        if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
            completion(FALSE, error);
        }
        
        // shouldn't happen
        completion(TRUE, error);
    }];
}

-(void)getUserWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSString *endpoint = [NSString stringWithFormat:@"user/%@", user];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
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

-(void)getPostWithID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSString *endpoint = [NSString stringWithFormat:@"post/%@", post];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        
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

-(void)getOutletWithID:(NSString *)outlet completion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSString *endpoint = [NSString stringWithFormat:@"outlet/%@", outlet];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        
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

-(void)getStoryWithUID:(NSString *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSString *endpoint = [NSString stringWithFormat:@"story/%@", story];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
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

-(void)getGalleryWithUID:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    
    
    NSString *endpoint = [NSString stringWithFormat:@"gallery/%@", gallery];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        if (error) {
            completion(responseObject, error);
            return;
        }
        
        NSLog(@"responseObject: %@", responseObject);
        
//        if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
//            completion(responseObject, error);
//        }
        
        // shouldn't happen
        completion(responseObject, error);
    }];
}


-(void)getAssignmentWithUID:(NSString *)assignment completion:(FRSAPIDefaultCompletionBlock)completion {
    
    NSString *endpoint = [NSString stringWithFormat:@"assignment/%@", assignment];
    
    [self get:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
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

-(void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    
    [self post:acceptAssignmentEndpoint withParameters:@{@"assignment_id":assignmentID} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(NSDate *)dateFromString:(NSString *)string {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    }
    
    return [self.dateFormatter dateFromString:string];
}

/* 
    Social interaction
*/
-(void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:likeGalleryEndpoint, gallery.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [gallery setValue:@(TRUE) forKey:@"liked"];
        [[self managedObjectContext] save:Nil];
    }];
}

-(void)searchWithQuery:(NSString *)query completion:(FRSAPIDefaultCompletionBlock)completion {
    if (!query) {
        // error out
        
        return;
    }
    
    NSDictionary *params = @{@"q":query, @"stories":@(TRUE), @"galleries":@(TRUE), @"users":@(TRUE), @"limit":@999};
    
    [self get:searchEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject,error);
    }];
}
-(void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:likeStoryEndpoint, story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [story setValue:@(TRUE) forKey:@"liked"];
        [[self managedObjectContext] save:Nil];
    }];
}


-(void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }
    
    
    if ([[gallery valueForKey:@"reposted"] boolValue]) {
        [self unrepostGallery:gallery completion:completion];
        return;
    }


    NSString *endpoint = [NSString stringWithFormat:repostGalleryEndpoint, gallery.uid];
    
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        [gallery setValue:@(TRUE) forKey:@"reposted"];
        [[self managedObjectContext] save:Nil];
    }];
}
-(void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }
    
    if ([[story valueForKey:@"reposted"] boolValue]) {
        [self unrepostStory:story completion:completion];
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:repostStoryEndpoint, story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        [story setValue:@(TRUE) forKey:@"reposted"];
        [[self managedObjectContext] save:Nil];
    }];
}

-(void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostGalleryEndpoint, gallery.uid];

    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);

        [gallery setValue:@(FALSE) forKey:@"reposted"];
        
        [[self managedObjectContext] save:Nil];
    }];
}

-(void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostStoryEndpoint, story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        [story setValue:@(FALSE) forKey:@"reposted"];
        
        [[self managedObjectContext] save:Nil];
    }];

}

-(void)followUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }
    
    if ([user valueForKey:@"following"] && [[user valueForKey:@"following"] boolValue] == TRUE) {
        [self unfollowUser:user completion:^(id responseObject, NSError *error) {
            completion(responseObject, error);
        }];
        return;
    }
    
    [self followUserID:user.uid completion:^(id responseObject, NSError *error) {
        [user setValue:@(TRUE) forKey:@"following"];
        [[self managedObjectContext] save:Nil];
        completion(responseObject, error);
    }];
}
-(void)unfollowUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.news" code:101 userInfo:Nil]);
        return;
    }
    
    [self unfollowUserID:user.uid completion:^(id responseObject, NSError *error) {
        [user setValue:@(FALSE) forKey:@"following"];
        [[self managedObjectContext] save:Nil];
        completion(responseObject, error);
    }];
}

-(void)getFollowingForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followingEndpoint, user.uid];
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)followUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followUserEndpoint, userID];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}
-(void)unfollowUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unfollowUserEndpoint, userID];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)fetchCommentsForGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    [self fetchCommentsForGalleryID:gallery.uid completion:completion];
}
-(void)fetchCommentsForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:commentsEndpoint, galleryID];
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)fetchMoreComments:(FRSGallery *)gallery last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:paginateComments, gallery.uid, last];
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)addComment:(NSString *)comment toGallery:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
//    if ([self checkAuthAndPresentOnboard]) {
//        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
//        return;
//    }
    
    [self addComment:comment toGalleryID:gallery completion:completion];
}

-(void)addComment:(NSString *)comment toGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
   
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:commentEndpoint, galleryID];
    NSDictionary *parameters = @{@"comment":comment};
    
    [self post:endpoint withParameters:parameters completion:completion];
}

/* serialization */

-(id)parsedObjectsFromAPIResponse:(id)response cache:(BOOL)cache {
    
    if ([[response class] isSubclassOfClass:[NSDictionary class]]) {
        NSManagedObjectContext *managedObjectContext = (cache) ? [self managedObjectContext] : Nil;
        NSMutableDictionary *responseObjects = [[NSMutableDictionary alloc] init];
        NSArray *keys = [response allKeys];
        
        for (NSString *key in keys) {
            id valueForKey = [self objectFromDictionary:[response objectForKey:key] context:managedObjectContext];
            
            if (valueForKey == [response objectForKey:key]) {
                return response; // non parse
            }
            
            [responseObjects setObject:valueForKey forKey:key];
        }
        
        if (cache) {
            NSError *saveError;
            [managedObjectContext save:&saveError];
        }
        
        return responseObjects;
    }
    else if ([[response class] isSubclassOfClass:[NSArray class]]) {
        NSMutableArray *responseObjects = [[NSMutableArray alloc] init];
        NSManagedObjectContext *managedObjectContext = (cache) ? [self managedObjectContext] : Nil;
        
        for (NSDictionary *responseObject in response) {
            id originalResponse = [self objectFromDictionary:responseObject context:managedObjectContext];
            
            if (originalResponse == responseObject) {
                return response;
            }
            
            [responseObjects addObject:[self objectFromDictionary:responseObject context:managedObjectContext]];
        }

        return responseObjects;
    }
    else {

    }
    
    return response;
}

-(id)objectFromDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)managedObjectContext {
    
    NSString *objectType = dictionary[@"object"];
    
    if ([objectType isEqualToString:galleryObjectType]) {
        NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSGallery" inManagedObjectContext:[self managedObjectContext]];
        
        FRSGallery *gallery = (FRSGallery *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
        gallery.currentContext = [self managedObjectContext];
        [gallery configureWithDictionary:dictionary];
        return gallery;
    }
    else if ([objectType isEqualToString:storyObjectType]) {
        NSEntityDescription *storyEntity = [NSEntityDescription entityForName:@"FRSStory" inManagedObjectContext:[self managedObjectContext]];
        FRSStory *story = (FRSStory *)[[NSManagedObject alloc] initWithEntity:storyEntity insertIntoManagedObjectContext:nil];
        [story configureWithDictionary:dictionary];
        return story;
    }
    
    return dictionary; // not serializable
}

-(NSManagedObjectContext *)managedObjectContext {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

-(BOOL)checkAuthAndPresentOnboard {
    
    if (![[FRSAPIClient sharedClient] isAuthenticated]) {
        
        id<FRSApp> appDelegate = (id<FRSApp>)[[UIApplication sharedApplication] delegate];
        FRSTabBarController *tabBar = (FRSTabBarController *) [appDelegate tabBar];
        FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
        UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
        
        if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
            [navController pushViewController:onboardVC animated:FALSE];
        }
        else {
            UITabBarController *tab = (UITabBarController *)navController;
            tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
            tab.navigationController.interactivePopGestureRecognizer.delegate = nil;
            UINavigationController *onboardNav = [[UINavigationController alloc] init];
            [onboardNav pushViewController:onboardVC animated:NO];
            [tab presentViewController:onboardNav animated:YES completion:Nil];
        }

        return TRUE;
    }
    
    if ([[FRSAPIClient sharedClient] authenticatedUser].suspended) {
        [self checkSuspended];
        return TRUE;
    }
    
    return FALSE;
}



/// not ideal
#pragma mark - Smooch
-(void)presentSmooch {
    FRSUser *currentUser = [[FRSAPIClient sharedClient] authenticatedUser];
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

-(void)checkSuspended {
    
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate reloadUser];
    
    if ([[FRSAPIClient sharedClient] authenticatedUser].suspended) {
        self.suspendedAlert = [[FRSAlertView alloc] initWithTitle:@"SUSPENDED" message: [NSString stringWithFormat:@"You’ve been suspended for inappropriate behavior. You will be unable to submit, repost, or comment on galleries for 14 days."] actionTitle:@"CONTACT SUPPORT" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.suspendedAlert show];
    }
}
-(void)didPressButtonAtIndex:(NSInteger)index {
    
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
/// not ideal



-(void)fetchAddressFromLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __block NSString *address;
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0) {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             
             address = [NSString stringWithFormat:@"%@, %@", [placemark locality], [placemark administrativeArea]];
             
             NSLog(@"Found address: %@",address);
             completion(address, Nil);
         }
         else {
             completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:404 userInfo:Nil]);
         }
         
     }];
}

// FILE DEALINGS
-(void)fetchFileSizeForVideo:(PHAsset *)video callback:(FRSAPISizeCompletionBlock)callback {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:video options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            
            NSNumber *size;
            NSError *fetchError;
            
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:&fetchError];
            callback([size integerValue], fetchError);
        }
    }];
}

-(void)fetchFileSizeForImage:(PHAsset *)image callback:(FRSAPISizeCompletionBlock)callback {
    [[PHImageManager defaultManager] requestImageDataForAsset:image options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        float imageSize = imageData.length;
        callback([@(imageSize) integerValue], Nil);
    }];
}

-(NSString *)md5:(PHAsset *)asset {
    return @"";
}

-(NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback {
    NSMutableDictionary *digest = [[NSMutableDictionary alloc] init];
    
    [self fetchAddressFromLocation:asset.location completion:^(id responseObject, NSError *error) {
        
        digest[@"address"] = responseObject;
        digest[@"lat"] = @(asset.location.coordinate.latitude);
        digest[@"lng"] = @(asset.location.coordinate.longitude);
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            digest[@"contentType"] = @"image/jpeg";
            [self fetchFileSizeForImage:asset callback:^(NSInteger size, NSError *err) {
                digest[@"fileSize"] = @(size);
                digest[@"chunkSize"] = @(size);
                callback(digest, err);
            }];
        }
        else {
            [self fetchFileSizeForVideo:asset callback:^(NSInteger size, NSError *err) {
                digest[@"fileSize"] = @(size);
                digest[@"chunkSize"] = @(chunkSize * megabyteDefinition);
                digest[@"contentType"] = @"video/mp4";                
                callback(digest, err);
            }];
        }
    }];
    
    return digest;
}

-(void)completePost:(NSString *)postID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    
    [self post:completePostEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)fetchPayments:(FRSAPIDefaultCompletionBlock)completion {
    [self get:getPaymentsEndpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)deletePayment:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:deletePaymentEndpoint, paymentID];
    
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)makePaymentActive:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:makePaymentActiveEndpoint, paymentID];
    
    [self post:endpoint withParameters:@{@"active":@(1)} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)getTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [self get:getTermsEndpoint withParameters:Nil completion:completion];
}
-(void)acceptTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:acceptTermsEndpoint withParameters:Nil completion:completion];
}

-(void)blockUser:(NSString*)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:blockUserEndpoint, userID];
    
    [self post:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)unblockUser:(NSString*)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unblockUserEndpoint, userID];
    
    [self post:endpoint withParameters:nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}
-(void)reportUser:(NSString *)userID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *format = @"user/%@/report";
    NSString *endpoint = [NSString stringWithFormat:format, userID];
    [self post:endpoint withParameters:params completion:completion];
}

-(void)reportGallery:(FRSGallery *)gallery params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *format = @"gallery/%@/report";
    NSString *endpoint = [NSString stringWithFormat:format, gallery.uid];
    [self post:endpoint withParameters:params completion:completion];
}

-(void)fetchBlockedUsers:(FRSAPIDefaultCompletionBlock)completion {
    [self get:@"user/blocked" withParameters:Nil completion:completion];
}

@end
