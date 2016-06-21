//
//  FRSFileUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSMultipartTask.h"
#import "Reachability.h"

static NSString * __nonnull const uploadFailedNotification = @"FRSUploadFailedNotification";
static NSString * __nonnull const uploadSuccessNotification = @"FRSUploadSuccessNotification";
static NSString * __nonnull const uploadProgressNotification = @"FRSUploadProgressNotification";
static NSString * __nonnull const uploadStartedNotification = @"FRSUploadStartedNotification";
static int const maxFailures = 5; // max failures before pause
static int const failWaitTime = 5; // seconds waited between fail count trigger

@protocol FRSContextProvider <NSObject>
-(nullable NSManagedObjectContext *)managedObjectContext;
@end

@interface FRSFileUploadManager : NSObject <FRSUploadDelegate>
{
    
}
@property (nonatomic, readonly) NetworkStatus reachabilityStatus;
@property (nonatomic, readonly) BOOL forcePaused;
@property (nonatomic, readonly) int errorCount;
@property (nonatomic, readonly, nullable) NSMutableArray *uploadQueue;
@property (nonatomic, readonly, nullable) NSMutableArray *activeUploads;
@property (readonly) unsigned long long bytesToSend;
@property (readonly) unsigned long long bytesSent;
@property (readonly) float progressPercentage; // calculated by bytesSent/bytesToSend
@property (nonatomic, nullable) NSNotificationCenter *notificationCenter;
+(__nonnull instancetype)sharedUploader;
-(void)uploadPhoto:( NSURL * _Nonnull )photoURL toURL:(NSURL * _Nonnull)destinationURL;
-(void)uploadVideo:(NSURL * _Nonnull)videoURL toURL:(NSURL * _Nonnull)destinationURL;
-(nullable NSManagedObjectContext *)uploaderContext;

+(nullable NSManagedObjectContext *)uploaderContext; // convenience for outside use
-(void)handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler; // iterate in background


/*
    Post creation (pre-upload stage)
 */

-(void)createGalleryWithPosts:(nonnull NSArray *)posts;
@end
