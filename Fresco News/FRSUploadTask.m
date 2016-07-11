//
//  FRSUploadTask.m
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadTask.h"

@implementation FRSUploadTask
@synthesize uploadTask = _uploadTask;
// sets up architecture, start initializes request
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion {
    
    // save meta-data & callbacks, prepare to be called upon to start
    self.assetURL = asset;
    self.destinationURL = destination;
    self.progressBlock = progress;
    self.completionBlock = completion;
    
   // NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fresconews.upload.background"];
   // sessionConfiguration.sessionSendsLaunchEvents = TRUE; // trigger info on completion
    _session = [NSURLSession sharedSession]; // think queue might be able to bet set to nil but test this for now
}

-(void)createUploadFromData:(NSData *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion {
    
    // save meta-data & callbacks, prepare to be called upon to start
    self.requestData = asset;
    self.destinationURL = destination;
    self.progressBlock = progress;
    self.completionBlock = completion;
    
    //NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fresconews.upload.background"];
   // sessionConfiguration.sessionSendsLaunchEvents = TRUE; // trigger info on completion
    _session = [NSURLSession sharedSession];
                //sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]]; // think queue might be able to bet set to nil but test this for now
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
    
    if (self.requestData) {
        
        NSLog(@"UPLOADING FROM DATA");
        
        _uploadTask = [self.session uploadTaskWithRequest:uploadRequest fromData:self.requestData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            self.requestData = Nil;
            
            if (error) {
                if (self.delegate) {
                    [self.delegate uploadDidFail:self withError:error response:data];
                }
            }
            else {
                [self checkEtag:data];
                if (self.delegate) {
                    [self.delegate uploadDidSucceed:self withResponse:data];
                }
            }
            
            if (self.completionBlock) {
                self.completionBlock(self, data, error, (error == Nil), response); // reference to task, response data, whether or not error present
            }
        }];
    }
    else {
        _uploadTask = [self.session uploadTaskWithRequest:uploadRequest fromFile:self.assetURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"UPLOADING FROM FILE URL");

            if (error) {
                if (self.delegate) {
                    [self.delegate uploadDidFail:self withError:error response:data];
                }
            }
            else {
                [self checkEtag:data];
                if (self.delegate) {
                    [self.delegate uploadDidSucceed:self withResponse:data];
                }
            }
            
            if (self.completionBlock) {
                self.completionBlock(self, data, error, (error == Nil), response); // reference to task, response data, whether or not error present
            }
            
        }];

    }
    
    _hasStarted = TRUE;
    [_uploadTask resume]; // starts initial request
}

-(NSString *)contentMD5 {
    return [AWFileHash md5HashOfFileAtPath:_assetURL.absoluteString];
}

-(id)serializedObjectFromResponse:(NSData *)response {
    
    NSError *jsonError;
    id responseObject = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        return @{@"err":@"Malformed JSON object", @"success":@(FALSE)};
    }
    
    return responseObject;
}

-(void)checkEtag:(NSData *)data {
    NSDictionary *responseDictionary = [self serializedObjectFromResponse:data];
    if (responseDictionary[@"eTag"]) {
        _eTag = responseDictionary[@"eTag"];
    }
    else {
        // spells out error in upload
    }
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

@end
