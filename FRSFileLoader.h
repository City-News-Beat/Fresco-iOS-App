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
@protocol FRSFileLoaderDelegate
-(void)applicationNotAuthorized;
-(void)filesLoaded;
@end

typedef void (^AuthCallback)(BOOL authorized);
typedef void (^MediaCallback)(NSArray *media, NSError *error);
typedef void (^DataCallback)(UIImage *image, AVAsset *video, PHAssetMediaType mediaType, NSError *error);

@interface FRSFileLoader : NSObject
{
    PHFetchResult *currentCollection;
    MediaCallback returnCallback;
    NSRange currentRange;
    NSMutableArray *allAssets;
    PHCachingImageManager *assetLoader;

}
-(id)initWithDelegate:(id<FRSFileLoaderDelegate>)del;
@property (nonatomic, weak) id<FRSFileLoaderDelegate> delegate;
-(NSInteger)numberOfAssets;
-(void)fetchAssetsWithinIndexRange:(NSRange)range callback:(MediaCallback)callback;
-(void)getDataFromAsset:(PHAsset *)asset callback:(DataCallback)callback;
-(PHAsset *)assetAtIndex:(NSInteger)index;
@end
