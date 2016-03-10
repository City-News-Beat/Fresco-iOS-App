//
//  FRSMultipartTask.m
//  Fresco
//
//  Created by Philip Bernstein on 3/10/16.
//  Copyright © 2016 Fresco News. All rights reserved.
//

#import "FRSMultipartTask.h"

@implementation FRSMultipartTask

-(void)uploadDataFromURL:(NSURL *)url completion:(TransferCompletionBlock)completion progress:(TransferProgressBlock)progress {
    
    // reporting back to parent
    completionBlock = completion;
    progressBlock = progress;
    
    // set up initial stream
    needsData = TRUE;
    dataInputStream = [NSInputStream inputStreamWithURL:url];
    dataInputStream.delegate = self;
    [dataInputStream open];
    
    // now we start the fun
    NSLog(@"START CHUNKING");
    [self next];
}

-(void)next {
    // loop on background thread for obvious reasons
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
        if ([currentData length] >= 5 * MB) {
            [self startChunkUpload];
            triggeredUpload = TRUE;
            break;
        }
    }
    
    if (ranOnce && !triggeredUpload) { // last chunk, less than 5mb
        [self startChunkUpload];
        needsData = FALSE;
        [dataInputStream close];
        NSLog(@"END CHUNKING");
    }
}
-(void)startChunkUpload {
    NSLog(@"NEW CHUNK");
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
    
    // set up actual REST call
    
}

-(NSString *)uniqueTempPath {
    return [[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] stringByAppendingString:@".dat"];
}
@end
