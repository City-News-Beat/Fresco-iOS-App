//
//  FRSFileUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFileUploadManager.h"
#import "FRSMultipartTask.h"
#import "FRSAppDelegate.h" // take advantage of specific core data methods

@implementation FRSFileUploadManager
@synthesize uploadQueue = _uploadQueue, notificationCenter = _notificationCenter, errorCount = _errorCount;


-(id)init {
    self = [super init];
    
    if (self) {
        _uploadQueue = [[NSMutableArray alloc] init];
        _activeUploads = [[NSMutableArray alloc] init];
        _notificationCenter = [NSNotificationCenter defaultCenter];
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
    
    _bytesToSend+=[fileSizeValue unsignedLongLongValue];
    
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
    newTask.delegate = self;
    
    /* configure task */
    [self addUploadTask:newTask];
}

-(void)handleChunkedUpload:(NSURL *)url destination:(NSURL *)destination {
    // create FRSMultipartTask, add to queue
    FRSMultipartTask *newTask = [[FRSMultipartTask alloc] init];
    newTask.delegate = self;
    
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

-(void)next {
    if ([self.uploadQueue count] > 1) {
        FRSUploadTask *nextTask = self.uploadQueue[1];
        [nextTask start];
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
    [self.notificationCenter postNotificationName:uploadStartedNotification object:upload userInfo:Nil];
    [self.activeUploads addObject:upload];
}

-(void)uploadDidProgress:(id)upload bytesSent:(int64_t)sent totalBytes:(int64_t)total {
    NSDictionary *infoForNotification = @{@"sent":@(sent), @"total":@(total)};
    [self.notificationCenter postNotificationName:uploadProgressNotification object:upload userInfo:infoForNotification];
    
    _bytesSent += total;
}

-(void)uploadDidSucceed:(id)upload withResponse:(NSData *)response {
    NSDictionary *infoForNotification = @{@"response":response};
    [self.notificationCenter postNotificationName:uploadSuccessNotification object:upload userInfo:infoForNotification];
    
    [self.activeUploads removeObject:upload];
    [self next];
}

-(void)uploadDidFail:(id)upload withError:(NSError *)error response:(NSData *)response {
    _errorCount++;

    NSDictionary *infoForNotification = @{@"response":response, @"error":error};
    [self.notificationCenter postNotificationName:uploadFailedNotification object:upload userInfo:infoForNotification];
    
    if (_errorCount >= maxFailures) {
        [self waitOnFailure];
        return;
    }
    
    [self.activeUploads removeObject:upload];
    [self.activeUploads addObject:upload];
    [self next];
}

-(void)waitOnFailure {
    // wait for x seconds before starting again
    [self performSelector:@selector(next) withObject:Nil afterDelay:5];
}

-(NSManagedObjectContext *)uploaderContext {
    id<FRSFileUploaderObjectContext> appDelegate = (id<FRSFileUploaderObjectContext>)[[UIApplication sharedApplication] delegate];
    
    return [appDelegate managedObjectContext];
}

// background notification & app killer
-(void)continueFromBackgroundWithCompletion:(nonnull void (^)())completionHandler {
    //complete work (either iterate based on waiting uploads or remove from store)
    
    
    // end of work
    completionHandler();
}

@end
