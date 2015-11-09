//
//  FRSGalleryAssetsManager.h
//  Fresco
//
//  Created by Daniel Sun on 11/9/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

@interface FRSGalleryAssetsManager : NSObject

/**
 *  Result of fetching assets that are less than a day old
 */

@property (strong, nonatomic) PHFetchResult *fetchResult;

/**
 *  Shared accessor for manager
 *
 *  @return Returns singleton instance of FRSGalleryAssetsManager
 */

+ (FRSGalleryAssetsManager *)sharedManager;

#pragma mark - Fetching

/**
 *  Fetches gallery assets that are less than a day old
 */

-(void)fetchGalleryAssets;



@end
