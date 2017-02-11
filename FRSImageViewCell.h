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

/*
    Simple cell w/ nib just so I could easily lay out everything needed
 */

@interface FRSImageViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIView *coverView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *checkBox;
@property (nonatomic, weak) PHAsset *currentAsset;
@property (nonatomic, strong) AVAsset *currentAVAsset;
@property (nonatomic, weak) FRSFileLoader *fileLoader;

- (void)selected:(BOOL)selected;
- (void)loadAsset:(PHAsset *)asset;

@end
