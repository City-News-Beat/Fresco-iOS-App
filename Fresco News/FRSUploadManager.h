//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 7/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "FRSMultipartTask.h"
#import "FRSUploadTask.h"

static int const maxConcurrent = 5;

@interface FRSUploadManager : NSObject
{
    __weak id weakSelf;
    unsigned long long totalBytesSent;
    BOOL invalidated;
    int toComplete;
    int isComplete;
    BOOL isStarted;
    BOOL isRetry;
}
-(instancetype)initWithGallery:(NSDictionary *)gallery assets:(NSArray *)assets;
@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic, retain) NSMutableArray *currentTasks;
@property (nonatomic, retain) NSMutableArray *etags;
@property (nonatomic, retain) NSDictionary *gallery;
@property (nonatomic, retain) NSArray *assets;
@property (nonatomic, retain) NSArray *posts;
@property unsigned long long contentSize;
-(void)addTaskForImageAsset:(PHAsset *)asset url:(NSURL *)url post:(NSDictionary *)post;
-(void)addMultipartTaskForAsset:(PHAsset *)asset urls:(NSArray *)urls post:(NSDictionary *)post;
-(void)start;
-(void)pause;
-(void)resume;
@end
