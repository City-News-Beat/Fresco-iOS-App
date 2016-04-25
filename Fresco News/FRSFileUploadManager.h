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

@interface FRSFileUploadManager : NSObject
{
    
}

@property (nonatomic, readonly) NSMutableArray *uploadQueue;

+(instancetype)sharedUploader;
-(void)uploadPhoto:(NSURL *)photoURL toURL:(NSURL *)destinationURL;
-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL;
@end
