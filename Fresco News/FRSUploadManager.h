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

typedef void (^FRSUploadSizeCompletionBlock)(NSInteger size, NSError *error);
typedef void (^FRSUploadPostAssetCompletionBlock)(NSDictionary* postUploadMeta, BOOL isVideo, NSInteger fileSize, NSError *error);


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

+ (id)sharedInstance;


/**
 Stars a new upload with the passed parameters
 
 @param posts Array of dictionaries to represent the posts, containing - "post_id", and "key"
 @param assets Array of PHAssets that correspond to indices of the passed posts array
 */
- (void)startNewUploadWithPosts:(NSArray *)posts withAssets:(NSArray *)assets;
    
/**
 Checks for existence of cached and uploads and reseums uploads
 */
- (void)checkCachedUploads;


/**
 Clears cached uploads from the system
 */
- (void)clearCachedUploads;



/**
 Returns API digest to be sent up for creating a post from an asset

 @param asset PHAsset the digest is dervied from
 @param callback Completion handler that will return the digest
 @return <#return value description#>
 */
- (void)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback;


@end
