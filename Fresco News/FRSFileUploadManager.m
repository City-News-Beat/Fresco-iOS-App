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
@synthesize uploadQueue = _uploadQueue, notificationCenter = _notificationCenter, errorCount = _errorCount, forcePaused = _forcePaused;


+(instancetype)sharedUploader {
    static FRSFileUploadManager *uploader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        uploader = [[FRSFileUploadManager alloc] init];
    });
    
    return uploader;
}

-(id)init {
    self = [super init];
    
    if (self) {
        _uploadQueue = [[NSMutableArray alloc] init];
        _activeUploads = [[NSMutableArray alloc] init];
        _notificationCenter = [NSNotificationCenter defaultCenter];
        [self startReachability];
        [self resumeFromPersistentUploads];
    }
    
    return self;
}

-(void)startReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

-(void)reachabilityChanged:(NSNotification *)reachabilityNotification {
    
    Reachability *curReach = [reachabilityNotification object];
    NetworkStatus currentStatus = [curReach currentReachabilityStatus];

    switch (currentStatus)
    {
        case NotReachable: {
            _forcePaused = TRUE;
            break;
        }
            
        case ReachableViaWWAN: {
            if (_forcePaused) {
                [self restartQueue];
            }
            _forcePaused = FALSE;
            break;
        }
        case ReachableViaWiFi: {
            if (_forcePaused) {
                [self restartQueue];
            }
            _forcePaused = FALSE;
            break;
        }
    }
}

-(void)resumeFromPersistentUploads {
    // load already persisted uploads
}

// upload photo and video exist b/c we have rules as to what gets past on as single request or multi request task
-(void)uploadPhoto:(NSURL *)photoURL toURL:(NSURL *)destinationURL {
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [photoURL getResourceValue:&fileSizeValue
                        forKey:NSURLFileSizeKey
                         error:&fileSizeError];
    
    [self handleSingleUpload:photoURL destination:destinationURL fileSize:[fileSizeValue integerValue]];
}

-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL {
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [videoURL getResourceValue:&fileSizeValue
                       forKey:NSURLFileSizeKey
                        error:&fileSizeError];
    
    _bytesToSend += [fileSizeValue unsignedLongLongValue];
    
    if (fileSizeError) {
        // default to chunked upload
        [self handleChunkedUpload:videoURL destination:destinationURL fileSize:[fileSizeValue integerValue]];
    }
    else if ([fileSizeValue unsignedLongLongValue] / 1024 / 1024 > 25) {
        // chunked upload
        [self handleChunkedUpload:videoURL destination:destinationURL fileSize:[fileSizeValue integerValue]];
    }
    else {
        // single upload
        [self handleSingleUpload:videoURL destination:destinationURL fileSize:[fileSizeValue integerValue]];
    }
}

-(void)handleSingleUpload:(NSURL *)url destination:(NSURL *)destination fileSize:(NSInteger)sizeInBytes {
    // create FRSUploadTask, add to queue
    FRSUploadTask *newTask = [[FRSUploadTask alloc] init];
    newTask.delegate = self;
    newTask.managedObject = [self managedObjectForTask:newTask];
    newTask.fileSizeFromMetadata = (int64_t)sizeInBytes;
    /* configure task */
    [self addUploadTask:newTask];
}

-(void)handleChunkedUpload:(NSURL *)url destination:(NSURL *)destination fileSize:(NSInteger)sizeInBytes {
    // create FRSMultipartTask, add to queue
    FRSMultipartTask *newTask = [[FRSMultipartTask alloc] init];
    newTask.delegate = self;
    newTask.managedObject = [self managedObjectForTask:newTask];
    newTask.fileSizeFromMetadata = (int64_t)sizeInBytes;
    /* configure task */
    [self addUploadTask:newTask];
}

// creates managed object based off *NEW* **FULLY INITIALIZED** upload task
-(NSManagedObject *)managedObjectForTask:(FRSUploadTask *)task {
    NSManagedObjectContext *currentContext = [self uploaderContext];
    NSManagedObject *taskManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUpload" inManagedObjectContext:currentContext];
    
    // specific properties
    if ([[task class] isSubclassOfClass:[FRSMultipartTask class]]) {
        FRSMultipartTask *multiTask = (FRSMultipartTask *)task;
        [taskManagedObject setValue:multiTask.destinationURLS forKey:@"destinationURLS"];
        [taskManagedObject setValue:@(TRUE) forKey:@"multipart"];
        [taskManagedObject setValue:@(chunkSize) forKey:@"chunkSize"];
    }
    else if ([[task class] isSubclassOfClass:[FRSUploadTask class]]) {
        [taskManagedObject setValue:@(FALSE) forKey:@"multipart"];
        [taskManagedObject setValue:@[task.destinationURL.absoluteString] forKey:@"destinationURLS"]; // save AWS signed URL

    }
    else {
        return Nil; // what tf went on here, theoretically impossible, & should have broken by now
    }
    
    // general properties
    [taskManagedObject setValue:@(task.fileSizeFromMetadata) forKey:@"fileSize"];
    [taskManagedObject setValue:[NSDate date] forKey:@"creationDate"]; // check against expired URLS, etc
    [taskManagedObject setValue:task.assetURL forKey:@"assetURL"]; // save origin location (might be temp, might have to change)
    
    NSError *storeError;
    [currentContext save:&storeError];
    
    if (storeError) {
        NSLog(@"Error saving upload task: %@", storeError);
    }
    
    return taskManagedObject;
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
        if (!task.hasStarted) {
            [task start];
        }
    }

}

-(void)next {
    if ([self.uploadQueue count] > 1) {
        FRSUploadTask *nextTask = self.uploadQueue[1];
        [nextTask start];
    }
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

+(NSManagedObjectContext *)uploaderContext {
    id<FRSContextProvider> appDelegate = (id<FRSContextProvider>)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

-(void)handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler {
    // do work
    
    
    // end work
    completionHandler();
}

@end
