//
//  FRSFileUploadManager.m
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFileUploadManager.h"

@implementation FRSFileUploadManager
@synthesize uploadQueue = _uploadQueue;

-(void)uploadPhoto:(NSData *)photoData toURL:(NSURL *)destinationURL {
    
}
-(void)uploadVideo:(NSURL *)videoURL toURL:(NSURL *)destinationURL {
    
}


+(instancetype)sharedUploader {
    static FRSFileUploadManager *uploader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        uploader = [[FRSFileUploadManager alloc] init];
    });
    
    return uploader;
}
@end
