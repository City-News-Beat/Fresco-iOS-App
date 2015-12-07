//
//  FRSGalleryAssetsManager.m
//  Fresco
//
//  Created by Daniel Sun on 11/9/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSGalleryAssetsManager.h"
#import "FRSAppConstants.h"


@interface FRSGalleryAssetsManager() <PHPhotoLibraryChangeObserver>

@end

@implementation FRSGalleryAssetsManager


#pragma mark - static methods

+ (FRSGalleryAssetsManager *)sharedManager
{
    static FRSGalleryAssetsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FRSGalleryAssetsManager alloc] initPrivate];
        
    });
    return manager;
}

-(instancetype)initPrivate{
    self = [super init];
    if (self){
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
    }
    return self;
}

#pragma mark - fetching

- (void)fetchGalleryAssetsInBackgroundWithCompletion:(void (^)())completion{
    //Photos fetch
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
#if TARGET_IPHONE_SIMULATOR
        
#else

    //Set maximumum 1 day of age
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    components.day -= 7; //one week
    NSDate *lastWeek  = [calendar dateFromComponents:components];
    options.predicate = [NSPredicate predicateWithFormat:@"(creationDate >= %@)", lastWeek];
#endif
    
    PHFetchResult *results = [PHAsset fetchAssetsWithOptions:options];
    NSMutableArray *filteredAssets = [NSMutableArray new];
    
    [results enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        //Check if there is a location, and if the video is less than the MAX_VIDEO_LENGTH
        if (asset.location != nil && asset.duration <= MAX_VIDEO_LENGTH) {
            [filteredAssets addObject:asset];
            }
        }];
        
        PHAssetCollection *assetCollectionWithLocation = [PHAssetCollection transientAssetCollectionWithAssets:filteredAssets title:@"Assets with location data"];
        
        self.fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollectionWithLocation options:nil];
        
        if (completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });

        }
    });
}

#pragma mark - PHPhotoLibraryChangeObserver delegate method

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResult];
        if (collectionChanges) {
            
            // get the new fetch result
            self.fetchResult = [collectionChanges fetchResultAfterChanges];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GALLERY_ASSET_CHANGE object:nil userInfo:@{@"changeObject" : changeInstance}];
        }
    });
}



@end
