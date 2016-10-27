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
}


-(void)addAsset:(PHAsset *)asset withToken:(NSString *)token {
    if (!asset || !token) {
        return;
    }
    
    NSString *revisedToken = [@"raw/" stringByAppendingString:token];

    if (asset.mediaType == PHAssetMediaTypeImage) {
        [asset requestContentEditingInputWithOptions:Nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            NSURL *imageURL = contentEditingInput.fullSizeImageURL;
            
            NSArray *uploadMeta = @[imageURL.absoluteString, revisedToken];
            
            BOOL restart = FALSE;
            
            if (self.uploadMeta.count == 0) {
                restart = TRUE;
            }
            
            [self.uploadMeta addObject:uploadMeta];
            if (restart) {
                [self restart];
            }
        }];
    }
    else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:Nil resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
            NSURL *videoURL = [(AVURLAsset *)avasset URL];
            
            // create temp location to move data (PHAsset can not be weakly linked to)
            NSString *file = [[videoURL.absoluteString componentsSeparatedByString:@"/"] lastObject];
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:Nil];
            
            // set up resource from PHAsset
            PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
            PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
            options.networkAccessAllowed = YES;
            
            // write data from PHAsset resource to temp location, send for upload
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:tempPath] options:options completionHandler:^(NSError * _Nullable error) {
                
                BOOL restart = FALSE;
                
                if (self.uploadMeta.count == 0) {
                    restart = TRUE;
                }
                
                NSArray *uploadMeta = @[tempPath, revisedToken];
                [self.uploadMeta addObject:uploadMeta];
                
                if (restart) {
                    [self restart];
                }
                
            }];
        }];
    }
}

-(void)restart {
    NSArray *request = [self.uploadMeta objectAtIndex:0];
    [self addUploadForPost:request[1] url:request[0] completion:^(id responseObject, NSError *error) {
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

-(void)addUploadForPost:(NSString *)postID url:(NSString *)body completion:(FRSAPIDefaultCompletionBlock)completion {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *upload = [AWSS3TransferManagerUploadRequest new];
    NSLog(@"%@", body);
    upload.body = [NSURL URLWithString:body];
    upload.key = postID;
    upload.bucket = awsBucket;
    upload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        float progress = (totalBytesSent * 1.0) / (totalBytesExpectedToSend * 1.0);
        NSLog(@"PROGRESS: %f", progress);
    };
    __weak typeof (self) weakSelf = self;
    
    [[transferManager upload:upload] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            NSLog(@"UPLOAD ERROR: %@", task.error);
            [weakSelf uploadDidErrorWithError:task.error];
        }
        
        if (task.result) {
            NSLog(@"UPLOAD COMPLETE");
            [self taskDidComplete:task];
            [self next];
        }
        
        return nil;
    }];
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
