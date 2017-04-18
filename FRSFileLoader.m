

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

- (void)fetchAssetsWithinIndexRange:(NSRange)range callback:(MediaCallback)callback {
    currentRange = range;

    if (![self checkAuthorization]) {
        [self getAuthorization];
    }

    if (range.location + range.length >= [allAssets count]) {
        range.length = [allAssets count] - range.length - 1; // reached end of media
    }

    NSArray *toReturn = [allAssets objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    callback(toReturn, Nil);
}

- (PHAsset *)assetAtIndex:(NSInteger)index {
    if (index >= [allAssets count]) {
        return Nil;
    }

    return [allAssets objectAtIndex:index];
}

- (NSInteger)numberOfAssets {
    return [allAssets count];
}

// load a list of all photos / videos from the last 7 days
- (void)getAssets {
    if (!currentCollection) {
        [self getAlbumCollection];
    }

    if (!allAssets) { // discount doublecheck
        allAssets = [[NSMutableArray alloc] init];
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
     

    for (PHAssetCollection *collection in currentCollection) {
        // fetch assets based on the sort and date restrictions we set up
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];

        // add each asset to our file list
        for (PHAsset *asset in assets) {
            //if (asset.location) {
                [allAssets addObject:asset];
            //}
        }
    }

    // delegate called to notify that we are authorized (only used first time user opens app, and gets the "Please allow access to photos" prompt
    if (self.delegate) {
        [self.delegate filesLoaded];
    }
}

// create collection from photo library
- (void)getAlbumCollection {
    currentCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:Nil];
}

// request authorization, take appropriate actions
- (void)getAuthorization {
    if ([allAssets count] > 0)
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

@end

