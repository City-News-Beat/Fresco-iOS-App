//
//  FRSUploadTask.m
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadTask.h"
#import "Fresco.h"

@implementation FRSUploadTask
@synthesize uploadTask = _uploadTask;
// sets up architecture, start initializes request
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion {
    
    self.assetURL = asset;
    self.destinationURL = destination;
    self.progressBlock = progress;
    self.completionBlock = completion;
}

-(void)stop {
    
}

-(void)start {
    NSMutableURLRequest *uploadRequest;
    [self signRequest:uploadRequest];
    
    _uploadTask = [session uploadTaskWithRequest:uploadRequest fromFile:self.assetURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

-(void)signRequest:(NSMutableURLRequest *)request {
    
}

- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

}

@end
