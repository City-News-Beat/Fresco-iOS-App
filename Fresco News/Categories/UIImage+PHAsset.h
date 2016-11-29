//
//  UIImage+PHAsset.h
//  FrescoNews
//
//  Created by Joshua Lerner on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;
@import Photos;

@interface UIImage (PHAsset)

+ (UIImage *)imageFromAsset:(PHAsset *)asset;

+ (UIImage *)fullResImageFromAsset:(PHAsset *)asset;

@end
