//
//  FRSAssetGridCellCollectionViewCell.m
//  Fresco
//
//  Created by Elmir Kouliev on 10/7/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "AssetGridViewCell.h"

@implementation AssetGridViewCell

- (void)setThumbnailImage:(UIImage *)thumbnailImage{

    _thumbnailImage = thumbnailImage;
    
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor fieldBorderColor].CGColor;
    self.clipsToBounds = YES;
    
    UIImageView* photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    photoImageView.image = thumbnailImage;
    photoImageView.clipsToBounds = YES;
    photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.selectedView.backgroundColor = [UIColor assetOverlayColor];
    self.selectedView.hidden = NO;
    
    UIImageView *checkMark = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.selectedView.frame) - 30 , 8, 22, 22)];
    checkMark.image = [UIImage imageNamed:@"checkmark"];
    [self.selectedView addSubview:checkMark];
    
    [self addSubview:self.selectedView];
    [self addSubview:photoImageView];

}

#pragma mark - Accessors

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.selectedView.hidden = !selected;
        [self bringSubviewToFront:self.selectedView];
   
    });
    
}

@end
