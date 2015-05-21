//
//  FRSDataManager.m
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <NSArray+F.h>
#import <Parse/Parse.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "FRSDataManager.h"
#import "NSFileManager+Additions.h"
#import "ASIFormDataRequest+Array.h"

#define kFrescoUserIdKey @"frescoUserId"

@interface FRSDataManager () {
    @protected
    FRSUser *_currentUser;
}

@property (nonatomic, strong) NSURLSessionTask *searchTask;

+ (NSURLSessionConfiguration *)frescoSessionConfiguration;

@end

@implementation FRSDataManager

#pragma mark - static methods

+ (FRSDataManager *)sharedManager
{
    static FRSDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FRSDataManager alloc] init];
    });
    return manager;
}

+ (NSURLSessionConfiguration *)frescoSessionConfiguration
{
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return configuration;
}

#pragma mark - object lifecycle

- (id)init
{
    NSURL *baseURL = [NSURL URLWithString:[VariableStore sharedInstance].baseURL];
    if (self = [super initWithBaseURL:baseURL sessionConfiguration:[[self class] frescoSessionConfiguration]]) {
        [[self responseSerializer] setAcceptableContentTypes:nil];
    }
    return self;
}


#pragma - User State

- (void)currentUserFromParseUser
{
    // make a blank user
    self.currentUser = [[FRSUser alloc] init];
    
    // user is logged into parse
    if ([PFUser currentUser]) {
        NSString *userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
        
        // but user isn't sync'd
        if (!userId || [userId length] == 0) {
            [[PFUser currentUser] fetch];
            userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
            
            // or doesn't exist at all make one asynchronously
            if (!userId || [userId length] == 0) {
                [self createFrescoUser:^(id responseObject, NSError *error) {
                    FRSUser *frsUser = responseObject;
                    _currentUser = frsUser;
                    
                    // send data back to Parse
                    [[PFUser currentUser] setObject:_currentUser.userID forKey:kFrescoUserIdKey];
                    [[PFUser currentUser] save];
                }];
            }
            // this is synchronous
            else
                self.currentUser.userID = userId;
        }
        else
            self.currentUser.userID = userId;
    }
}

- (void)setCurrentUser:(FRSUser *)currentUser
{
    if (currentUser)
        _currentUser = currentUser;
    // log out
    else {
        _currentUser = nil;
        [PFUser logOutInBackground];
    }
}

- (FRSUser *)currentUser
{
    // see if we can bootstrap the user from Parse
    if (!_currentUser)
       [self currentUserFromParseUser];

    return _currentUser;
}

- (void)logout
{
    [self setCurrentUser:nil];
}

- (void)createFrescoUser:(FRSAPIResponseBlock)responseBlock{
    NSString *randomEmail = [NSString stringWithFormat:@"jrgresh+fresco%8.f@gmail.com", [NSDate timeIntervalSinceReferenceDate]];
    NSDictionary *params = @{@"email" : randomEmail, @"password" : @"foobar"};
    
    [self POST:@"/user/create" parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           if (responseBlock) responseBlock(user, nil);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           if (responseBlock) responseBlock(nil, error);
       }];
}

#pragma mark - posts

-(void)getPostsWithId:(NSNumber*)postId responseBlock:(FRSAPIResponseBlock)responseBlock
{
    NSString *path = @"frs-query.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"getPost" forKey:@"type"];
    [params setObject:postId forKey:@"postId"];
   
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.fresconews.Fresco"]){
        [params setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"sourcesFilter"];
    
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        FRSPost *post = [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:responseObject error:NULL];
        
        if (responseBlock) responseBlock(post, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (responseBlock) responseBlock(nil, error);
    }];


}

- (void)getPostsWithTags:(NSArray *)tags limit:(NSNumber *)limit responseBlock:(FRSAPIArrayResponseBlock)responseBlock
{
    NSString *path = @"frs-query.php";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:limit forKey:@"limit"];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.fresconews.Fresco"])
        [params setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"sourcesFilter"];
    
    if ([tags count]) {
        [params setObject:@"getPostsWithTags" forKey:@"type"];
        NSArray *tagNames = [tags map:^NSString *(FRSTag * obj) {
            return [obj identifier];
        }];
        [params setObject:tagNames forKey:@"tags"];
    }
    else {
        [params setObject:@"getPosts" forKey:@"type"];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *posts = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:obj error:NULL];
        }];
        
        if (responseBlock) responseBlock(posts, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (responseBlock) responseBlock(nil, error);
    }];
}

- (void)getPostsWithTag:(FRSTag *)tag limit:(NSNumber *)limit responseBlock:(FRSAPIArrayResponseBlock)responseBlock
{
    NSArray *tags = tag ? @[tag] : nil;
    [self getPostsWithTags:tags limit:limit responseBlock:responseBlock];
}

- (void)getPostsAfterId:(NSNumber*)lastId responseBlock:(FRSAPIArrayResponseBlock)responseBlock{
    
    NSString *path = @"frs-query.php";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"getPosts" forKey:@"type"];
    [params setObject:lastId forKey:@"lastId"];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.fresconews.Fresco"])
        [params setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"sourcesFilter"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        NSArray *posts = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:obj error:NULL];
        }];
        
        if (responseBlock) responseBlock(posts, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        if (responseBlock) responseBlock(nil, error);
    }];
}


#pragma mark - get tags

- (void)getTagsWithResponseBlock:(FRSAPIResponseBlock)responseBlock{
    NSString *path = @"frs-query.php";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"getTagsWithPosts" forKey:@"type"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        NSArray *tags = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSTag class] fromJSONDictionary:obj error:NULL];
        }];
        if(responseBlock)
            responseBlock(tags, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

       if(responseBlock)
           responseBlock(nil, error);
    }];
    
}

#pragma mark - tag search

- (void)searchForTags:(NSString *)searchTerm responseBlock:(FRSAPIArrayResponseBlock)responseBlock
{
    [self cancelSearch];
    NSString *path = @"frs-query.php";
    NSDictionary *params = @{@"type": @"getTags", @"query" : (searchTerm ?: @"")};
    NSURLSessionTask *task = [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseBlock) responseBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (responseBlock) responseBlock(nil, error);
    }];
    [self setSearchTask:task];
}

- (void)cancelSearch
{
    [[self searchTask] cancel];
    [self setSearchTask:nil];
}

#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSString *path = @"http://monorail.theburgg.com/fresco/stories.php?type=stories";
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSArray *stories = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSStory class] fromJSONDictionary:obj error:NULL];
        }];
        if(responseBlock)
            responseBlock(stories, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock)
            responseBlock(nil, error);
    }];
    
}

#pragma mark - Galleries

- (void)getGalleriesAtURLString:(NSString *)urlString WithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if ([responseObject objectForKey:@"data"] != [NSNull null]) {
            NSArray *galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
                return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
            }];
            if(responseBlock)
                responseBlock(galleries, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock)
            responseBlock(nil, error);
    }];
}

- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock{
    if (offset != nil) {
        
        [self getGalleriesAtURLString:[NSString stringWithFormat:@"/gallery/highlights?offset=%@", offset] WithResponseBlock:responseBlock];
    }
    else{
        [self getGalleriesAtURLString:@"/gallery/highlights/" WithResponseBlock:responseBlock];
    }
}


- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [self getGalleriesAtURLString:[NSString stringWithFormat:@"/user/galleries?id=%@", [FRSDataManager sharedManager].currentUser.userID] WithResponseBlock:responseBlock];
}

@end