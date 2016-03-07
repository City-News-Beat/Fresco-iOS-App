//
//  FRSFileLoader.m
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSFileLoader.h"

@implementation FRSFileLoader
@synthesize delegate = _delegate;

-(NSInteger)numberOfAssets {
    return [allAssets count];
}

-(id)initWithDelegate:(id<FRSFileLoaderDelegate>)del {
    self = [super init];
    
    if (self) {
        _delegate = del;
        
        if (![self checkAuthorization]) { // only request auth if we don't have auth
            [self getAuthorization];
        }
        else {
            [self getAssets]; // we have auth, loading list of assets
        }
    }
    
    return self;
}

// deprecated, this would be a good design choice if we were working with larger representations of assets, but PHAsset is negligible in memory
-(void)fetchAssetsWithinIndexRange:(NSRange)range callback:(MediaCallback)callback {
    currentRange = range;
    
    if (![self checkAuthorization]) {
        [self getAuthorization];
    }
    
    // now we finally get to indexes!!!!
    if (range.location + range.length >= [allAssets count]) {
        range.length = [allAssets count] - range.length - 1; // reached end of media
    }
    
    NSArray *toReturn = [allAssets objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    callback(toReturn, Nil);
}

-(PHAsset *)assetAtIndex:(NSInteger)index {
    if (index >= [allAssets count]) {
        return Nil;
    }
    
    return [allAssets objectAtIndex:index];
}

// load a list of all photos / videos from the last 24 hours
-(void)getAssets {
    
    if (!currentCollection) {
        [self getAlbumCollection];
    }

    if (!allAssets) { // discount doublecheck
        allAssets = [[NSMutableArray alloc] init];
    }

    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    // have most recently created assets at this top of list
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    // only load assets w/ creation date within the last 24 hours (86400 seconds)
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval:-86400];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat: @"creationDate >= %@ && creationDate <= %@ ", yesterday, today];
    options.predicate = dayPredicate;
    
    
    for (PHAssetCollection *collection in currentCollection) {
        
        // fetch assets based on the sort and date restrictions we set up
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        // add each asset to our file list
        for (PHAsset *asset in assets) {
            [allAssets addObject:asset];
        }
    }
    
    // delegate called to notify that we are authorized (only used first time user opens app, and gets the "Please allow access to photos" prompt
    if (_delegate) {
        [_delegate filesLoaded];
    }
}

// create collection from photo library
-(void)getAlbumCollection {
    currentCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:Nil];
}

// request authorization, take appropriate actions
-(void)getAuthorization {
    
    if ([allAssets count] > 0)
        return;
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self getAssets];
                break;
            case PHAuthorizationStatusRestricted:
                [self getAssets];
                break;
            case PHAuthorizationStatusDenied:
                if (_delegate) { // non-optional not checking for conformity
                    [_delegate applicationNotAuthorized]; // can't re-ask, need to go into settings
                }
                break;
            default:
                break;
        }
    }];
}

// just checks if we're already authorized
-(BOOL)checkAuthorization {
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

    return authorized;
}

// used by image cell to load preview image (pretty quick & async)
-(void)getDataFromAsset:(PHAsset *)phAsset callback:(DataCallback)callback {
    if (!assetLoader) {
        assetLoader = [[PHCachingImageManager alloc] init];
    }
    
    [assetLoader requestImageDataForAsset:phAsset options:Nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSError *error;
        float screenSize = [[UIScreen mainScreen] bounds].size.width/3.0;
        
        [[PHImageManager defaultManager]
            requestImageForAsset:phAsset
            targetSize:CGSizeMake(screenSize, screenSize)
            contentMode:PHImageContentModeAspectFill
            options:nil
            resultHandler:^(UIImage *result, NSDictionary *info) {
                
                if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                    
                    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:Nil resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        callback(result, avAsset, phAsset.mediaType, error);
                    }];
                    
                    return; // don't want 2 callbacks
                }
                
                callback(result, Nil, phAsset.mediaType, error);
            }];
            
        }];
}

// only overrode so that we'd immediately load assets, and, by design, request authorization upon open
-(id)init {
    self = [super init];
    
    if (self) {
        [self getAssets];
    }
    
    return self;
}

@end
