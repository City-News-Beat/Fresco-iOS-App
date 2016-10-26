//
//  FRSUploadTask.m
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadTask.h"
#import "FRSTracker.h"
#import "FRSUpload+CoreDataProperties.h"
#import "FRSAppDelegate.h"

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
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.sessionSendsLaunchEvents = TRUE; // trigger info on completion
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]]; // think queue might be able to bet set to nil but test this for now
}


-(void)stop {
    [_uploadTask suspend];
}

-(void)complete {
    FRSUpload *upload = (FRSUpload *)self.managedObject;
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.managedObjectContext performBlock:^{
        upload.completed = @(TRUE);
        [delegate saveContext];
    }];
}

-(void)start {
    // our turn in the queue, check if we've already started first
    if (_uploadTask || _hasStarted) {
        return; // FRSUploadTask are one off, no re-use
    }
    
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:self.destinationURL];
    [uploadRequest setHTTPMethod:@"PUT"];
    
    if (self.requestData) {
        
        NSLog(@"UPLOADING FROM DATA");
        
        _uploadTask = [self.session uploadTaskWithRequest:uploadRequest fromData:self.requestData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            self.requestData = Nil;
            
            if (error) {
                if (self.delegate) {
                    [self.delegate uploadDidFail:self withError:error response:data];
                }
                
                [FRSTracker track:@"Upload Error" parameters:@{@"error_message":error.localizedDescription}];
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
    return @"";
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
    NSLog(@"ETAGS: %@", data);
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


- (void)URLSession:(NSURLSession *)urlSession task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

    // manage properties
    _totalBytes = totalBytesExpectedToSend;
    _bytesUploaded += bytesSent;
    
    counter++;
    counterBuffer+= bytesSent;
    
    if (counter%3 != 0) {
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

@end
