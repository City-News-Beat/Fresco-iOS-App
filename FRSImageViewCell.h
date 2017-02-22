//
//  FRSImageViewCell.h
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "FRSFileLoader.h"

static NSString *const imageCellIdentifier = @"image-picker-cell";

@interface FRSImageViewCell : UICollectionViewCell

@property (nonatomic, weak) FRSFileLoader *fileLoader;

- (void)selected:(BOOL)selected;
- (void)loadAsset:(PHAsset *)asset;

@end
