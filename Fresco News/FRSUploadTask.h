//
//  FRSUploadTask.h
//  Fresco
//
//  Created by Philip Bernstein on 4/25/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "AWFileHash.h"

@protocol FRSUploadDelegate <NSObject>
// mandatory, basic upload events
-(void)uploadWillStart:(id)upload;
-(void)uploadDidProgress:(id)upload bytesSent:(int64_t)sent totalBytes:(int64_t)total;
-(void)uploadDidSucceed:(id)upload withResponse:(NSData *)response;
-(void)uploadDidFail:(id)upload withError:(NSError *)error response:(NSData *)response;
@end

typedef void (^TransferProgressBlock)(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^TransferCompletionBlock)(id task, NSData *responseData, NSError *error, BOOL success, NSURLResponse *response);
typedef void (^TransferCancellationBlock)(id task, NSError *error, BOOL success);


@interface FRSUploadTask : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate> // allows granular feedback on upload
{
    
}

@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, weak) id<FRSUploadDelegate> delegate;
@property (nonatomic, weak) FRSPost *associatedPost;
@property (nonatomic, retain, readonly) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, retain, readonly) NSURLSession *session;
@property (nonatomic, retain, readonly) NSString *eTag;
@property (nonatomic, retain) NSData *requestData;
// file sizing & progress
@property int64_t bytesUploaded;
@property int64_t totalBytes;
@property int64_t fileSizeFromMetadata;

@property (nonatomic, retain) NSURL *assetURL;
@property (nonatomic, retain) NSURL *destinationURL;

@property (nonatomic, copy) TransferCompletionBlock completionBlock;
@property (nonatomic, copy) TransferProgressBlock progressBlock;
@property BOOL hasStarted;
-(void)createUploadFromSource:(NSURL *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;
-(void)createUploadFromData:(NSData *)asset destination:(NSURL *)destination progress:(TransferProgressBlock)progress completion:(TransferCompletionBlock)completion;

// were going to be internal but needed in all classes inheriting this structure
-(void)signRequest:(NSMutableURLRequest *)request;
-(NSString *)contentMD5; // md5 of entire file, streamed to reduce memory load

-(void)start;
-(void)stop;
-(void)pause;
-(void)resume;
@end
