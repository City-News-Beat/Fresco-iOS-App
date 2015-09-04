//
//  UIImage+ALAsset.h
//  FrescoNews
//
//  Created by Joshua Lerner on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import Foundation;

@class ALAsset;

@interface UIImage (ALAsset)

+ (UIImage *)imageFromAsset:(ALAsset *)asset;

+ (UIImage *)fullResImageFromAsset:(ALAsset *)asset;

@end
