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
#import "FRSCheckBox.h"

/*
    Simple cell w/ nib just so I could easily lay out everything needed
 */

@interface FRSImageViewCell : UICollectionViewCell
{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *timeLabel;
    IBOutlet FRSCheckBox *checkBox;
}
-(void)loadAsset:(PHAsset *)asset;
@property (nonatomic, weak) PHAsset *currentAsset;
@property (nonatomic, strong) AVAsset *currentAVAsset;
@property (nonatomic, weak) FRSFileLoader *fileLoader;
-(void)selected:(BOOL)selected;
@end
