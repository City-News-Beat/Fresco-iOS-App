//
//  FRSUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 10/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadManager.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import "FRSUpload+CoreDataProperties.h"
#import "Fresco.h"
#import "FRSAppDelegate.h"
#import "FRSTracker.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@implementation FRSUploadManager
static NSDate *lastDate;


+ (id)sharedUploader {
    
    static FRSUploadManager *sharedUploader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUploader = [[self alloc] init];
    });
    
    return sharedUploader;
}

-(void)checkCachedUploads {
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"completed", @(FALSE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUpload"];
    signedInRequest.predicate = signedInPredicate;
    
    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; // temp (replace with internal or above method
    
    // no need to sort response, because theoretically there is 1
    NSError *fetchError;
    NSArray *uploads = [context executeFetchRequest:signedInRequest error:&fetchError];
    NSMutableDictionary *uploadsDictionary = [[NSMutableDictionary alloc] init];
    
    if (uploads.count > 0) {
        for (FRSUpload *upload in uploads) {
            
            NSTimeInterval sinceStart = [upload.creationDate timeIntervalSinceNow];
            sinceStart *= -1;
            
            if (sinceStart >= (24 * 60 * 60)) {
                
                [self.context performBlock:^{
                    upload.completed = @(TRUE);
                    [self.context save:Nil];
                }];
                
                continue;
            }
                NSString *key = upload.uploadID;
                [uploadsDictionary setObject:upload forKey:key];
        }
        
        self.managedObjects = uploadsDictionary;
        [self retryUpload];
    }
}

-(void)appWillResignActive {
    
    if (completed == toComplete) {
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) == FALSE) {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
        localNotification.alertBody = @"Wait, we're almost done! Come back to Fresco to finish uploading your gallery.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        return;
    }
    
    UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
    objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"Come back and finish your upload!" arguments:nil];
    objNotificationContent.body = [NSString localizedUserNotificationStringForKey:@"Wait, we're almost done! Come back to Fresco to finish uploading your gallery."
                                                                        arguments:nil];
    objNotificationContent.sound = [UNNotificationSound defaultSound];
    objNotificationContent.userInfo = @{@"type":@"trigger-upload-notification"};
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    components.second += 3;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
                                              triggerWithDateMatchingComponents:components repeats:FALSE];
    
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"com.fresconews.Fresco"
                                                                          content:objNotificationContent trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Local Notification succeeded");
        }
        else {
            NSLog(@"Local Notification failed");
        }
    }];
}

-(void)retryUpload {
    currentIndex = 0;
    totalFileSize = 0;
    uploadedFileSize = 0;
    lastProgress = 0;
    toComplete = 0;
    completed = 0;
    self.uploadMeta = [[NSMutableArray alloc] init];
    
    for (NSString *uploadPost in [self.managedObjects allKeys]) {
        FRSUpload *upload = [self.managedObjects objectForKey:uploadPost];
        if ([upload.completed boolValue] != TRUE) {
            // key = TOKEN uploadID = POST resourceURL = ASSEt
            if (upload.key && upload.uploadID && upload.resourceURL) {
                PHFetchResult *assetArray = [PHAsset fetchAssetsWithLocalIdentifiers:@[upload.resourceURL] options:nil];
                PHAsset *asset = [assetArray firstObject];
                [self addAsset:asset withToken:upload.key withPostID:upload.uploadID];
            }
            
            [self.context performBlock:^{
                upload.completed = @(TRUE);
                [self.context save:Nil];
            }];
        }
    }
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    self.currentUploads = [[NSMutableArray alloc] init];
    self.uploadsToComplete = 0;
    self.completedUploads = 0;
    self.uploadMeta = [[NSMutableArray alloc] init];
    [self startAWS];
    currentIndex = 0;
    
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = delegate.managedObjectContext;
    
    [self subscribeToEvents];
    
}

-(void)subscribeToEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSRetryUpload" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self retryUpload];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSDismissUpload" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        for (NSString *uploadPost in [self.managedObjects allKeys]) {
            FRSUpload *upload = [self.managedObjects objectForKey:uploadPost];
            
            [self.context performBlock:^{
                upload.completed = @(TRUE);
                [self.context save:Nil];
            }];
        }

    }];
    
}

-(void)createUploadWithAsset:(PHAsset *)asset token:(NSString *)token post:(NSString *)post {
    
    FRSUpload *upload = [FRSUpload MR_createEntityInContext:self.context];
    
    [self.context performBlock:^{
        upload.resourceURL = asset.localIdentifier;
        upload.key = token;
        upload.uploadID = post;
        upload.completed = @(FALSE);
        upload.creationDate = [NSDate date];
        [self.context save:Nil];
    }];
    
    if (!self.managedObjects) {
        self.managedObjects = [[NSMutableDictionary alloc] init];
    }
    
    [self.managedObjects setObject:upload forKey:post];
}

-(void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID {
    if (!asset || !token) {
        return;
    }
    
    toComplete++;
    
    NSString *revisedToken = [@"raw/" stringByAppendingString:token];
    
    [self createUploadWithAsset:asset token:token post:postID];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.version = PHImageRequestOptionsVersionOriginal;
        
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSString *tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"] stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpeg"]];
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:Nil];
            
            // write data to temp path (background thread, async)
            [imageData writeToFile:tempPath atomically:NO];
            
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil] fileSize];
            totalFileSize += fileSize;
            
            NSArray *uploadMeta = @[tempPath, revisedToken, postID];
            
            [self.uploadMeta addObject:uploadMeta];
            [self checkRestart];
        }];
    }
    else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:Nil resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
            // create temp location to move data (PHAsset can not be weakly linked to)
            NSString *tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"] stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:Nil];
            
            // set up resource from PHAsset
            PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
            PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
            options.networkAccessAllowed = YES;
            
            // write data from PHAsset resource to temp location, send for upload
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:tempPath] options:options completionHandler:^(NSError * _Nullable error) {
                
                unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil] fileSize];
                totalFileSize += fileSize;

                NSArray *uploadMeta = @[tempPath, revisedToken, postID];
                [self.uploadMeta addObject:uploadMeta];
                [self checkRestart];
            }];
        }];
    }
}

-(void)checkRestart {
    if (self.uploadMeta.count == 1) {
        [self restart];
    }
}

-(void)restart {
    
    if (completed == toComplete) {
        // complete
        NSLog(@"UPLOAD PROCESS COMPLETE");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"completion"}];
        currentIndex = 0;
        totalFileSize = 0;
        uploadedFileSize = 0;
        lastProgress = 0;
        toComplete = 0;
        completed = 0;
        self.uploadMeta = [[NSMutableArray alloc] init];
        return;
    }
    
    NSLog(@"STARTING NEW UPLOAD");
    NSArray *request = [self.uploadMeta objectAtIndex:currentIndex];
    [self addUploadForPost:request[1] url:request[0] postID:request[2] completion:^(id responseObject, NSError *error) {
        NSLog(@"COMPLETED: %@ %@", responseObject, error);
    }];
}

-(void)next {
    
}

-(void)startAWS {
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:awsAccessKey secretKey:awsSecretKey];
        
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWS_REGION credentialsProvider:credentialsProvider];
        
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

-(void)addUploadForPost:(NSString *)postID url:(NSString *)body postID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    
    AWSS3TransferManagerUploadRequest *upload = [AWSS3TransferManagerUploadRequest new];
    
    if ([body containsString:@".jpeg"]) {
        upload.contentType = @"image/jpeg";
    }
    else {
        upload.contentType = @"video/mp4";
    }
    
    upload.body = [NSURL fileURLWithPath:body];
    upload.key = postID;
    upload.metadata = @{@"post_id":post};
    upload.bucket = awsBucket;
    
    /*
        MixPanel speed tracking
     */
    lastDate = [NSDate date];
    
    upload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        [self updateProgress:bytesSent];
        
        NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastDate];
        float percentageOfSecond = 1 / secondsSinceLastUpdate;
        
        float megabitsPerSecond = bytesSent * percentageOfSecond * 1.0 / 1024 /* kb */ / 1024 /* mb */;
        uploadSpeed = megabitsPerSecond;
        
        NSLog(@"UPLOAD SPEED: %fmbps", megabitsPerSecond);
        
        lastDate = [NSDate date];
    };
    __weak typeof (self) weakSelf = self;
    
    [[transferManager upload:upload] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            NSLog(@"ERR: %@", task.error);
            [weakSelf uploadDidErrorWithError:task.error];
        }
        
        if (task.result) {
            
            FRSUpload *upload = [self.managedObjects objectForKey:post];
            
            if (upload) {
                [self.context performBlock:^{
                    upload.completed = @(TRUE);
                    [self.context save:Nil];
                }];
            }
            
            completed++;
            NSLog(@"UPLOAD COMPLETE");
            currentIndex++;
            [self taskDidComplete:task];
            [self restart];
        }
        
        return nil;
    }];
}

-(void)updateProgress:(int64_t)bytes {
    uploadedFileSize+= bytes;
    float progress = (uploadedFileSize * 1.0) / (totalFileSize * 1.0);
    NSLog(@"PROG: %f", progress);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"progress", @"percentage":@(progress)}];
}

-(void)uploadDidErrorWithError:(NSError *)error {
    
    NSMutableDictionary *uploadErrorSummary = [@{@"error_message":error.localizedDescription} mutableCopy];
    if (uploadSpeed > 0) {
        [uploadErrorSummary setObject:@(uploadSpeed) forKey:@"upload_speed"];
    }
    
    if (error.localizedDescription) {
        [FRSTracker track:@"Upload Failure" parameters:uploadErrorSummary];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:Nil userInfo:@{@"type":@"failure"}];
}

-(void)taskDidComplete:(AWSTask *)task {
//    NSString *eTag = task.aws_properties[@"ETag"];
//    
//    if (eTag == nil) {
//        [self uploadDidErrorWithError:Nil];
//    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
