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
    
    // save meta-data & callbacks, prepare to be called upon to start
    self.assetURL = asset;
    self.destinationURL = destination;
    self.progressBlock = progress;
    self.completionBlock = completion;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fresconews.upload.background"];
    sessionConfiguration.sessionSendsLaunchEvents = TRUE; // trigger info on completion
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]]; // think queue might be able to bet set to nil but test this for now
}

-(void)stop {
    [_uploadTask suspend];
}

-(void)start {
    // our turn in the queue, check if we've already started first
    if (_uploadTask || _hasStarted) {
        return; // FRSUploadTask are one off, no re-use
    }
    
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:self.destinationURL];
    [uploadRequest setHTTPMethod:@"PUT"];
    [self signRequest:uploadRequest];
    
    _uploadTask = [self.session uploadTaskWithRequest:uploadRequest fromFile:self.assetURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            if (self.delegate) {
                [self.delegate uploadDidFail:self withError:error response:data];
            }
        }
        else {
            if (self.delegate) {
                [self.delegate uploadDidSucceed:self withResponse:data];
            }
        }
        
        if (self.completionBlock) {
            self.completionBlock(self, data, error, (error == Nil)); // reference to task, response data, whether or not error present
        }
        
    }];
    
    _hasStarted = TRUE;
    [_uploadTask resume]; // starts initial request
}

-(void)pause {
    [_uploadTask suspend];
}

-(void)resume {
    [_uploadTask resume];
}

-(void)signRequest:(NSMutableURLRequest *)request {
    NSString *authorizationString = [self authenticationToken];
    [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
}

- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

    // manage properties
    _totalBytes = totalBytesExpectedToSend;
    _bytesUploaded += bytesSent;
    
    
    // update delegate ( or block )
    // typedef void (^TransferProgressBlock)(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);

    if (self.progressBlock) {
        self.progressBlock(task, bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }
    
    if (self.delegate) {
        [self.delegate uploadDidProgress:self bytesSent:bytesSent totalBytes:totalBytesExpectedToSend];
    }
}

-(NSString *)authenticationToken {

    NSArray *allAccounts = [SSKeychain accountsForService:serviceName];
    
    if ([allAccounts count] == 0) {
        return [NSString stringWithFormat:@"Basic: %@", clientAuthorization]; // client as default
    }
    
    NSDictionary *credentialsDictionary = [allAccounts firstObject];
    NSString *accountName = credentialsDictionary[kSSKeychainAccountKey];
    
    return [NSString stringWithFormat:@"Bearer: %@", [SSKeychain passwordForService:serviceName account:accountName]];
}

@end
