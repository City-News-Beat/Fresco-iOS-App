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

@implementation FRSUploadManager
@synthesize isRunning = _isRunning, managedUploads = _managedUploads;

-(void)checkAndStart {
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"completed", @(FALSE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUpload"];
    signedInRequest.predicate = signedInPredicate;
    
    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; // temp (replace with internal or above method
    
    // no need to sort response, because theoretically there is 1
    NSError *fetchError;
    NSArray *uploads = [context executeFetchRequest:signedInRequest error:&fetchError];
    NSLog(@"UPLOADS: %@", uploads);
    
    if ([uploads count] > 0) {
        _isRunning = TRUE;
    }
    
    for (FRSUpload *upload in uploads) {
        [self.managedUploads addObject:upload];
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
                    [self addMultipartTaskForAsset:asset urls:dest post:@{@"key":upload.key, @"uploadId":upload.uploadID}];
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
                        [self addTaskForImageAsset:asset url:[NSURL URLWithString:urls[0]] post:@{@"key":upload.key, @"uploadId":upload.uploadID}];
                    }
                }
                else {
                    continue;
                }
            }
        }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)commonInit {
    _tasks = [[NSMutableArray alloc] init];
    _currentTasks = [[NSMutableArray alloc] init];
    _etags = [[NSMutableArray alloc] init];
    _managedUploads = [[NSMutableArray alloc] init];
    
    weakSelf = self;
    
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
            
            [self addMultipartTaskForAsset:currentAsset urls:urls post:currentPost];
            
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
            
        [self.managedUploads addObject:upload];


        }
        else {
            [self addTaskForImageAsset:currentAsset url:[NSURL URLWithString:currentPost[@"upload_urls"][0]] post:currentPost];
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

-(void)addMultipartTaskForAsset:(PHAsset *)asset urls:(NSArray *)urls post:(NSDictionary *)post {
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
                        
                        [self markAsComplete];

                        _currentTasks = [[NSMutableArray alloc] init];
                    }
                }];
            }
            else {
                    isRunning = FALSE;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"failure"}];
                    [self markAsComplete];

            }
        }];
        
        [self addTask:multipartTask];
    }];
}

-(void)addTaskForImageAsset:(PHAsset *)asset url:(NSURL *)url post:(NSDictionary *)post {
    toComplete++;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (!_posts) {
            _contentSize += [imageData length];
        }

        FRSUploadTask *task = [[FRSUploadTask alloc] init];

        [task createUploadFromData:imageData destination:url progress:^(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            [self uploadedData:bytesSent];
        } completion:^(id task, NSData *responseData, NSError *error, BOOL success, NSURLResponse *response) {
            if (success) {
                if (success) {
                    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
                    NSString *eTag = headers[@"Etag"];
                    
                    NSMutableDictionary *postCompletionDigest = [[NSMutableDictionary alloc] init];
                    
                    if (!eTag || !post[@"uploadId"] || !post[@"key"] || !post[@"post_id"]) {
                        isComplete++;
                        [self next:task];
                        return;
                    }
                    
                    postCompletionDigest[@"eTags"] = @[eTag];
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
