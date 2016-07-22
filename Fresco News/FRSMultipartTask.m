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
    tags = [[NSMutableDictionary alloc] init];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.sessionSendsLaunchEvents = TRUE; // trigger info on completion
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
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
        if (currentData == Nil) {
            [self readDataInputStream];
        }
    });
}

-(void)start {
    [dataInputStream open];
    [self readDataInputStream];
}
-(void)readDataInputStream {
    
    if (!currentData) {
        needsData = TRUE;
        currentData = [[NSMutableData alloc] init];
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        uint8_t buffer[1024];
        NSInteger length;
        BOOL ranOnce = FALSE;
        BOOL triggeredUpload = FALSE;

        while ([dataInputStream hasBytesAvailable])
        {
            length = [dataInputStream read:buffer maxLength:1024];
            // dataRead += length;
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
            NSLog(@"LAST CHUNK");
        }

    });
}

// moves to next chunk based on previously succeeded blocks, does not iterate if we are above max # concurrent requests
-(void)startChunkUpload {
    NSLog(@"START CHUNK UPLOAD");
    NSURL *urlToUploadTo = _destinationURLS[totalConnections];
    openConnections++;
    totalConnections++;
    int connect = (int)totalConnections;
    if (!urlToUploadTo) {
        return; // error
    }
    
    // set up actual NSURLSessionUploadTask
    NSMutableURLRequest *chunkRequest = [NSMutableURLRequest requestWithURL:urlToUploadTo];
    [chunkRequest setHTTPMethod:@"PUT"];
    
    __block NSData *dataToUpload = [currentData copy];
    currentData = Nil;
    
    [self uploadChunk:chunkRequest data:dataToUpload index:connect];
}

-(void)uploadChunk:(NSURLRequest *)chunkRequest data:(NSData *)dataToUpload index:(int)connect {
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:chunkRequest fromData:dataToUpload completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        openConnections--;
        
        if (error) {
            totalErrors++;
            
            NSLog(@"CHUNK ERROR: %@", error);
            
            // put in provision for # of errors, and icing the task, and being able to resume it when asked to
            if (weakSelf.delegate && totalErrors > chunkMaxFailures) {
                [weakSelf.delegate uploadDidFail:self withError:error response:data];
            }
            
            self.completionBlock(self, Nil, Nil, FALSE, Nil);
            return;
        }
        else {
            
            totalErrors = 0;
            
            
            
            NSLog(@"CHUNK UPLOADED");
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *eTag = headers[@"Etag"];
            
            if (!weakSelf.eTags) {
                weakSelf.eTags = [[NSMutableArray alloc] init];
            }
            
            if (eTag) {
                [tags setObject:eTag forKey:@(connect-1)];
            }
            
            if (openConnections == 0 && needsData == FALSE) {
                NSLog(@"UPLOAD COMPLETE");
                
                for (int i = 0; i < self.destinationURLS.count; i++) {
                    NSString *eTag = tags[@(i)];
                    if (eTag) {
                        [weakSelf.eTags addObject:eTag];
                    }
                }
                if (weakSelf.completionBlock) {
                    NSLog(@"TAGS: %@", weakSelf.eTags);
                    
                    weakSelf.completionBlock(self, Nil, Nil, TRUE, Nil);
                }
            }
            
            
            if (weakSelf.delegate) {
                [weakSelf.delegate uploadDidSucceed:weakSelf withResponse:data];
            }
            
            if (openConnections < maxConcurrentUploads && needsData) {
                [weakSelf next];
            }
        }
        
    }];
    
    [task resume];
    
    currentData = Nil;
    // if we have open stream & below max connections
    if (openConnections < maxConcurrentUploads && needsData) {
        [self next];
    }
}

-(NSArray *)sortedTags {
    
    NSMutableArray *tag = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _eTags.count; i++) {
        [tag addObject:tags[@(i)]];
    }
    
    return tag;
}
// have to override to take into account multiple chunks
- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    counter++;
    counterBuffer+= bytesSent;
    
    if (counter%5 != 0) {
        return;
    }
    
    self.bytesUploaded += bytesSent;
    
    if (self.delegate) {
        [self.delegate uploadDidProgress:self bytesSent:self.bytesUploaded totalBytes:self.fileSizeFromMetadata];
    }
    
    if (self.progressBlock) {
        self.progressBlock(self, counterBuffer, self.bytesUploaded, self.fileSizeFromMetadata);
    }
    
    counterBuffer = 0;
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
