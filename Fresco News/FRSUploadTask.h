//
//  FRSUploadTask.h
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fresco.h"
#import <Photos/Photos.h>

#define session [NSURLSession sharedSession]
@protocol FRSUploadDelegate <NSObject>
@optional
-(void)uploadWillStart:(id)upload;
-(void)uploadDidProgress:(id)upload bytesSent:(unsigned long)sent totalBytes:(unsigned long)total;
-(void)uploadDidSucceed:(id)upload withResponse:(NSData *)response;
-(void)uploadDidFail:(id)upload withError:(NSError *)error response:(NSData *)response;
@end

@interface FRSUploadTask : NSObject
{
    
}

@property (nonatomic, retain, readonly) NSURLSessionUploadTask *uploadTask;
@property unsigned long bytesUploaded;
@property unsigned long totalBytes;
@property (nonatomic, retain) NSURL *assetURL;
@property (nonatomic, retain) NSURL *destinationURL;

@property TransferCompletionBlock completionBlock;
@property TransferProgressBlock progressBlock;
@property BOOL hasStarted;
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;


-(void)start;
-(void)stop;

@end
