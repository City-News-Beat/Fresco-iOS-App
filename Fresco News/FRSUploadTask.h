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
// mandatory, basic upload events
-(void)uploadWillStart:(id)upload;
-(void)uploadDidProgress:(id)upload bytesSent:(unsigned long)sent totalBytes:(unsigned long)total;
-(void)uploadDidSucceed:(id)upload withResponse:(NSData *)response;
-(void)uploadDidFail:(id)upload withError:(NSError *)error response:(NSData *)response;
@end

typedef void (^TransferProgressBlock)(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^TransferCompletionBlock)(id task, NSData *responseData, NSError *error, BOOL success);
typedef void (^TransferCancellationBlock)(id task, NSError *error, BOOL success);


@interface FRSUploadTask : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate> // allows granular feedback on upload
{
    
}

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, weak) id<FRSUploadDelegate> delegate;
@property (nonatomic, retain, readonly) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, retain, readonly) NSURLSession *session;
@property unsigned long bytesUploaded;
@property unsigned long totalBytes;
@property (nonatomic, retain) NSURL *assetURL;
@property (nonatomic, retain) NSURL *destinationURL;

@property TransferCompletionBlock completionBlock;
@property TransferProgressBlock progressBlock;
@property BOOL hasStarted;
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;

// were going to be internal but needed in all classes inheriting this structure
-(void)signRequest:(NSMutableURLRequest *)request;
-(NSString *)authenticationToken;

-(void)start;
-(void)stop;
-(void)pause;
-(void)resume;
@end
