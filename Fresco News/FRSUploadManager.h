//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 10/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fresco.h"


@interface FRSUploadManager : NSObject
{
    int currentIndex;
    unsigned long long totalFileSize;
    unsigned long long uploadedFileSize;
    float lastProgress;
    int toComplete;
    int completed;
    BOOL isFromFresh;
    uint64_t uploadSpeed;
}

+(id)sharedUploader;
-(void)checkCachedUploads;
-(void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID;
@property (nonatomic, retain) NSMutableArray *currentUploads;
@property (nonatomic, assign) int completedUploads;
@property (nonatomic, assign) int uploadsToComplete;
@property (nonatomic, retain) NSMutableArray *uploadMeta;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableDictionary *managedObjects;
@end
