//
//  FRSAssetsPickerController.h
//  Fresco
//
//  Created by Elmir Kouliev and Apple on 10/7/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
@import UIKit;
@import Photos;

@interface AssetsPickerController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/**
 *  The selected assets.
 *
 *  It contains selected `PHAsset` objects. The order of the objects is the selection order.
 *
 *  You can use this property to select assets initially when presenting the picker.
 */

@property (nonatomic, strong) NSMutableArray *selectedAssets;

@property (strong) PHFetchResult *assetsFetchResults;

@property (strong) PHAssetCollection *assetCollection;

@end
