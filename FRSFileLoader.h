//
//  FRSFileLoader.h
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

/*
    Class to manage pulling assets from the users library & managing permissions. Also responsible for generation of asset thumbnails.
*/
@protocol FRSFileLoaderDelegate <NSObject>
- (void)applicationNotAuthorized;
- (void)filesLoaded;
- (void)collectionsLoaded;
@end

typedef void (^AuthCallback)(BOOL authorized);
typedef void (^MediaCallback)(NSArray *media, NSError *error);
typedef void (^DataCallback)(UIImage *image, AVAsset *video, PHAssetMediaType mediaType, NSError *error);

@interface FRSFileLoader : NSObject {
    PHFetchResult<PHAssetCollection *> *currentCollections;
    MediaCallback returnCallback;
    NSRange currentRange;
    NSMutableArray *assetsForCurrentCollection;
    PHAssetCollection *currentCollection;

    BOOL wasPreviouslyAuthorized;
}

@property (nonatomic, weak) id<FRSFileLoaderDelegate> delegate;

- (id)initWithDelegate:(id<FRSFileLoaderDelegate>)del;

- (NSInteger)numberOfAssets;
- (void)fetchAssetsForCollection:(PHAssetCollection *)collection;
- (void)fetchAssetsWithinIndexRange:(NSRange)range callback:(MediaCallback)callback;
- (void)getDataFromAsset:(PHAsset *)asset callback:(DataCallback)callback;
- (PHAsset *)assetAtIndex:(NSInteger)index;

- (PHFetchResult<PHAssetCollection *> *)collections;
- (NSInteger)numberOfCollections;

// multiple folder collections
- (NSInteger)numberOfAssetsInCollection:(PHAssetCollection *)assetCollection;
- (void)fetchAssetsWithinIndexRange:(NSRange)range inCollection:(PHAssetCollection *)assetCollection callback:(MediaCallback)callback;
- (void)getDataFromAsset:(PHAsset *)asset inCollection:(PHAssetCollection *)assetCollection callback:(DataCallback)callback;
- (PHAsset *)assetAtIndex:(NSInteger)index inCollection:(PHAssetCollection *)assetCollection;

@end
