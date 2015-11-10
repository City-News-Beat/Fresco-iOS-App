//
//  FRSAssetGridCellCollectionViewCell.h
//  Fresco
//
//  Created by Elmir Kouliev on 10/7/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetGridViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, strong) UIView *selectedView;



/**
 *  Adds video thumbnail and duration in cell to distinguish between stills and video assets
 *
 *  @param duration the duration of the video asset
 */

-(void)configureForVideoAssetWithDuration:(NSTimeInterval)duration;




@end
