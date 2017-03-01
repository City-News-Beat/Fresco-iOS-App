//
//  FRSUploadManager.h
//  Fresco
//
//  Created by Elmir Kouev on 2/23/17.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAVAssetExportSession.h"
#import <Photos/Photos.h>

typedef void (^FRSUploadSizeCompletionBlock)(NSInteger size, NSError *error);
typedef void (^FRSUploadPostAssetCompletionBlock)(NSDictionary* postUploadMeta, BOOL isVideo, NSInteger fileSize, NSError *error);


/**
 Class responsbile for handling photo/video upload for posts to Fresco. See the `startNewUploadWithPosts` for instructions on how to start
 an upload
 */
@interface FRSUploadManager : NSObject <SDAVAssetExportSessionDelegate> {
    unsigned long long totalFileSize;
    unsigned long long totalVideoFilesSize;
    unsigned long long totalImageFilesSize;
    unsigned long long uploadedFileSize;
    float lastProgress;
    int toComplete;
    int completed;
    float uploadSpeed;
    int numberOfVideos;
}

@property (nonatomic, strong) NSMutableArray *uploadMeta;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableDictionary *managedObjects;
@property (nonatomic, strong) NSMutableDictionary *transcodingProgressDictionary;


/**
 Used to access shared instance of this class as a singleton

 @return Shared instance object of this class
 */
+ (id)sharedInstance;

/**
 Stars a new upload with the passed posts. Posts must follow the specified format below.
 
 @param posts Array of dictionaries to represent the posts, containing - "post_id", "key" and "asset"
 */
- (void)startNewUploadWithPosts:(NSArray *)posts;
    
/**
 Method responsible for checking managed object context for existing uploads and proceeding
 to trigger a new upload cycle if there are hanging uploads. In the case of there being no persistent uploads, the local sandbox
 will be cleared of cached files.
 */
- (void)checkCachedUploads;

/**
 Clears cached uploads from the system
 */
- (void)clearCachedUploads;

/**
 Returns the API digest to be sent up for creating a post from an asset.

 @param asset PHAsset the digest is dervied from
 @param callback Completion handler that will return the digest
 */
- (void)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback;


@end
