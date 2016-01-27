//
//  FRSUploadManager.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/23/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

@import FBSDKCoreKit;
@import FBSDKShareKit;
@import Photos;

#import "FRSUploadManager.h"
#import "FRSDataManager.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>



@interface FRSUploadManager()

+ (NSURLSessionConfiguration *)frescoSessionConfiguration;

@property (nonatomic, assign) NSInteger postCount;

@property (nonatomic, assign) NSInteger currentPostIndex;

@property (strong, nonatomic) NSMutableArray *uploadingAssetIDs;

/*
 @{
    @"gallery_id" : <gallery.galleryId>
    @"assets" : @[assetId]
    @"caption" : <caption>
    @"facebook_selected" : @BOOL
    @"twitter_selected: @BOOL 
 }
*/
@property (strong, nonatomic) NSMutableDictionary *uploadingDict;

@end

@implementation FRSUploadManager

#pragma mark - static methods

+ (FRSUploadManager *)sharedManager
{
    static FRSUploadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FRSUploadManager alloc] init];
        
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
    NSURL *baseURL = [NSURL URLWithString:BASE_API];
    
    if (self = [super initWithBaseURL:baseURL sessionConfiguration:[[self class] frescoSessionConfiguration]]) {
        
        [[self responseSerializer] setAcceptableContentTypes:nil];
        
    }
    return self;
}

#pragma mark Upload Methods

- (void)uploadGallery:(FRSGallery *)gallery withAssignment:(FRSAssignment *)assignment withSocialOptions:(NSDictionary *)socialOptions withResponseBlock:(FRSAPISuccessBlock)responseBlock{
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    __block NSProgress *progress = nil;
    
    //Form the request
    FRSPost *post = gallery.posts[0];
    
    self.postCount = gallery.posts.count;
    self.currentPostIndex = 0;
    
    NSString *filename = [NSString stringWithFormat:@"file%@", @(0)];
    
    NSDictionary *parameters = @{ @"owner" : [FRSDataManager sharedManager].currentUser.userID,
                                  @"caption" : gallery.caption ?: [NSNull null],
                                  @"posts" : [post constructPostMetaDataWithFileName:filename],
                                  @"assignment" : assignment.assignmentId ?: [NSNull null],
                                  @"count" : @(self.postCount)};
    
    
    self.isUploadingGallery = YES;
    
    //Send request for image data
    [post dataForPostWithResponseBlock:^(NSData *data, NSError *error) {
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
                                        multipartFormRequestWithMethod:@"POST"
                                        URLString:[[FRSDataManager sharedManager] endpointForPath:@"gallery/assemble"]
                                        parameters:parameters
                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                            
                                            FRSPost *post = gallery.posts[0];
                                            
                                            NSString *mimeType = post.image.asset.mediaType == PHAssetMediaTypeImage ? @"image/jpeg" : @"video/quicktime";
                                            
                                            [formData appendPartWithFileData:data
                                                                        name:filename
                                                                    fileName:filename
                                                                    mimeType:mimeType];
                                            
                                            
                                        } error:nil];
        
        [request setValue:[FRSDataManager sharedManager].frescoAPIToken forHTTPHeaderField:@"authtoken"];
        
        NSURLSessionUploadTask *uploadTask = [manager
                                              uploadTaskWithStreamedRequest:request
                                              progress:&progress
                                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *uploadError) {
                                                  
                                                  //Check if we have a valid response
                                                  
                                                  NSLog(@"error = %@", uploadError.localizedDescription);
                                                  NSLog(@"response = %@", response);
                                                  NSLog(@"responseObject = %@", responseObject);
                                                  
                                                  if(responseObject[@"data"][@"_id"] != nil && !uploadError){
                                                      
                                                      gallery.galleryID = responseObject[@"data"][@"_id"];
                                                      
                                                      //Run rest of upload
                                                      
                                                      [self handleGalleryCompletionForGallery:gallery withSocialOptions:socialOptions];
                                                      
                                                      
                                                  }
                                                  //Gallery ID is missing
                                                  else{
                                                      
                                                      //Send response block back to caller
                                                      if(responseBlock)
                                                          responseBlock(NO, nil);
                                                      
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_FAILURE object:nil];
                                                      
                                                      self.isUploadingGallery = NO;
                                                      
                                                  }
                                                  
                                              }];
        
        [uploadTask resume];
        
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }];
}

/**
 *  Extracting completion for initial gallery upload, this method uploads the rest of the posts from the gallery that is being uploaded.
 *
 *  @param gallery The gallery to finish upload
 */

- (void)handleGalleryCompletionForGallery:(FRSGallery *)gallery withSocialOptions:(NSDictionary *)socialOptions{
    
    //Check if the gallery has more than one post
    if(gallery.posts.count > 1)
        
        //Dispatch posts upload to global queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
            
            //Thread waits for each upload
            dispatch_semaphore_t  semaphore = dispatch_semaphore_create(0);
            
            //Lopp through posts and upload each one back to back
            for (NSInteger i = 1; i < gallery.posts.count; i++) {
                
                [self uploadPost:gallery.posts[i] withGalleryId:gallery.galleryID withResponseBlock:^(BOOL sucess, NSError *error) {
                    
                    //Signal to update the profile when upload is finished i.e. finished with the last post
                    if(i == gallery.posts.count - 1){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_COMPLETE object:nil];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_UPLOADING_GALLERY_DICT];
                            self.isUploadingGallery = NO;
                        });
                    }
                    
                    //Signal that upload is done to semaphore
                    dispatch_semaphore_signal(semaphore);
                    
                }];
                
                //Call dispatch_semaphore_wait to prevent thread from running
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        });

    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_COMPLETE object:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_UPLOADING_GALLERY_DICT];
            self.isUploadingGallery = NO;
        });
        
    }
    
    //Run social psot now that we have the gallery id back
    NSString *crossPostString = [NSString stringWithFormat:@"Just posted a gallery to @fresconews: %@/gallery/%@", BASE_URL, gallery.galleryID];
    
    NSString *title = @"Just posted a gallery to @fresconews:";
    NSString *url = [NSString stringWithFormat:@"%@/gallery/%@", BASE_URL, gallery.galleryID];
    
    if(((NSNumber *)socialOptions[@"twitter"]).boolValue)
        [self postToTwitter:crossPostString];
    
    if(((NSNumber *)socialOptions[@"facebook"]).boolValue){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Gallery Upload Done" object:nil userInfo:@{@"title" : title, @"url" : url}];
    }
//        [self postToFacebook:crossPostString];
    
    [self resetDraftGalleryPost];

}

- (void)uploadPost:(FRSPost *)post withGalleryId:(NSString *)galleryId withResponseBlock:(FRSAPISuccessBlock)responseBlock{
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    self.currentPostIndex++;
    
    __block NSProgress *progress = nil;
    
    NSString *filename = [NSString stringWithFormat:@"file%@", @(self.currentPostIndex)];
    
    NSDictionary *parameters = @{
                                 @"gallery" : galleryId,
                                 @"posts" : [post constructPostMetaDataWithFileName:filename]
                                 };
    
    //Request image data
    [post dataForPostWithResponseBlock:^(NSData *data, NSError *error) {
    
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
                                        multipartFormRequestWithMethod:@"POST"
                                        URLString:[[FRSDataManager sharedManager] endpointForPath:@"gallery/addpost"]
                                        parameters:parameters
                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                            
                                            NSString *mimeType = post.image.asset.mediaType == PHAssetMediaTypeImage ? @"image/jpeg" : @"video/quicktime";
                                            
                                            [formData appendPartWithFileData:data
                                                                        name:filename
                                                                    fileName:filename
                                                                    mimeType:mimeType];
                                            
                                            
                                        } error:nil];
        
        [request setValue:[FRSDataManager sharedManager].frescoAPIToken forHTTPHeaderField:@"authtoken"];
        
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *uploadError) {
            
            if(responseBlock)
                responseBlock(uploadError == nil ? YES : NO, uploadError);
            
        }];
        
        [uploadTask resume];

        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    
    }];

}


#pragma mark - Social Upload Methods

- (void)postToTwitter:(NSString *)string {
    
    string = [NSString stringWithFormat:@"status=%@", string];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    tweetRequest.HTTPMethod = @"POST";
    tweetRequest.HTTPBody = [[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] dataUsingEncoding:NSUTF8StringEncoding];
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
    
    [NSURLConnection sendAsynchronousRequest:tweetRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {
            // TODO: Notify the user
            NSLog(@"Error crossposting to Twitter: %@", connectionError);
        }
        
    }];
}

- (void)postToFacebook:(NSString *)string{
    
    
    
    
    
    

    // TODO: Fix [[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"] ) {
//    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
//                                       parameters: @{@"message" : string}
//                                       HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        if (error) {
//            // TODO: Notify the user
//            NSLog(@"Error crossposting to Facebook");
//        }
//        else {
//            NSLog(@"Success crossposting to Facebook: Post id: %@", result[@"id"]);
//        }
//    }];

}

#pragma mark - User Defaults Management

- (void)resetDraftGalleryPost
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:UD_CAPTION_STRING_IN_PROGRESS];
    [defaults setObject:nil forKey:UD_DEFAULT_ASSIGNMENT_ID];
    [defaults setObject:nil forKey:UD_SELECTED_ASSETS];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        
        NSProgress *progress = (NSProgress *)object;
        
        NSNumber *fractionCompleted = [NSNumber numberWithDouble:((progress.fractionCompleted + (float)self.currentPostIndex) / self.postCount)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIF_UPLOAD_PROGRESS
             object:nil
             userInfo:@{
                        @"fractionCompleted" : fractionCompleted
                        }];
        });
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



@end
