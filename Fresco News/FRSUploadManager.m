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
#import "SDAVAssetExportSession.h"
#import "EndpointManager.h"
#import "NSDate+ISO.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@implementation FRSUploadManager

static NSDate *lastDate;

+ (id)sharedInstance {
    static FRSUploadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(notifyExit:) name:UIApplicationWillResignActiveNotification object:nil];

    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.currentGalleryID = @"";
        [self commonInit];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTranscodingProgress:(float)progress withPostID:(NSString *)postID {
    [self.transcodingProgressDictionary setValue:[NSNumber numberWithFloat:progress] forKey:postID];
    __block float transcodingProgress = 0;
    [self.transcodingProgressDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL *stop) {
      transcodingProgress += value.floatValue;
    }];

    float totalTranscodingProgress = 0.5f * transcodingProgress / numberOfVideos;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate"
                                                        object:nil
                                                      userInfo:@{ @"type" : @"progress",
                                                                  @"percentage" : @(totalTranscodingProgress) }];
}

- (void)notifyExit:(NSNotification *)notification {
    if (completed == toComplete || toComplete == 0) {
        return;
    }

    [FRSTracker track:uploadClose
           parameters:@{ @"percent_complete" : @(lastProgress),
                         @"gallery_id" : _currentGalleryID }];
}

- (void)checkCachedUploads {
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"completed", @(FALSE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUpload"];
    signedInRequest.predicate = signedInPredicate;

    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [[(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] coreDataController] managedObjectContext]; // temp (replace with internal or above method

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

- (void)retryUpload {
    currentIndex = 0;
    totalFileSize = 0;
    uploadedFileSize = 0;
    lastProgress = 0;
    toComplete = 0;
    totalImageFilesSize = 0;
    totalVideoFilesSize = 0;
    completed = 0;
    numberOfVideos = 0;
    self.uploadMeta = [[NSMutableArray alloc] init];
    self.transcodingProgressDictionary = [[NSMutableDictionary alloc] init];

    for (NSString *uploadPost in [self.managedObjects allKeys]) {
        FRSUpload *upload = [self.managedObjects objectForKey:uploadPost];
        if ([upload.completed boolValue] == NO) {
            if (upload.key && upload.uploadID && upload.resourceURL) {
                PHFetchResult *assetArray = [PHAsset fetchAssetsWithLocalIdentifiers:@[ upload.resourceURL ] options:nil];
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

- (void)commonInit {
    if (self.uploadMeta) {
        [self.uploadMeta removeAllObjects];
    }
    self.currentUploads = [[NSMutableArray alloc] init];
    self.completedUploads = 0;
    self.uploadMeta = [[NSMutableArray alloc] init];
    self.transcodingProgressDictionary = [[NSMutableDictionary alloc] init];
    [self startAWS];
    currentIndex = 0;
    numberOfVideos = 0;

    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = delegate.coreDataController.managedObjectContext;

    [self subscribeToEvents];
}

- (void)subscribeToEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSRetryUpload"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                    [self retryUpload];
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSDismissUpload"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                    for (NSString *uploadPost in [self.managedObjects allKeys]) {
                                                        FRSUpload *upload = [self.managedObjects objectForKey:uploadPost];

                                                        [self.context performBlock:^{
                                                          upload.completed = @(TRUE);
                                                          [self.context save:Nil];
                                                        }];
                                                    }

                                                  }];
}

- (void)createUploadWithAsset:(PHAsset *)asset token:(NSString *)token post:(NSString *)post {
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

- (void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID {
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

        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, UIImageOrientation orientation, NSDictionary *_Nullable info) {
                                                      NSString *tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"] stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpeg"]];

                                                      // write data to temp path (background thread, async)
                                                      [imageData writeToFile:tempPath atomically:NO];

                                                      unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil] fileSize];
                                                      totalFileSize += fileSize;
                                                      totalImageFilesSize += fileSize;
                                                      NSArray *uploadMeta = @[ tempPath, revisedToken, postID ];

                                                      [self.uploadMeta addObject:uploadMeta];
                                                      if (self.uploadMeta.count == toComplete) {
                                                          [self startUploads];
                                                      }
                                                    }];
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        numberOfVideos++;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                        options:nil
                                                  resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
                                                    // create temp location to move data (PHAsset can not be weakly linked to)
                                                    NSString *tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"] stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
                                                    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:avasset];
                                                    encoder.delegate = self;
                                                    encoder.outputFileType = AVFileTypeMPEG4;
                                                    encoder.outputURL = [NSURL fileURLWithPath:tempPath];
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
                                                    encoder.postID = postID;

                                                    NSLog(@"STARTING EXPORT");
                                                    [encoder exportAsynchronouslyWithCompletionHandler:^{
                                                      NSLog(@"ENDING EXPORT %@", encoder.error);
                                                      unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil] fileSize];
                                                      totalFileSize += fileSize;
                                                      totalVideoFilesSize += fileSize;
                                                      NSArray *uploadMeta = @[ tempPath, revisedToken, postID ];
                                                      [self.uploadMeta addObject:uploadMeta];
                                                      if (self.uploadMeta.count == toComplete) {
                                                          [self startUploads];
                                                      }
                                                    }];
                                                  }];
    }
}

- (void)startUploads {
    for (NSArray *request in self.uploadMeta) {
        [self addUploadForPost:request[1]
                           url:request[0]
                        postID:request[2]
                    completion:^(id responseObject, NSError *error) {
                        [[NSFileManager defaultManager] removeItemAtPath:request[0] error:nil];
                    }];
    }
}

- (void)restart {
    if (completed == toComplete) {
        // complete
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{ @"type" : @"completion" }];
        currentIndex = 0;
        totalFileSize = 0;
        totalImageFilesSize = 0;
        totalVideoFilesSize = 0;
        uploadedFileSize = 0;
        lastProgress = 0;
        toComplete = 0;
        completed = 0;
        numberOfVideos = 0;
        self.uploadMeta = [[NSMutableArray alloc] init];
        self.transcodingProgressDictionary = [[NSMutableDictionary alloc] init];

        NSMutableDictionary *uploadErrorSummary = [@{ @"debug_message" : @"Upload completed" } mutableCopy];
        if (uploadSpeed > 0) {
            [uploadErrorSummary setObject:@(uploadSpeed) forKey:@"upload_speed_kBps"];
        }

        [FRSTracker track:uploadDebug parameters:uploadErrorSummary];
    }
}

- (void)startAWS {
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:[EndpointManager sharedInstance].currentEndpoint.amazonS3AccessKey secretKey:[EndpointManager sharedInstance].currentEndpoint.amazonS3SecretKey];

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWS_REGION credentialsProvider:credentialsProvider];

    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (void)addUploadForPost:(NSString *)postID url:(NSString *)body postID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion {
    __block int uploadUpdates;

    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *upload = [AWSS3TransferManagerUploadRequest new];

    if ([body containsString:@".jpeg"]) {
        upload.contentType = @"image/jpeg";
    } else {
        upload.contentType = @"video/mp4";
    }

    upload.body = [NSURL fileURLWithPath:body];
    upload.key = postID;
    upload.metadata = @{ @"post_id" : post };
    upload.bucket = [EndpointManager sharedInstance].currentEndpoint.amazonS3Bucket;

    /*
     MixPanel speed tracking
     */
    lastDate = [NSDate date];

    upload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {

      [self updateProgress:bytesSent];

      NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastDate];
      float percentageOfSecond = 1 / secondsSinceLastUpdate;

      float kBPerSecond = bytesSent * percentageOfSecond * 1.0 / 1024 /* kb */;
      float averagekBPerSecond = kBPerSecond;

      if (uploadUpdates > 0) {
          averagekBPerSecond = uploadSpeed / uploadUpdates;
          averagekBPerSecond = ((averagekBPerSecond * uploadUpdates) + kBPerSecond) / (uploadUpdates + 1);
      }

      uploadSpeed = averagekBPerSecond;

      lastDate = [NSDate date];
      uploadUpdates++;
    };
    __weak typeof(self) weakSelf = self;

    [[transferManager upload:upload] continueWithBlock:^id(AWSTask *task) {

      if (task.error) {
          NSLog(@"Upload Error: %@", task.error);
          [weakSelf uploadDidErrorWithError:task.error];
      }

      if (task.result) {
          FRSUpload *upload = [self.managedObjects objectForKey:post];

          if (upload) {
              [self.context performBlock:^{
                upload.completed = @(YES);
                [self.context save:nil];
                completion(nil, nil);

                NSArray *metaToRemove = nil;
                for (NSArray *meta in self.uploadMeta) {
                    if ([meta[2] isEqualToString:postID]) {
                        metaToRemove = meta;
                    }
                }
                if (metaToRemove) {
                    [self addUploadForPost:metaToRemove[1]
                                       url:metaToRemove[0]
                                    postID:metaToRemove[2]
                                completion:^(id responseObject, NSError *error) {
                                  [[NSFileManager defaultManager] removeItemAtPath:metaToRemove[0] error:nil];
                                  [self.uploadMeta removeObject:metaToRemove];
                                }];
                }
              }];
          }

          completed++;
          currentIndex++;
          [self taskDidComplete:task];
          [self restart];
      }

      return nil;
    }];
}

- (void)updateProgress:(int64_t)bytes {
    uploadedFileSize += bytes;

    float progress;
    if (numberOfVideos > 0) {
        progress = 0.5f + (0.5f * (uploadedFileSize * 1.0) / (totalFileSize * 1.0));
    } else {
        progress = (uploadedFileSize * 1.0) / (totalFileSize * 1.0);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate"
                                                        object:nil
                                                      userInfo:@{ @"type" : @"progress",
                                                                  @"percentage" : @(progress) }];
}

- (void)uploadDidErrorWithError:(NSError *)error {
    NSMutableDictionary *uploadErrorSummary = [@{ @"error_message" : error.localizedDescription } mutableCopy];
    if (uploadSpeed > 0) {
        [uploadErrorSummary setObject:@(uploadSpeed) forKey:@"upload_speed_kBps"];
    }
    NSString *videoFilesSize = [NSString stringWithFormat:@"%lluMB", totalVideoFilesSize];
    NSString *imageFilesSize = [NSString stringWithFormat:@"%lluMB", totalImageFilesSize];

    NSDictionary *filesDictionary = @{ @"video" : videoFilesSize,
                                       @"photo" : imageFilesSize };
    [uploadErrorSummary setObject:filesDictionary forKey:@"files"];

    [FRSTracker track:uploadError parameters:uploadErrorSummary];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:Nil userInfo:@{ @"type" : @"failure" }];
}

- (void)taskDidComplete:(AWSTask *)task {
}

- (void)fetchAddressFromLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __block NSString *address;

    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *placemark = [placemarks objectAtIndex:0];

                         NSString *thoroughFare = @"";
                         if ([placemark thoroughfare] && [[placemark thoroughfare] length] > 0) {
                             thoroughFare = [[placemark thoroughfare] stringByAppendingString:@", "];

                             if ([placemark subThoroughfare]) {
                                 thoroughFare = [[[placemark subThoroughfare] stringByAppendingString:@" "] stringByAppendingString:thoroughFare];
                             }
                         }

                         address = [NSString stringWithFormat:@"%@%@, %@", thoroughFare, [placemark locality], [placemark administrativeArea]];
                         completion(address, Nil);
                     } else {
                         completion(@"No address found.", Nil);
                         [FRSTracker track:addressError parameters:@{ @"coordinates" : @[ @(location.coordinate.longitude), @(location.coordinate.latitude) ] }];
                     }

                   }];
}

- (NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback {
    NSMutableDictionary *digest = [[NSMutableDictionary alloc] init];

    [self fetchAddressFromLocation:asset.location
                        completion:^(id responseObject, NSError *error) {

                          digest[@"address"] = responseObject;
                          digest[@"lat"] = @(asset.location.coordinate.latitude);
                          digest[@"lng"] = @(asset.location.coordinate.longitude);

                          digest[@"captured_at"] = [(NSDate *)asset.creationDate ISODateWithTimeZone];

                          if (asset.mediaType == PHAssetMediaTypeImage) {
                              digest[@"contentType"] = @"image/jpeg";
                              [self fetchFileSizeForImage:asset
                                                 callback:^(NSInteger size, NSError *err) {
                                                   digest[@"fileSize"] = @(size);
                                                   digest[@"chunkSize"] = @(size);
                                                   callback(digest, err);
                                                 }];
                          } else {
                              [self fetchFileSizeForVideo:asset
                                                 callback:^(NSInteger size, NSError *err) {
                                                   digest[@"fileSize"] = @(size);
                                                   digest[@"chunkSize"] = @(chunkSize * megabyteDefinition);
                                                   digest[@"contentType"] = @"video/mp4";
                                                   callback(digest, err);
                                                 }];
                          }
                        }];

    return digest;
}

- (void)fetchFileSizeForVideo:(PHAsset *)video callback:(FRSAPISizeCompletionBlock)callback {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;

    [[PHImageManager defaultManager] requestAVAssetForVideo:video
                                                    options:options
                                              resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                                                if ([asset isKindOfClass:[AVURLAsset class]]) {
                                                    AVURLAsset *urlAsset = (AVURLAsset *)asset;

                                                    NSNumber *size;
                                                    NSError *fetchError;

                                                    [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:&fetchError];
                                                    callback([size integerValue], fetchError);
                                                }
                                              }];
}

- (void)fetchFileSizeForImage:(PHAsset *)image callback:(FRSAPISizeCompletionBlock)callback {
    [[PHImageManager defaultManager] requestImageDataForAsset:image
                                                      options:nil
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                  float imageSize = imageData.length;
                                                  callback([@(imageSize) integerValue], Nil);
                                                }];
}

- (void)setUploadsCountToComplete:(int)uploadsCount {
    toComplete = uploadsCount;
}

@end
