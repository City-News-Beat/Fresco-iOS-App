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
- (void)setUploadsCountToComplete:(int)uploadsCount;

@property (nonatomic, strong) NSMutableArray *currentUploads;
@property (nonatomic, assign) int completedUploads;
@property (nonatomic, strong) NSMutableArray *uploadMeta;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableDictionary *managedObjects;
@property (nonatomic, strong) NSString *currentGalleryID;
@property (nonatomic, strong) NSMutableDictionary *transcodingProgressDictionary;

@end
