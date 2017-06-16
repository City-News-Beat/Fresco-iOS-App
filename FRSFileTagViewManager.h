//
//  FRSFileTagViewManager.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseViewController.h"
#import "FRSCameraConstants.h"
#import <Photos/Photos.h>

@protocol FRSFileTagViewManagerDelegate <NSObject>

- (void)removeSelection;

@end

@interface FRSFileTagViewManager : NSObject

@property(assign, nonatomic) BOOL tagUpdated;
@property(weak, nonatomic) id<FRSFileTagViewManagerDelegate> delegate;

+ (FRSFileTagViewManager *)sharedInstance;

- (void)showTagViewForAsset:(PHAsset *)asset;
- (NSMutableArray *)availableTags;
- (FRSPackageProgressLevel)packageProgressLevel;

- (BOOL)isInterviewTagged;
- (BOOL)isWideShotTagged;
- (BOOL)isSteadyPanTagged;

- (void)clearAllCachedInfo;
@end
