//
//  FRSFileUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFileUploadManager.h"
#import "FRSMultipartTask.h"

@implementation FRSFileUploadManager
@synthesize uploadQueue = _uploadQueue;


-(id)init {
    self = [super init];
    
    if (self) {
        _uploadQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}
-(void)uploadPhoto:(NSURL *)photoURL toURL:(NSURL *)destinationURL {
    [self handleSingleUpload:photoURL destination:destinationURL];
}

-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL {
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [videoURL getResourceValue:&fileSizeValue
                       forKey:NSURLFileSizeKey
                        error:&fileSizeError];
    
    if (fileSizeError) {
        // default to chunked upload
        [self handleChunkedUpload:videoURL destination:destinationURL];
    }
    else if ([fileSizeValue unsignedLongLongValue] / 1024 / 1024 > 25) {
        // chunked upload
        [self handleChunkedUpload:videoURL destination:destinationURL];
    }
    else {
        // single upload
        [self handleSingleUpload:videoURL destination:destinationURL];
    }
}

-(void)handleSingleUpload:(NSURL *)url destination:(NSURL *)destination {
    // create FRSUploadTask, add to queue
    FRSUploadTask *newTask = [[FRSUploadTask alloc] init];
    /* configure task */
    [self addUploadTask:newTask];
}

-(void)handleChunkedUpload:(NSURL *)url destination:(NSURL *)destination {
    // create FRSMultipartTask, add to queue
    FRSMultipartTask *newTask = [[FRSMultipartTask alloc] init];
    /* configure task */
    [self addUploadTask:newTask];
}

-(void)addUploadTask:(FRSUploadTask *)task {
    [_uploadQueue addObject:task];
    [self checkAgainstEmptyQueue];
}

-(void)checkAgainstEmptyQueue {
    if ([self.uploadQueue count] == 1) {
        FRSUploadTask *task = self.uploadQueue[0];
        if (!task.hasStarted) {
            [self restartQueue];
        }
    }
}

-(void)restartQueue {
    if ([self.uploadQueue count] >= 1) {
        FRSUploadTask *task = self.uploadQueue[0];
        [task start];
    }

}


+(instancetype)sharedUploader {
    static FRSFileUploadManager *uploader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        uploader = [[FRSFileUploadManager alloc] init];
    });
    
    return uploader;
}

-(void)handleError:(FRSUploadTask *)task error:(NSError *)error {
    
}

#pragma mark Delegate Methods

-(void)uploadWillStart:(id)upload {
    
}

-(void)uploadDidProgress:(id)upload bytesSent:(unsigned long)sent totalBytes:(unsigned long)total {
    
}

-(void)uploadDidSucceed:(id)upload withResponse:(NSData *)response {
    
}

-(void)uploadDidFail:(id)upload withError:(NSError *)error response:(NSData *)response {
    
}


@end
