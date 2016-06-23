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
#import "FRSFileUploadManager.h" // temp patch
#import "FRSRequestSerializer.h"
#import "FRSAppDelegate.h"

@implementation FRSAPIClient

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
            
        case 2:
            // prolly not an error
            break;
            
        default:
            break;
    }
}

-(void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion {
    NSDictionary *params;
    
    if ([self currentInstallation]) {
        params = @{@"username":user, @"password":password, @"installation":[self currentInstallation]};
    }
    else {
        params = @{@"username":user, @"password":password};

    }
    
    [self post:loginEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        if (!error) {
            [self handleUserLogin:responseObject];
        }
        else {
            NSLog(@"LOGIN ERROR: %@", error);
        }
        
    }];
}

/*
    Sign in: all expect user to have an account, either returns a token, a challenge (i.e. 'create an account') or incorrect details
 */
-(void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *twitterAccessToken = session.authToken;
    NSString *twitterAccessTokenSecret = session.authTokenSecret;
    NSDictionary *authDictionary;
    
    if ([self currentInstallation]) {
       authDictionary = @{@"platform" : @"twitter", @"token" : twitterAccessToken, @"secret" : twitterAccessTokenSecret, @"installation":[self currentInstallation]};
    }
    else {
        authDictionary = @{@"platform" : @"twitter", @"token" : twitterAccessToken, @"secret" : twitterAccessTokenSecret};
    }
    
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
    NSDictionary *authDictionary;
    
    if ([self currentInstallation]) {
        authDictionary = @{@"platform" : @"facebook", @"token" : facebookAccessToken, @"installation":[self currentInstallation]};
    }
    else {
        authDictionary = @{@"platform" : @"facebook", @"token" : facebookAccessToken};
    }

    [self post:socialLoginEndpoint withParameters:authDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error); // burden of error handling falls on sender
        
        // handle internal cacheing of authentication
        if (!error) {
            [self handleUserLogin:responseObject];
        }
    }];
}

-(void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    // email
    // username
    // password
    // twitter_handle
    // social_links
    // installation
    
    
    [self post:signUpEndpoint withParameters:digestion completion:^(id responseObject, NSError *error) {
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
    NSString *checkEndpoint = [userEndpoint stringByAppendingString:check];
    
    [self get:checkEndpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
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
    }];
    
}

-(FRSUser *)authenticatedUser {
    
    // predicate searching for users in store w/ loggedIn as TRUE/1
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isLoggedIn", @(TRUE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUser"];
    signedInRequest.predicate = signedInPredicate;
    
    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [FRSFileUploadManager uploaderContext]; // temp (replace with internal or above method
    
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
    
    return [authenticatedUsers firstObject];
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
        }
    }
    
    if (facebookToken) {
        // add facebook to digestion
        if (facebookToken.tokenString) {
            NSDictionary *facebookDigestion = @{@"token":facebookToken.tokenString};
            [socialDigestion setObject:facebookDigestion forKey:@"facebook"];
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
         // no installation without push info, apparently
        return Nil;
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
    }];
}

-(void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:userFeed, user.uid];
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
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
                NSLog(@"Sent Location");
            }
            else {
                NSLog(@"Location Error: %@", error);
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

-(void)fetchGalleriesInStory:(NSString *)storyID completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
    NSString *endpoint = [storyGalleriesEndpoint stringByAppendingString:storyID];
    
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

-(void)startLocator {
    [FRSLocator sharedLocator];
}

-(void)updateUserLocation:(NSDictionary *)inputParams completion:(void(^)(NSDictionary *response, NSError *error))completion
{
    if (![self isAuthenticated]) {
        return;
    }
    
    [self post:@"user/locate" withParameters:inputParams completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
        
}

-(void)fetchFollowing:(void(^)(NSArray *galleries, NSError *error))completion {
    FRSUser *authenticatedUser = [self authenticatedUser];
    NSString *endpoint = [NSString stringWithFormat:followingFeed, authenticatedUser.uid];
    
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:galleryUnlikeEndpoint, gallery.uid];
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [gallery setValue:@(TRUE) forKey:@"liked"];
    }];
}
-(void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:storyUnlikeEndpoint, story.uid];
    [self get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
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
    
    NSArray *posts = [gallery.posts allObjects];
    NSMutableDictionary *galleryDigest = [[NSMutableDictionary alloc] init];
    NSMutableArray *postsToSend = [[NSMutableArray alloc] init];

    for (FRSPost *post in posts) {
        NSMutableDictionary *currentPost = [[NSMutableDictionary alloc] init];
        currentPost[@"address"] = (post.address) ? post.address : @"";
        currentPost[@"lat"] = @(post.location.coordinate.latitude);
        currentPost[@"lng"] = @(post.location.coordinate.longitude);
        currentPost[@"contentType"] = (post.contentType) ? post.contentType : @"image/jpeg";
        
        if (post.videoUrl) {
            currentPost[@"fileSize"] = [self fileSizeForURL:[NSURL fileURLWithPath:post.videoUrl]];
            currentPost[@"chunkSize"] = @(5242880); // 5mb in bytes
        }
        
        [postsToSend addObject:currentPost];
    }
    
    galleryDigest[@"caption"] = (gallery.caption) ? gallery.caption : @"";
    galleryDigest[@"posts"] = posts;
    
    [self post:createGalleryEndpoint withParameters:galleryDigest completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
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
    
    NSArray *allAccounts = [SSKeychain accountsForService:serviceName];
    
    if ([allAccounts count] == 0) {
        return Nil;
    }
    
    NSDictionary *credentialsDictionary = [allAccounts firstObject];
    NSString *accountName = credentialsDictionary[kSSKeychainAccountKey];
    
    return [SSKeychain passwordForService:serviceName account:accountName];
}

-(void)saveToken:(NSString *)token forUser:(NSString *)userName {
    [SSKeychain setPasswordData:[token dataUsingEncoding:NSUTF8StringEncoding] forService:serviceName account:userName];
}

-(NSString *)tokenForUser:(NSString *)userName {
    return [SSKeychain passwordForService:serviceName account:userName];
}

-(BOOL)isAuthenticated {
    if ([[SSKeychain accountsForService:serviceName] count] > 0) {
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
    NSString *endpoint = [NSString stringWithFormat:likeGalleryEndpoint, gallery.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [gallery setValue:@(TRUE) forKey:@"liked"];
    }];
}
-(void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likeStoryEndpoint, story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        [story setValue:@(TRUE) forKey:@"liked"];
    }];
}


-(void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[gallery valueForKey:@"reposted"] boolValue]) {
        [self unrepostGallery:gallery completion:completion];
    }

    NSString *endpoint = [NSString stringWithFormat:repostGalleryEndpoint, gallery.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        if (!error) {
            [gallery setValue:@(TRUE) forKey:@"reposted"];
            [[self managedObjectContext] save:Nil];
        }
    }];
}
-(void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    
    if ([[story valueForKey:@"reposted"] boolValue]) {
        [self unrepostStory:story completion:completion];
    }
    
    NSString *endpoint = [NSString stringWithFormat:repostStoryEndpoint, story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        if (!error) {
            [story setValue:@(TRUE) forKey:@"reposted"];
        }
        
        [[self managedObjectContext] save:Nil];
    }];
}

-(void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:[@"un" stringByAppendingString:repostGalleryEndpoint], gallery.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);

        if (!error) {
            [gallery setValue:@(FALSE) forKey:@"reposted"];
        }
        
        [[self managedObjectContext] save:Nil];
    }];
}

-(void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:[@"un" stringByAppendingString:repostStoryEndpoint], story.uid];
    [self post:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        if (!error) {
            [story setValue:@(FALSE) forKey:@"reposted"];
        }
        
        [[self managedObjectContext] save:Nil];
    }];

}

-(void)followUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    [self followUserID:user.uid completion:completion];
}
-(void)unfollowUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    [self unfollowUserID:user.uid completion:completion];
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

-(void)addComment:(NSString *)comment toGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    [self addComment:comment toGalleryID:gallery.uid completion:completion];
}

-(void)addComment:(NSString *)comment toGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
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
    
    if (![dictionary respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        return dictionary;
    }
    
    if ([dictionary isEqual:[NSNull null]]) {
        return dictionary;
    }
    
    
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


@end
