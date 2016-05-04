//
//  FRSMultipartTask.m
//  Fresco
//
//  Created by Philip Bernstein on 3/10/16.
//  Copyright © 2016 Fresco News. All rights reserved.
//

#import "FRSMultipartTask.h"
#import "Fresco.h"

@implementation FRSMultipartTask
@synthesize completionBlock = _completionBlock, progressBlock = _progressBlock;

-(void)uploadDataFromURL:(NSURL *)url completion:(TransferCompletionBlock)completion progress:(TransferProgressBlock)progress {
    
    // reporting back to parent
    _completionBlock = completion;
    _progressBlock = progress;
    
    // set up initial stream
    needsData = TRUE;
    dataInputStream = [NSInputStream inputStreamWithURL:url];
    dataInputStream.delegate = self;
    [dataInputStream open];
    
    // start input from data stream
    [self next];
}


// ovveride 
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion {
    
}

-(void)next {
    // loop on background thread to not interrupt UI, but on HIGH priority to supercede any default thread needs
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!currentData) // don't want multiple running loops
            [self readDataInputStream];
    });
}

-(void)readDataInputStream {
    
    if (!currentData) {
        currentData = [[NSMutableData alloc] init];
    }
    
    uint8_t buffer[1024];
    NSInteger length;
    BOOL ranOnce = FALSE;
    BOOL triggeredUpload = FALSE;
    
    while ([dataInputStream hasBytesAvailable])
    {
        length = [dataInputStream read:buffer maxLength:1024];
        dataRead += length;
        ranOnce = TRUE;
        
        if (length > 0)
        {
            [currentData appendBytes:buffer length:length];
        }
        if ([currentData length] >= CHUNK_SIZE * MB) {
            [self startChunkUpload];
            triggeredUpload = TRUE;
            break;
        }
    }
    
    // last chunk, less than 5mb, streaming process ends here
    if (ranOnce && !triggeredUpload) {
        [self startChunkUpload];
        needsData = FALSE;
        [dataInputStream close];
    }
}

// moves to next chunk based on previously succeeded blocks, does not iterate if we are above max # concurrent requests
-(void)startChunkUpload {
    openConnections++;
    totalConnections++;
    
    // write to temp directory for upload to AWS (we can skip this if we don't use SDK, idk yet)
    __block NSString *currentPath = [self uniqueTempPath];
    [currentData writeToFile:currentPath atomically:YES];
    currentData = Nil;
    
    // if we have open stream & below max connections
    if (openConnections < MAX_CONCURRENT && needsData) {
        [self next];
    }
    
    // set up actual NSURLSessionUploadTask
    
}

// generates unique temp path to store chunks during upload (off of volotile memory), automatically cleared
-(NSString *)uniqueTempPath {
    return [[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] stringByAppendingString:@".dat"];
}

// pause current request just like inherited class, but takes action on streaming too
-(void)pause {
    [super pause];
}

// resume current request just like inherited class, but takes action on streaming too
-(void)resume {
    [super resume];
}

@end
