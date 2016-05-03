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
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fresconews.upload.background"];
    
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

-(void)stop {
    [_uploadTask suspend];
}

-(void)start {
    
    NSMutableURLRequest *uploadRequest;
    [self signRequest:uploadRequest];
    
    _uploadTask = [self.session uploadTaskWithRequest:uploadRequest fromFile:self.assetURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
    }];
    
    [_uploadTask resume]; // starts initial request
}

-(void)pause {
    [_uploadTask suspend];
}

-(void)resume {
    [_uploadTask resume];
}

-(void)signRequest:(NSMutableURLRequest *)request {
    
}

- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

}

-(NSString *)authenticationToken {
    
    NSArray *allAccounts = [SSKeychain accountsForService:serviceName];
    
    if ([allAccounts count] == 0) {
        return Nil;
    }
    
    NSDictionary *credentialsDictionary = [allAccounts firstObject];
    NSString *accountName = credentialsDictionary[kSSKeychainAccountKey];
    
    return [SSKeychain passwordForService:serviceName account:accountName];
}

@end
