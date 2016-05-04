//
//  FRSFileUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSMultipartTask.h"

static NSString * const uploadFailedNotification = @"FRSUploadFailedNotification";
static NSString * const uploadSuccessNotification = @"FRSUploadSuccessNotification";
static NSString * const uploadProgressNotification = @"FRSUploadProgressNotification";
static NSString * const uploadStartedNotification = @"FRSUploadStartedNotification";
static int const maxFailures = 5;

@interface FRSFileUploadManager : NSObject <FRSUploadDelegate>
{
    
}

@property (nonatomic, readonly) int errorCount;
@property (nonatomic, readonly) NSMutableArray *uploadQueue;
@property (nonatomic, readonly) NSMutableArray *activeUploads;
@property (readonly) unsigned long long bytesToSend;
@property (readonly) unsigned long long bytesSent;
@property (readonly) float progressPercentage; // calculated by bytesSent/bytesToSend
@property (nonatomic) NSNotificationCenter *notificationCenter;
+(instancetype)sharedUploader;
-(void)uploadPhoto:(NSURL *)photoURL toURL:(NSURL *)destinationURL;
-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL;
@end
