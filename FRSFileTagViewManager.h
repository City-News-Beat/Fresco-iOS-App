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

@property(strong, nonatomic) NSMutableArray *interviewTaggedAssetsArray;
@property(strong, nonatomic) NSMutableArray *wideShotTaggedAssetsArray;
@property(strong, nonatomic) NSMutableArray *steadyPanTaggedAssetsArray;


+ (FRSFileTagViewManager *)sharedInstance;

- (void)showTagViewForCaptureMode:(FRSCaptureMode)captureMode andTagViewMode:(FRSTagViewMode)tagViewMode;
- (void)showTagViewForAsset:(PHAsset *)asset;
- (NSMutableArray *)availableTags;
- (FRSPackageProgressLevel)packageProgressLevel;

@end
