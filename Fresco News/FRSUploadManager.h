//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Philip Bernstein on 10/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAVAssetExportSession.h"
#import "FRSAPIClient.h"
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
    float uploadSpeed;
    int numberOfVideos;
    SDAVAssetExportSession *exporter;
}

@property (nonatomic, strong) NSMutableArray *currentUploads;
@property (nonatomic, assign) int completedUploads;
@property (nonatomic, strong) NSMutableArray *uploadMeta;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableDictionary *managedObjects;
@property (nonatomic, strong) NSString *currentGalleryID;
@property (nonatomic, strong) NSMutableDictionary *transcodingProgressDictionary;

+ (id)sharedInstance;



/**
 Starts uploading posts

 @param posts Array of posts from API to upload
 @param assets Upload of matching PHAssets to upload
 */
- (void)uploadPosts:(NSArray *)posts withAssets:(NSArray *)assets;

    
/**
 Checks for existence of cached and uploads and reseums uploads
 */
- (void)checkCachedUploads;


/**
 Clears cached uploads from the system
 */
- (void)clearCachedUploads;


/**
 Adds asset to upload queue
 */
- (void)addAsset:(PHAsset *)asset withToken:(NSString *)token withPostID:(NSString *)postID;


- (NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback;


@end
