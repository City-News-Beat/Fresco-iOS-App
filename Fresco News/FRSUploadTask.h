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

@property unsigned long bytesUploaded;
@property unsigned long totalBytes;

@property TransferCompletionBlock completionBlock;
@property TransferProgressBlock progressBlock;
@property BOOL hasStarted;
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;

-(void)start;
-(void)stop;

-(void)postUpdateNotification;
-(void)postCompletionNotification;


@end
