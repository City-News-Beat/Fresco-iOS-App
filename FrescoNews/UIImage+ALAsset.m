//
//  UIImage+ALAsset.m
//  FrescoNews
//
//  Created by Joshua Lerner on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "UIImage+ALAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation UIImage (ALAsset)

+ (UIImage *)imageFromAsset:(ALAsset *)asset
{
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    return [UIImage imageWithCGImage:representation.fullResolutionImage
                               scale:[representation scale]
                         orientation:(UIImageOrientation)[representation orientation]];
}

@end
