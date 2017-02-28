//
//  FRSUploadManager.m
//  Fresco
//
//  Created by Elmir Kouev on 2/23/17.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadManager.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import "FRSUpload+CoreDataProperties.h"
#import "Fresco.h"
#import "FRSAppDelegate.h"
#import "FRSTracker.h"
#import "SDAVAssetExportSession.h"
#import "EndpointManager.h"
#import "FRSLocator.h"
#import "NSDate+ISO.h"
#import "NSError+Fresco.h"
#import "PHAsset+Fresco.h"
#import "CLLocation+Fresco.h"
#import "NSURL+Fresco.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@interface FRSUploadManager ()

@property (nonatomic, strong) AWSS3TransferManager *transferManager;

@end

@implementation FRSUploadManager

+ (id)sharedInstance {
    static FRSUploadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(notifyExit:) name:UIApplicationWillResignActiveNotification object:nil];

    });

    return sharedInstance;
}

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];

    if (self) {
        FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.context = delegate.coreDataController.managedObjectContext;
        
        [self subscribeToEvents];
        [self resetState];
        [self startAWS];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 This method will reset the state of the upload manager to a blank slate. 
 Should typically be called once an upload is finished or before starting a new one.
 
 Note: Managed objects are cleared on a forcel cancel of the upload, not here
 */
- (void)resetState {
    self.uploadMeta = [[NSMutableArray alloc] init];
    self.transcodingProgressDictionary = [[NSMutableDictionary alloc] init];
    totalFileSize = 0;
    totalVideoFilesSize = 0;
    totalImageFilesSize = 0;
    uploadedFileSize = 0;
    lastProgress = 0;
    toComplete = 0;
    completed = 0;
    uploadSpeed = 0;
    numberOfVideos = 0;
}

/**
 Configures AWS for us
 */
- (void)startAWS {
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]
                                                         initWithAccessKey:[EndpointManager sharedInstance].currentEndpoint.amazonS3AccessKey
                                                         secretKey:[EndpointManager sharedInstance].currentEndpoint.amazonS3SecretKey];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWS_REGION credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
}


#pragma mark - Files

- (void)checkCachedUploads {
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"completed", @(FALSE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUpload"];
    NSMutableDictionary *uploadsDictionary = [[NSMutableDictionary alloc] init];
    signedInRequest.predicate = signedInPredicate;


    //No need to sort response, because theoretically there is 1
    NSError *fetchError;
    NSArray *uploads = [self.context executeFetchRequest:signedInRequest error:&fetchError];
    
    if(uploads == nil && fetchError != nil) return;

    if (uploads.count > 0) {
        for (FRSUpload *upload in uploads) {
            NSTimeInterval sinceStart = [upload.creationDate timeIntervalSinceNow];
            sinceStart *= -1;

            //If older than a day, in seconds, remove from persistence
            if (sinceStart >= (24 * 60 * 60)) {
                [self.context performBlock:^{
                    [self.context deleteObject:upload];
                    [self.context save:nil];
                }];
            } else {
                NSString *key = upload.uploadID;
                [uploadsDictionary setObject:upload forKey:key];
            }
        }
        
        //Assign to class and retry
        self.managedObjects = uploadsDictionary;
        [self retryUpload];
    } else {
        //Otherwise clear cached uploads
        [self clearCachedUploads];
    }
}


/**
 Destroys all cached uploads in the local file system
 */
- (void)clearCachedUploads {
    BOOL isDir;
    NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:localDirectory]; // temp directory where we store video
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
        if (![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"Error: Create folder failed %@", directory);
            return;
        }
    }
    
    //Purge old un-needed files
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:localDirectory];
        NSError *error = nil;
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
            NSString *filePath =[NSString stringWithFormat:@"%@/%@", directory, file];
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
            
            if (!success || error) {
                NSLog(@"Upload cache purge %@ with error: %@", (success) ? @"succeeded" : @"failed", error);
            }
        }
    });
}

#pragma mark - Events

- (void)appWillResignActive {
    if (completed == toComplete) {
        return;
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") == FALSE) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
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
    objNotificationContent.userInfo = @{ @"type" : @"trigger-upload-notification" };

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    components.second += 3;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
        triggerWithDateMatchingComponents:components
                                  repeats:FALSE];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"com.fresconews.Fresco"
                                                                          content:objNotificationContent
                                                                          trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request
             withCompletionHandler:^(NSError *_Nullable error) {
               if (!error) {
                   NSLog(@"Local Notification succeeded!");
               } else {
                   NSLog(@"Local Notification failed.");
               }
             }];
}



- (void)notifyExit:(NSNotification *)notification {
    if (completed == toComplete || toComplete == 0) {
        return;
    }
    
    [FRSTracker track:uploadClose
           parameters:@{ @"percent_complete" : @(lastProgress) }];
}

- (void)subscribeToEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:FRSRetryUpload
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self retryUpload];
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:FRSDismissUpload
                                                      object:nil
                                                       queue:nil
     
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self cancelUploadWithForce:YES];
                                                  }];
}

/**
 Updates trancoding progress in state and subsequently broadcasts progress
 
 @param progress Floating point of current progress for a post
 @param postID The ID of the post progress is being reported on
 */
- (void)updateTranscodingProgress:(float)progress withPostID:(NSString *)postID {
    __block float transcodingProgress = 0;
    [self.transcodingProgressDictionary setValue:[NSNumber numberWithFloat:progress] forKey:postID];
    
    [self.transcodingProgressDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL *stop) {
        transcodingProgress += value.floatValue;
    }];
    
    float totalTranscodingProgress = 0.5f * transcodingProgress / numberOfVideos;
    [[NSNotificationCenter defaultCenter] postNotificationName:FRSUploadNotification
                                                        object:nil
                                                      userInfo:@{ @"type" : @"progress",
                                                                  @"percentage" : @(totalTranscodingProgress) }];
}

- (void)updateProgress:(int64_t)bytes {
    uploadedFileSize += bytes;
    
    float progress;
    if (numberOfVideos > 0) {
        progress = 0.5f + (0.5f * (uploadedFileSize * 1.0) / (totalFileSize * 1.0));
    } else {
        progress = (uploadedFileSize * 1.0) / (totalFileSize * 1.0);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRSUploadNotification
                                                        object:nil
                                                      userInfo:@{ @"type" : @"progress",
                                                                  @"percentage" : @(progress) }];
}

#pragma mark - Assets

- (void)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback {
    NSMutableDictionary *digest = [[NSMutableDictionary alloc] init];
    
    [asset.location fetchAddress:^(id responseObject, NSError *error) {
        digest[@"address"] = responseObject;
        digest[@"lat"] = @(asset.location.coordinate.latitude);
        digest[@"lng"] = @(asset.location.coordinate.longitude);
        digest[@"captured_at"] = [(NSDate *)asset.creationDate ISODateWithTimeZone];
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            digest[@"contentType"] = @"image/jpeg";
            
            [asset fetchFileSize:^(NSInteger size, NSError *error) {
                digest[@"fileSize"] = @(size);
                digest[@"chunkSize"] = @(size);
                callback(digest, error);
            }];
        } else {
            [asset fetchFileSize:^(NSInteger size, NSError *error) {
                digest[@"fileSize"] = @(size);
                digest[@"chunkSize"] = @(size);
                callback(digest, error);
            }];
        }
    }];
}

/**
 Creates an an asset for uploading by writing to the local file system and returning information
 on the location and size of the asset. The upload itself will also be saved to Core Data here if it's not already
 so that it can be pulled from cache or the upload fails mid-way
 
 TODO: Make this save the local path to be re-used later instead on the FRSUpload
 of trancoding every time if the user fails and retries the upload
 
 @param asset The PHAsset to genereate for upload
 @param key The AWS file key we're uploading to
 @param postID The ID of the post which correpsonds to this asset
 @param completion completion handler returning metadata on the asset
 */
- (void)createAssetForUpload:(PHAsset *)asset withKey:(NSString *)key withPostID:(NSString *)postID completion:(FRSUploadPostAssetCompletionBlock)completion {
    NSString *revisedKey = [@"raw/" stringByAppendingString:key];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.version = PHImageRequestOptionsVersionOriginal;
        
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, UIImageOrientation orientation, NSDictionary *_Nullable info) {
                                                        NSString *tempPath = [[NSURL uniqueFileString] stringByAppendingString:@".jpeg"];
                                                        NSError *imageError;
                                                        
                                                        //Write data to temp path (background thread, async)
                                                        if([imageData writeToFile:tempPath options:NSDataWritingAtomic error:&imageError]) {
                                                            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:&imageError];
                                                            
                                                            //Handle possible read error
                                                            if(attributes != nil && !imageError) {
                                                                NSDictionary *uploadMeta = [self uploadDictionaryForPost:tempPath key:revisedKey post:postID];
                                                                completion(uploadMeta, NO, [attributes fileSize], nil);
                                                            } else {
                                                                completion(nil, NO, 0, imageError);
                                                            }
                                                        } else {
                                                            completion(nil, NO, 0, imageError);
                                                        }
                                                    }];
        
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        //Request asset and transcode into a the desired bitrate
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                        options:nil
                                                  resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
                                                      // create temp location to move data (PHAsset can not be weakly linked to)
                                                      NSString *tempPath = [NSURL uniqueFileString];
                                                      SDAVAssetExportSession *encoder = [self encoderWithAsset:avasset postID:postID];
                                                      encoder.outputURL = [NSURL fileURLWithPath:tempPath];
                                                      
                                                      //Begin encoding the video, delegate responder will update the progress
                                                      [encoder exportAsynchronouslyWithCompletionHandler:^{
                                                          if(encoder.error) {
                                                              completion(nil, YES, 0, encoder.error);
                                                          } else if(encoder.status == AVAssetExportSessionStatusCompleted) {
                                                              NSError *videoError;
                                                              NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:&videoError];
                                                              
                                                              //Handle possible read error
                                                              if(attributes != nil && !videoError) {
                                                                  NSDictionary *uploadMeta = [self uploadDictionaryForPost:tempPath key:revisedKey post:postID];
                                                                  completion(uploadMeta, YES, [attributes fileSize], nil);
                                                              } else {
                                                                  completion(nil, YES, 0, videoError);
                                                              }
                                                          }
                                                      }];
                                                  }];
    }
}

/**
 Returns an SDAVAssetExportSession for use

 @param asset AVAsset to initialize with
 @param postID Post ID associated with the export session
 @return New initialized SDAVAssetExportSession
 */
- (SDAVAssetExportSession *)encoderWithAsset:(AVAsset *)asset postID:(NSString *)postID{
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.postID = postID;
    encoder.delegate = self;
    encoder.videoSettings = @{
                              AVVideoCodecKey : AVVideoCodecH264,
                              AVVideoWidthKey : @1920,
                              AVVideoHeightKey : @1080,
                              AVVideoCompressionPropertiesKey : @{
                                      AVVideoProfileLevelKey : AVVideoProfileLevelH264High41,
                                      AVVideoMaxKeyFrameIntervalDurationKey : @16
                                      },
                              };
    encoder.audioSettings = @{
                              AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                              AVNumberOfChannelsKey : @2,
                              AVSampleRateKey : @44100,
                              AVEncoderBitRateKey : @64000,
                              };
    
    return encoder;
}


#pragma mark - Upload Events

- (void)startNewUploadWithPosts:(NSArray *)posts {
    __weak typeof(self) weakSelf = self;
    __block NSInteger currentIndex = 0;

    //Clear state before we begin
    [self resetState];
    
    //Block to start uploads once we're done
    void (^startUploads)(void) = ^ {
        //Check if we have internet
        if(![[AFNetworkReachabilityManager sharedManager] isReachable]){
            return [weakSelf uploadDidErrorWithError:[NSError errorWithMessage:@"Unable to secure an internet connection! Please try again once you've connected to WiFi or have a celluar connection."]];
        }
        
        for (NSDictionary *uploadForPost in self.uploadMeta) {
            [self addUploadForPost:uploadForPost[@"post_id"]
                           andPath:uploadForPost[@"path"]
                            andKey:uploadForPost[@"key"]
                        completion:^(id responseObject, NSError *error) {
                            if(error) {
                                [weakSelf uploadDidErrorWithError:error];
                            } else if (completed == toComplete) {
                                //Upload has fully completed
                                [[NSNotificationCenter defaultCenter]
                                 postNotificationName:FRSUploadNotification
                                 object:nil
                                 userInfo:@{ @"type" : @"completion" }];
                                [weakSelf trackDebugWithMessage:@"Upload Completed"];
                            }
                        }];
        }
    };
    
    //Loop through and create cached uploads
    //We do this before in order to not have to wait for transcoding to finish to have cached upload objects
    for (NSInteger i = 0; i < [posts count]; i++) {
        NSDictionary *post = posts[i];

        //Check if the upload is already in memory as this can be populated before hand if the upload
        if([self.managedObjects objectForKey:post[@"post_id"]] == nil) {
            [self createUploadWithAsset:post[@"asset"] key:post[@"key"] post:post[@"post_id"]];
        }
        
        //Count the number of videos for the transcoding progress
        numberOfVideos = numberOfVideos + (((PHAsset *)post[@"asset"]).mediaType == PHAssetMediaTypeVideo ? 1 : 0);
    }
    
    __block __weak FRSUploadPostAssetCompletionBlock weakHandleAssetCreation = nil;

    //This is done recursively because we can't have too many videos trancoding at a time, otherwise iOS will scream at us
    FRSUploadPostAssetCompletionBlock handleAssetCreation = ^void(NSDictionary *postUploadMeta, BOOL isVideo, NSInteger fileSize, NSError *error) {
        toComplete++;
        totalFileSize += fileSize;
        if(isVideo) {
            totalVideoFilesSize += fileSize;
        } else {
            totalImageFilesSize += fileSize;
        }
        
        if(!error) {
            [self.uploadMeta addObject:postUploadMeta];
            currentIndex++;
            
            //If the upload errors at some point and state is reset,
            //this count will never add up, hence will not start uploading
            if([self.uploadMeta count] == [posts count]) {
                startUploads();
            } else {
                
                //Needed for recursive defintion
                FRSUploadPostAssetCompletionBlock strongHandleAssetCreation = weakHandleAssetCreation;
                
                //Recursive call to block to process next post
                [self createAssetForUpload:posts[currentIndex][@"asset"]
                                   withKey:posts[currentIndex][@"key"]
                                withPostID:posts[currentIndex][@"post_id"]
                                completion:strongHandleAssetCreation];
            }
        } else {
            [self uploadDidErrorWithError:error];
        }
    };
    
    weakHandleAssetCreation = handleAssetCreation;
    
    [self createAssetForUpload:posts[currentIndex][@"asset"]
                       withKey:posts[currentIndex][@"key"]
                    withPostID:posts[currentIndex][@"post_id"]
                    completion:handleAssetCreation];
}

/**
 Retries an upload with the current uploads in state. Before attempting to retry, the required
 assets will be fetched, then a new upload will be started
 */
- (void)retryUpload {
    NSMutableArray *posts = [NSMutableArray new];

    //Generate posts from managed objects in coredata
    for (NSString *uploadPost in [self.managedObjects allKeys]) {
        FRSUpload *upload = [self.managedObjects objectForKey:uploadPost];

        if (upload.key && upload.uploadID && upload.resourceURL && [upload.completed boolValue] == FALSE) {
            PHFetchResult *assetArray = [PHAsset fetchAssetsWithLocalIdentifiers:@[ upload.resourceURL ] options:nil];
            
            //Asset no longer available, skip this item
            if([assetArray count] == 0) continue;
            
            [posts addObject:@{
                               @"post_id": upload.uploadID,
                               @"key": upload.key,
                               @"asset": [assetArray firstObject]
                               }];
        }
    }
    
    if(posts.count > 0){
        //Start new uploads once we've retrieved posts and assets
        [self startNewUploadWithPosts:posts];
    }
}



/**
 Cancels upload in progress

 @param withForce BOOL value passed if the cancel should clear all of the core data uploads as well to do a full erase
 */
- (void)cancelUploadWithForce:(BOOL)withForce {
    [self resetState];
    [self clearCachedUploads];
    [self.transferManager cancelAll];
    
    if(withForce == YES) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSUpload"];
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        NSError *deleteError;
        //Delete all FRSUploads
        [self.context executeRequest:delete error:&deleteError];
    }
}

/**
 Utiltiy to create the dictionary representing the asset being uploaded.

 @param path Path in local filesystem for the asset
 @param key AWS Key for the post
 @param post ID of the post
 @return NSDictionary representing the post's asset
 */
- (NSDictionary *)uploadDictionaryForPost:(NSString *)path key:(NSString *)key post:(NSString *)post {
    return @{
             @"path": path,
             @"key": key,
             @"post_id": post
             };
}


/**
 Starts the AWS upload for the passed post. If completed, will set the managed object to complete and return on completion block.

 @param postID ID of the post being uploaded
 @param path File Path string in local system
 @param key AWS Key for the media file
 @param completion Completion block returning success or error upload
 */
- (void)addUploadForPost:(NSString *)postID andPath:(NSString *)path andKey:(NSString *)key completion:(FRSAPIDefaultCompletionBlock)completion {
    //Speed tracking
    __block double lastUploadSpeed;
    __block NSDate *lastDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    
    //Configure AWS upload object
    AWSS3TransferManagerUploadRequest *upload = [AWSS3TransferManagerUploadRequest new];
    upload.contentType = [path containsString:@".jpeg"] ? @"image/jpeg" :  @"video/mp4";
    upload.body = [NSURL fileURLWithPath:path];
    upload.key = key;
    upload.metadata = @{ @"post_id" : postID };
    upload.bucket = [EndpointManager sharedInstance].currentEndpoint.amazonS3Bucket;
    
    //Progress handler
    upload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        //Send progress to be notified
        [self updateProgress:bytesSent];
        
        //Get time interval since lastDate (set at the bottom of this method)
        NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastDate];
        //Calculate speed at current runtime
        float currentUploadSpeed = (bytesSent / 1024.0) / secondsSinceLastUpdate; //kBps
        
        if (lastUploadSpeed > 0) {
            uploadSpeed = (currentUploadSpeed + lastUploadSpeed) / 2;
            lastUploadSpeed = uploadSpeed;
        } else {
            uploadSpeed = currentUploadSpeed;
        }
        
        lastDate = [NSDate date];
    };
    
    //This actually starts the upload and takes a completion block when the upload is done
    [[self.transferManager upload:upload] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
        if (task.error) {
            completion(nil, task.error);
        } else if (task.result) {
            for (NSDictionary *meta in self.uploadMeta) {
                if ([meta[@"post_id"] isEqualToString:postID]) {
                    [weakSelf.uploadMeta removeObject:meta];
                    break;
                }
            }
            
            [weakSelf trackDebugWithMessage:[NSString stringWithFormat:@"%@ completed", postID]];
            completed++;
            FRSUpload *upload = [weakSelf.managedObjects objectForKey:postID];
            
            //Handle object in cache if it exists
            if (upload) {
                [weakSelf.context performBlock:^{
                    upload.completed = @(TRUE);
                    [weakSelf.context save:nil];
                    completion(nil, nil);
                    //Remove after completing
                    [weakSelf.managedObjects removeObjectForKey:postID];
                }];
            } else {
                completion(nil, nil);
            }
            
        }
        
        return nil;
    }];
}


/**
 Creates FRSUpload CoreData object and saves to context, and also saves to 
 manager's state to keep track of all managed objects currently being uploaded.

 @param asset PHAsset assocaited with upload
 @param key AWS File key assocaited with upload
 @param post Post ID associated with upload
 */
- (void)createUploadWithAsset:(PHAsset *)asset key:(NSString *)key post:(NSString *)post {
    if (!self.managedObjects) {
        self.managedObjects = [[NSMutableDictionary alloc] init];
    }
    
    FRSUpload *upload = [FRSUpload MR_createEntityInContext:self.context];
    upload.resourceURL = asset.localIdentifier;
    upload.key = key;
    upload.uploadID = post;
    upload.completed = @(FALSE);
    upload.creationDate = [NSDate date];
    
    [self.context performBlock:^{
        [self.context save:Nil];
    }];
    
    //After saving to context, save to class's state as well for later use
    [self.managedObjects setObject:upload forKey:post];
}

/**
 Broadcasts failure upload notification to the app and also formally cancels the upload process.
 When this is called, the cancel is called without a force so that it can be retried at a later time. Last, this
 method also checks if there's no upload currently in progress to avoid re-broadcasting the failure.

 @param error NSError representing the error, should pass a localizedDescription to be presented to the user
 */
- (void)uploadDidErrorWithError:(NSError *)error {
    //No upload in progress, added this check due to this being called in a callback cycle
    if(toComplete == 0) return;
    
    //Do this before cancelling so we can use the active state variables
    NSMutableDictionary *uploadErrorSummary = [@{ @"error_message" : error.localizedDescription } mutableCopy];
    
    if (uploadSpeed > 0) {
        [uploadErrorSummary setObject:@(uploadSpeed) forKey:@"upload_speed_kBps"];
    }
    
    //Convert from bytes to megabytes
    [uploadErrorSummary setObject:@{ @"video" : [NSString stringWithFormat:@"%lluMB", totalVideoFilesSize / 1024 / 1024],
                                     @"photo" : [NSString stringWithFormat:@"%lluMB", totalImageFilesSize / 1024 / 1024] }
                           forKey:@"files"];
    
    //Cancel the upload
    [self cancelUploadWithForce:NO];
    
    if(!error || !error.localizedDescription){
        error = [NSError errorWithMessage:@"Please contact support@fresconews for assistance or use our in-app chat to get in contact with us."];
    }
    
    [FRSTracker track:uploadError parameters:uploadErrorSummary];
    [[NSNotificationCenter defaultCenter] postNotificationName:FRSUploadNotification object:Nil userInfo:@{ @"type" : @"failure", @"error": error }];
}

#pragma mark - Tracking

/**
 Tracks a debug message, and the upload speed if it's currently set in state
 
 @param message Message to pass along to the mobile event
 */
- (void)trackDebugWithMessage:(NSString *)message {
    NSMutableDictionary *uploadErrorSummary = [@{ @"debug_message" : message } mutableCopy];
    
    if (uploadSpeed > 0) {
        [uploadErrorSummary setObject:@(uploadSpeed) forKey:@"upload_speed_kBps"];
    }
    
    [FRSTracker track:uploadDebug parameters:uploadErrorSummary];
}

@end
