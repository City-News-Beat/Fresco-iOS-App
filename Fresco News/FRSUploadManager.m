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

#import "Fresco.h"

@implementation FRSUploadManager

+ (id)sharedUploader {
    
    static FRSUploadManager *sharedUploader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUploader = [[self alloc] init];
    });
    
    return sharedUploader;
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
}


-(void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID {
    if (!asset || !token) {
        return;
    }
    
    NSString *revisedToken = [@"raw/" stringByAppendingString:token];

    if (asset.mediaType == PHAssetMediaTypeImage) {
        
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:Nil resultHandler:^void(UIImage *image, NSDictionary *info) {
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpeg"]];
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:Nil];
        
        // write data to temp path (background thread, async)
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
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
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
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
    
    if (currentIndex+1 == self.uploadMeta.count) {
        // complete
        NSLog(@"UPLOAD PROCESS COMPLETE");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"completion"}];
        
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
    upload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        [self updateProgress:bytesSent];
    };
    __weak typeof (self) weakSelf = self;
    
    [[transferManager upload:upload] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            [weakSelf uploadDidErrorWithError:task.error];
        }
        
        if (task.result) {
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
    if (progress - lastProgress >= .03) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSUploadUpdate" object:nil userInfo:@{@"type":@"progress", @"percentage":@(progress)}];
    }
}

-(void)uploadDidErrorWithError:(NSError *)error {
    if (!error) {
        
    }
    else {
        
    }
}

-(void)taskDidComplete:(AWSTask *)task {
    NSString *eTag = task.aws_properties[@"ETag"];
    
    if (eTag == nil) {
        [self uploadDidErrorWithError:Nil];
    }
}

@end
