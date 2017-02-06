//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 10/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAVAssetExportSession.h"
#import <Photos/Photos.h>

@interface FRSUploadManager : NSObject <SDAVAssetExportSessionDelegate> {
    int currentIndex;
    unsigned long long totalFileSize;
    unsigned long long totalVideoFilesSize;
    unsigned long long totalImageFilesSize;
    unsigned long long uploadedFileSize;
    float lastProgress;
    int toComplete;
    int completed;
    BOOL isFromFresh;
    float uploadSpeed;
    int numberOfVideos;
    SDAVAssetExportSession *exporter;
}

+ (id)sharedInstance;
- (void)checkCachedUploads;
- (void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID;
- (NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback;

@property (nonatomic, retain) NSMutableArray *currentUploads;
@property (nonatomic, assign) int completedUploads;
@property (nonatomic, assign) int uploadsToComplete;
@property (nonatomic, retain) NSMutableArray *uploadMeta;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableDictionary *managedObjects;
@property (nonatomic, retain) NSString *currentGalleryID;
@property (nonatomic, retain) NSMutableDictionary *transcodingProgressDictionary;

@end
