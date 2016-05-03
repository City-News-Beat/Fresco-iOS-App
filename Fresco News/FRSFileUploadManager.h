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

@interface FRSFileUploadManager : NSObject <FRSUploadDelegate>
{
    
}

@property (nonatomic, readonly) NSMutableArray *uploadQueue;
@property (nonatomic, readonly) NSMutableArray *activeUploads;
@property (readonly) unsigned long bytesToSend;
@property (readonly) unsigned long bytesSent;
@property (readonly) float progressPercentage; // calculated by bytesSent/bytesToSend

+(instancetype)sharedUploader;
-(void)uploadPhoto:(NSURL *)photoURL toURL:(NSURL *)destinationURL;
-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL;
@end
