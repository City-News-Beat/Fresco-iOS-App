

//
//  FRSFileLoader.m
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSFileLoader.h"

@implementation FRSFileLoader

// only overrode so that we'd immediately load assets, and, by design, request authorization upon open
- (id)init {
    self = [super init];

    if (self) {
        [self getAssets];
    }

    return self;
}

- (id)initWithDelegate:(id<FRSFileLoaderDelegate>)del {
    self = [super init];

    if (self) {
        self.delegate = del;

        if (![self checkAuthorization]) { // only request auth if we don't have auth
            [self getAuthorization];
        } else {
            [self getAssets]; // we have auth, loading list of assets
        }
    }

    return self;
}

- (void)fetchAssetsForCollection:(PHAssetCollection *)collection {
    currentCollection = collection;
    [assetsForCurrentCollection removeAllObjects];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    // have most recently created assets at this top of list
    options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];

    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:currentCollection options:options];
    
    // add each asset to our file list
    for (PHAsset *asset in assets) {
        [assetsForCurrentCollection addObject:asset];
    }

}

- (void)fetchAssetsWithinIndexRange:(NSRange)range callback:(MediaCallback)callback {
    currentRange = range;

    if (![self checkAuthorization]) {
        [self getAuthorization];
    }

    if (range.location + range.length >= [assetsForCurrentCollection count]) {
        range.length = [assetsForCurrentCollection count] - range.length - 1; // reached end of media
    }

    NSArray *toReturn = [assetsForCurrentCollection objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    callback(toReturn, Nil);
}

- (PHAsset *)assetAtIndex:(NSInteger)index {
    if (index >= [assetsForCurrentCollection count]) {
        return Nil;
    }

    return [assetsForCurrentCollection objectAtIndex:index];
}

- (NSInteger)numberOfAssets {
    return [assetsForCurrentCollection count];
}

- (NSInteger)numberOfCollections {
    if (!currentCollections) {
        return 0;
    }
    return [currentCollections count];
}

// load a list of all photos / videos from the last 7 days
- (void)getAssets {
    if (!currentCollections) {
        [self getAlbumCollection];
    }

    if (!assetsForCurrentCollection) { // discount doublecheck
        assetsForCurrentCollection = [[NSMutableArray alloc] init];
    }

    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    // have most recently created assets at this top of list
    options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
    
    /* We don't want to limit file age to seven days anymore.
    #if TARGET_OS_SIMULATOR
        //Simulator
    #else
        //Device
        // only load assets w/ creation date within the defined maximum age
        NSDate *date = [[NSDate date] dateByAddingTimeInterval:-maxFileAge];
        NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"creationDate >= %@", date];
        options.predicate = dayPredicate;
    #endif
     */
    
    if(currentCollections.count == 0) return;
    
//    PHAssetCollection *firstCollection = currentCollections[0];
//    
//    // fetch assets based on the sort and date restrictions we set up
//    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:firstCollection options:options];
//    
//    // add each asset to our file list
//    for (PHAsset *asset in assets) {
//        [assetsForCurrentCollection addObject:asset];
//    }

    // delegate called to notify that we are authorized (only used first time user opens app, and gets the "Please allow access to photos" prompt
    if ([self.delegate respondsToSelector:@selector(filesLoaded)]) {
        [self.delegate filesLoaded];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionsLoaded)]) {
        [self.delegate collectionsLoaded];
    }

}

- (PHFetchResult<PHAssetCollection *> *)collections {
    return currentCollections;
}

// create collection from photo library
- (void)getAlbumCollection {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    // alphabetical order of the folders.
    options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES] ];

    currentCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:options];

    [currentCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"currentCollections [(PHAssetCollection *)obj localizedTitle]::: %@", [(PHAssetCollection *)obj localizedTitle]);
    }];
    
}

// request authorization, take appropriate actions
- (void)getAuthorization {
    if ([assetsForCurrentCollection count] > 0)
        return;

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
      switch (status) {
      case PHAuthorizationStatusAuthorized:
          [self getAssets];
          if (!wasPreviouslyAuthorized) {
              [FRSTracker track:photosEnabled];
          }
          break;
      case PHAuthorizationStatusRestricted:
          [self getAssets];
          break;
      case PHAuthorizationStatusDenied:
          if (self.delegate) { // non-optional not checking for conformity
              [self.delegate applicationNotAuthorized]; // can't re-ask, need to go into settings
          }

          if (wasPreviouslyAuthorized) {
              [FRSTracker track:photosDisabled];
          }
          break;
      default:
          break;
      }
    }];
}

// just checks if we're already authorized
- (BOOL)checkAuthorization {
    __block BOOL authorized = FALSE;

    switch ([PHPhotoLibrary authorizationStatus]) {
    case PHAuthorizationStatusAuthorized:
        authorized = TRUE;
        break;
    case PHAuthorizationStatusRestricted:
        authorized = TRUE;
        break;
    case PHAuthorizationStatusDenied:
        authorized = FALSE; // not necessary (default) but consistent
        break;
    default:
        break;
    }

    wasPreviouslyAuthorized = authorized;

    return authorized;
}

// used by image cell to load preview image (pretty quick & async)
- (void)getDataFromAsset:(PHAsset *)phAsset callback:(DataCallback)callback {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.version = PHImageRequestOptionsVersionOriginal;
    NSError *error;
    [[PHImageManager defaultManager] requestImageDataForAsset:phAsset
                                                      options:options
                                                resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, UIImageOrientation orientation, NSDictionary *_Nullable info) {

                                                  if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                                                      [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset
                                                                                                      options:Nil
                                                                                                resultHandler:^(AVAsset *_Nullable avAsset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {
                                                                                                  callback([UIImage imageWithData:imageData], avAsset, phAsset.mediaType, error);
                                                                                                }];

                                                      return;
                                                  }

                                                  callback([UIImage imageWithData:imageData], Nil, phAsset.mediaType, error);
                                                }];
}

#pragma mark - Fetch assets on the fly

// multiple folder collections
//- (NSInteger)numberOfAssetsInCollection:(PHAssetCollection *)assetCollection {
//    
//}
//
//- (void)fetchAssetsWithinIndexRange:(NSRange)range inCollection:(PHAssetCollection *)assetCollection callback:(MediaCallback)callback {
//    
//}
//
//- (void)getDataFromAsset:(PHAsset *)asset inCollection:(PHAssetCollection *)assetCollection callback:(DataCallback)callback {
//    
//}
//
//- (PHAsset *)assetAtIndex:(NSInteger)index inCollection:(PHAssetCollection *)assetCollection {
//    
//}


@end

