//
//  FRSUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 7/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadManager.h"
#import "FRSAPIClient.h"
#import "Fresco.h"
#import "MagicalRecord.h"
#import "FRSUpload+CoreDataProperties.h"
#import "FRSAppDelegate.h"
#import "FRSTracker.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@implementation FRSUploadManager
@synthesize isRunning = _isRunning, managedUploads = _managedUploads;

-(void)checkAndStart {
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (![[FRSAPIClient sharedClient] isAuthenticated]) {
        didFinish = TRUE;
        isRunning = FALSE;
        return;
    }
    
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"completed", @(FALSE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUpload"];
    signedInRequest.predicate = signedInPredicate;
    
    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; // temp (replace with internal or above method
    
    // no need to sort response, because theoretically there is 1
    NSError *fetchError;
    NSArray *uploads = [context executeFetchRequest:signedInRequest error:&fetchError];
    NSLog(@"UPLOADS: %@", uploads);
    
    if (uploads.count == 0) {
        didFinish = TRUE;
    }

    
    for (FRSUpload *upload in uploads) {
        
        NSTimeInterval sinceStart = [upload.creationDate timeIntervalSinceNow];
        sinceStart *= -1;
        
        if (sinceStart >= (24 * 60 * 60)) {
            
            [delegate.managedObjectContext performBlock:^{
                upload.completed = @(TRUE);
                [delegate saveContext];
            }];
            continue;
        }
        
        [self.managedUploads addObject:upload];
        _isRunning = TRUE;
            NSArray *urls = upload.destinationURLS;

            if (urls.count > 1) {
                
                NSString *resourceURL = upload.resourceURL;
                NSMutableArray *dest = [[NSMutableArray alloc] init];
                
                for (NSString *partURL in urls) {
                    [dest addObject:[NSURL URLWithString:partURL]];
                }
                
                PHFetchResult* assets =[PHAsset fetchAssetsWithLocalIdentifiers:@[resourceURL] options:nil];
                __block PHAsset *asset;
                [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    asset = obj;
                }];
                
                if (asset) {
                    [self addMultipartTaskForAsset:asset urls:dest post:@{@"key":upload.key, @"uploadId":upload.uploadID} upload:upload];
                }
                else {
                    continue;
                }
            }
            else {
                
                NSString *resourceURL = upload.resourceURL;
                
                PHFetchResult* assets =[PHAsset fetchAssetsWithLocalIdentifiers:@[resourceURL] options:nil];
                __block PHAsset *asset;
                [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    asset = obj;
                }];
                
                if (asset) {
                    if (urls[0]) {
                        _isRunning = TRUE;
                        [self addTaskForImageAsset:asset url:[NSURL URLWithString:urls[0]] post:@{@"key":upload.key, @"uploadId":upload.uploadID} upload:upload];
                    }
                }
                else {
                    continue;
                }
            }
        }
}

-(void)appWillResignActive {
    
    if (didFinish) {
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)commonInit {
    _tasks = [[NSMutableArray alloc] init];
    _currentTasks = [[NSMutableArray alloc] init];
    _etags = [[NSMutableArray alloc] init];
    _managedUploads = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSDismissUpload" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        didFinish = TRUE;
        isRunning = FALSE;
        [self markAsComplete];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FRSRetryUpload" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        
        if (isRunning || didFinish) {
            return;
        }
        
        [self markAsInComplete];

        totalBytesSent = 0;
        _tasks = [[NSMutableArray alloc] init];
        _currentTasks = [[NSMutableArray alloc] init];
        _etags = [[NSMutableArray alloc] init];
        isStarted = FALSE;
        isRunning = TRUE;
        
        if (_gallery) {
            [self startUploadProcess];
        }
    }];
    
    if (_gallery) {
        [self startUploadProcess];
    }
}

-(void)startUploadProcess {
    
    if (!_posts) {
        self.managedUploads = [[NSMutableArray alloc] init];
        [self checkAndStart];
        
        return;
    }
    
    toComplete = 0;
    isComplete = 0;

    if (!_posts) {
        return;
    }
    
    for (int i = 0; i < _posts.count; i++) {
        PHAsset *currentAsset = _assets[i];
        NSDictionary *currentPost = _posts[i];
        
        if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
            
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            
            for (NSString *partURL in currentPost[@"upload_urls"]) {
                [urls addObject:[NSURL URLWithString:partURL]];
            }
            
            FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
            FRSUpload *upload = [FRSUpload MR_createEntityInContext:delegate.managedObjectContext];
            NSMutableArray *urlStrings = [[NSMutableArray alloc] init];
            for (NSURL *url in urls) {
                [urlStrings addObject:url.absoluteString];
            }
            
            upload.destinationURLS = urlStrings;
            upload.resourceURL = currentAsset.localIdentifier;
            upload.creationDate = [NSDate date];
            upload.completed = @(FALSE);
            upload.key = currentPost[@"key"];
            upload.uploadID = currentPost[@"uploadId"];
            
            [delegate.managedObjectContext performBlock:^{
                [delegate saveContext];
            }];
            
            [self addMultipartTaskForAsset:currentAsset urls:urls post:currentPost upload:upload];

            [self.managedUploads addObject:upload];


        }
        else {
            FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
            FRSUpload *upload = [FRSUpload MR_createEntityInContext:delegate.managedObjectContext];
            NSMutableArray *urlStrings = [[NSMutableArray alloc] init];;
            
            if (currentPost[@"upload_urls"][0]) {
                [urlStrings addObject:currentPost[@"upload_urls"][0]];
            }
            
            upload.destinationURLS = urlStrings;
            upload.resourceURL = currentAsset.localIdentifier;
            upload.creationDate = [NSDate date];
            upload.completed = @(FALSE);
            upload.key = currentPost[@"key"];
            upload.uploadID = currentPost[@"uploadId"];

            [delegate.managedObjectContext performBlock:^{
                [delegate saveContext];
            }];
            
            [self.managedUploads addObject:upload];
            [self addTaskForImageAsset:currentAsset url:[NSURL URLWithString:currentPost[@"upload_urls"][0]] post:currentPost upload:upload];
        }
    }
}

-(void)addTask:(FRSUploadTask *)task {
    [_tasks addObject:task];
    
    
    if (!isStarted) {
        [self start];
    }
}

-(void)start {
    if (_tasks.count == 0) {
        return;
    }
    
    if (isStarted) {
        return;
    }
    
    NSLog(@"STARTING UPLOAD");
    
    isStarted = TRUE;
    
    FRSUploadTask *task = [_tasks firstObject];
    [task start];
    [_tasks removeObject:task];
}

-(void)uploadedData:(int64_t)bytes {
    totalBytesSent += bytes;
    NSLog(@"PROGRESS: %f", (totalBytesSent * 1.0) / (_contentSize * 1.0));
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"progress", @"percentage":@((totalBytesSent * 1.0) / (_contentSize * 1.0))}];
}

-(void)addMultipartTaskForAsset:(PHAsset *)asset urls:(NSArray *)urls post:(NSDictionary *)post upload:(FRSUpload *)upload {
    toComplete++;
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    options.progressHandler =  ^(double progress,NSError *error,BOOL* stop, NSDictionary* dict) {
        NSLog(@"progress %lf",progress);  //never gets called
    };
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        AVURLAsset* myAsset = (AVURLAsset*)avasset;
        NSNumber *size;
        [myAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];

        if (!_posts) {
            _contentSize += [size unsignedLongLongValue];
        }
        
        FRSMultipartTask *multipartTask = [[FRSMultipartTask alloc] init];
        multipartTask.managedObject = upload;
        
        [multipartTask createUploadFromSource:myAsset.URL destinations:urls progress:^(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            [self uploadedData:bytesSent];
        } completion:^(id task, NSData *responseData, NSError *error, BOOL success, NSURLResponse *response) {
            if (success) {
                NSMutableDictionary *postCompletionDigest = [[NSMutableDictionary alloc] init];
                postCompletionDigest[@"eTags"] = multipartTask.eTags;
                postCompletionDigest[@"uploadId"] = post[@"uploadId"];
                postCompletionDigest[@"key"] = post[@"key"];
                [[FRSAPIClient sharedClient] completePost:post[@"post_id"] params:postCompletionDigest completion:^(id responseObject, NSError *error) {
                    
                    NSLog(@"POST COMPLETED: %@", (error == Nil) ? @"TRUE" : @"FALSE");
                    
                    if (!error) {
                        isComplete++;
                        [self next:task];
                    }
                    else {
                        
                        if (error.localizedDescription) {
                            [FRSTracker track:@"Upload Error" parameters:@{@"error_message":(error.localizedDescription) ? error.localizedDescription : @""}];
                        }

                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"failure"}];
                        isRunning = FALSE;
                        _tasks = [[NSMutableArray alloc] init];
                        
                        for (FRSUploadTask *task in _currentTasks) {
                            [task stop];
                        }
                        
                        [self markAsComplete];

                        _currentTasks = [[NSMutableArray alloc] init];
                    }
                }];
            }
            else {
                    isRunning = FALSE;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"failure"}];
                    [self markAsComplete];
                [FRSTracker track:@"Upload Error" parameters:@{@"error_message":(error.localizedDescription) ? error.localizedDescription : @""}];
            }
        }];
        
        [self addTask:multipartTask];
    }];
}

-(void)addTaskForImageAsset:(PHAsset *)asset url:(NSURL *)url post:(NSDictionary *)post upload:(FRSUpload *)upload {
    toComplete++;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (!_posts) {
            _contentSize += [imageData length];
        }

        FRSUploadTask *task = [[FRSUploadTask alloc] init];
        task.managedObject = upload;
        
        [task createUploadFromData:imageData destination:url progress:^(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            [self uploadedData:bytesSent];
        } completion:^(id task, NSData *responseData, NSError *error, BOOL success, NSURLResponse *response) {
            if (success) {
                if (success) {
                    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
                    NSString *eTag = headers[@"Etag"];
                    
                    NSMutableDictionary *postCompletionDigest = [[NSMutableDictionary alloc] init];
                    
                    postCompletionDigest[@"eTags"] = @[(eTag) ? eTag : @""];
                    postCompletionDigest[@"uploadId"] = post[@"uploadId"];
                    postCompletionDigest[@"key"] = post[@"key"];
                    [[FRSAPIClient sharedClient] completePost:post[@"post_id"] params:postCompletionDigest completion:^(id responseObject, NSError *error) {
                        NSLog(@"POST COMPLETED: %@", (error == Nil) ? @"TRUE" : @"FALSE");
                        
                        if (!error) {
                            isComplete++;
                            [self next:task];
                        }
                        else {
                            if (!_posts) {
                                isComplete++;
                                [self next:task];
                                return;
                            }
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"failure"}];
                            isRunning = FALSE;
                            _tasks = [[NSMutableArray alloc] init];
                            
                            for (FRSUploadTask *task in _currentTasks) {
                                [task stop];
                            }
                            [FRSTracker track:@"Upload Error" parameters:@{@"error_message":(error.localizedDescription) ? error.localizedDescription : @""}];

                            _currentTasks = [[NSMutableArray alloc] init];
                            [self markAsComplete];
                        }
                    }];
                }
            }
            else {
                NSLog(@"%@", error);
                isRunning = FALSE;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"failure"}];
                [self markAsComplete];
                [FRSTracker track:@"Upload Error" parameters:@{@"error_message":(error.localizedDescription) ? error.localizedDescription : @""}];
            }
        }];
        
        [self addTask:task];
    }];
}

-(void)markAsComplete {
    FRSAppDelegate *delegate = (FRSAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [delegate.managedObjectContext performBlock:^{
        for (FRSUpload *upload in self.managedUploads) {
            upload.completed = @(TRUE);
        }
        [delegate saveContext];
    }];
    
}

-(void)markAsInComplete {
    FRSAppDelegate *delegate = (FRSAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [delegate.managedObjectContext performBlock:^{
        for (FRSUpload *upload in self.managedUploads) {
            upload.completed = @(FALSE);
        }
        [delegate saveContext];
    }];
    
}

-(void)pause {
    
}

-(void)resume {
    
}

-(void)next:(FRSUploadTask *)task {
    
    if (_tasks.count > 0) {
        FRSUploadTask *theTask = [_tasks firstObject];
        [theTask start];
        [_tasks removeObject:theTask];
        NSLog(@"STARTING NEXT %@", theTask);
    }
    else {
        invalidated = TRUE;
        
        if (toComplete == isComplete) {
            didFinish = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"completion"}];
            NSLog(@"GALLERY CREATION COMPLETE");
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self markAsComplete];
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

-(instancetype)initWithGallery:(NSDictionary *)gallery assets:(NSArray *)assets {
    self = [super init];
    
    if (self) {
        _assets = assets;
        _gallery = gallery;
        
        _posts = _gallery[@"posts_new"];
        [self commonInit];
    }
    
    return self;
}

@end
