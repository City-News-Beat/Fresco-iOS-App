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
@synthesize completionBlock = _completionBlock, progressBlock = _progressBlock, openConnections = _openConnections;

// ovveride 
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion {
    
    
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _openConnections = [[NSMutableArray alloc] init];
    }
    
    return self;
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
    
    // set up actual NSURLSessionUploadTask
    NSURLRequest *chunkRequest = Nil;
    
    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:chunkRequest fromData:currentData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
    }];
    
    [task resume];
    [_openConnections addObject:task];
    
    
    currentData = Nil;
    // if we have open stream & below max connections
    if (openConnections < MAX_CONCURRENT && needsData) {
        [self next];
    }
    
}

- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
}

// pause current request just like inherited class, but takes action on streaming too
-(void)pause {
    for (NSURLSessionUploadTask *task in _openConnections) {
        [task suspend];
    }
}

// resume current request just like inherited class, but takes action on streaming too
-(void)resume {
    for (NSURLSessionUploadTask *task in _openConnections) {
        [task resume];
    }
}

@end
