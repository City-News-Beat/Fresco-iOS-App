//
//  FRSMultipartTask.m
//  Fresco
//
//  Created by Philip Bernstein on 3/10/16.
//  Copyright © 2016 Fresco News. All rights reserved.
//

#import "FRSMultipartTask.h"
#import "NSData+NSHash.h" // md5 all requests

@implementation FRSMultipartTask
@synthesize completionBlock = _completionBlock, progressBlock = _progressBlock, openConnections = _openConnections, destinationURLS = _destinationURLS, session = _session;

-(void)createUploadFromSource:(NSURL *)asset destinations:(NSArray *)destinations progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion {
    
    // save meta-data & callbacks, prepare to be called upon to start
    self.assetURL = asset;
    self.destinationURLS = destinations;
    self.progressBlock = progress;
    self.completionBlock = completion;
    dataInputStream = [[NSInputStream alloc] initWithURL:self.assetURL];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fresconews.upload.background"];
    sessionConfiguration.sessionSendsLaunchEvents = TRUE; // trigger info on completion
    _session = [NSURLSession sharedSession];
    
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _openConnections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/*
    Integral part of upload process, this allows for the app to re-claim old/failed uploads, and continue uploading them in the background
 */
-(void)startFromChunk:(NSInteger)chunk {
    unsigned long long currentPoint = chunk * chunkSize * megabyteDefinition;
    
    if (self.fileSizeFromMetadata - currentPoint < chunkSize && self.fileSizeFromMetadata != currentPoint) {
        // final chunk (confirm tho)
    }
    else if (self.fileSizeFromMetadata == currentPoint) {
        // close on api end ** check this from core data not byte definition **
        
    }
    
    // continue from non-final chunk
}

-(void)next {
    // loop on background thread to not interrupt UI, but on HIGH priority to supercede any default thread needs
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!currentData) // don't want multiple running loops
            [self readDataInputStream];
    });
}

-(void)start {
    [self readDataInputStream];
}
-(void)readDataInputStream {
    
    if (!currentData) {
        needsData = TRUE;
        currentData = [[NSMutableData alloc] init];
        [dataInputStream open];
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
        if ([currentData length] >= chunkSize * megabyteDefinition) {
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
    NSLog(@"START CHUNK UPLOAD");
    openConnections++;
    totalConnections++;
    
    NSURL *urlToUploadTo = (totalConnections < self.destinationURLS.count)  ? self.destinationURLS[totalConnections-1] : Nil;
    
    if (!urlToUploadTo) {
        return; // error
    }
    
    // set up actual NSURLSessionUploadTask
    NSMutableURLRequest *chunkRequest = [NSMutableURLRequest requestWithURL:urlToUploadTo];
    [chunkRequest setHTTPMethod:@"PUT"];
    
    [self signRequest:chunkRequest];
    
    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:chunkRequest fromData:currentData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"UPLOAD FAILED");

            // put in provision for # of errors, and icing the task, and being able to resume it when asked to
            if (self.delegate) {
                [self.delegate uploadDidFail:self withError:error response:data];
            }
        }
        else {
            NSLog(@"UPLOAD SUCCEEDED %@", response);
            
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *eTag = headers[@"Etag"];
            
            if (!self.eTags) {
                self.eTags = [[NSMutableArray alloc] init];
            }
            
            [self.eTags addObject:eTag];
            
            if (self.delegate) {
                [self.delegate uploadDidSucceed:self withResponse:data];
                [_openConnections removeObject:task];
                if (openConnections < maxConcurrentUploads && needsData) {
                    [self next];
                }
                else if (!needsData) {
                    self.completionBlock(self, Nil, Nil, TRUE, Nil);
                }
            }
        }
        
    }];
    
    
    [task resume];
    [_openConnections addObject:task];
    
    
    currentData = Nil;
    // if we have open stream & below max connections
    if (openConnections < maxConcurrentUploads && needsData) {
        [self next];
    }
    
}

// have to override to take into account multiple chunks
- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    self.bytesUploaded += bytesSent;
    
    if (self.delegate) {
        [self.delegate uploadDidProgress:self bytesSent:self.bytesUploaded totalBytes:self.fileSizeFromMetadata];
    }
    
    if (self.progressBlock) {
        self.progressBlock(self, bytesSent, self.bytesUploaded, self.fileSizeFromMetadata);
    }
    
    NSLog(@"BYTES SENT");
}

// pause all open requests
-(void)pause {
    for (NSURLSessionUploadTask *task in _openConnections) {
        [task suspend];
    }
}

// resume all previously open requests
-(void)resume {
    for (NSURLSessionUploadTask *task in _openConnections) {
        [task resume];
    }
}

-(NSString *)contentMD5ForChunk:(NSData *)data {
    return [AWFileHash md5HashOfData:data];
}
@end
