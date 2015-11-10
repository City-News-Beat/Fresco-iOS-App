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
    checkMark.image = [UIImage imageNamed:@"picker-checkmark"];
    [self.selectedView addSubview:checkMark];
    
    [self addSubview:self.selectedView];
    [self addSubview:photoImageView];

}

-(void)configureForVideoAssetWithDuration:(NSTimeInterval)duration{
    UILabel *lengthLabel = [[UILabel alloc] init];
    lengthLabel.text = [self stringWithDuration:duration];
    lengthLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:11];
    lengthLabel.textColor = [UIColor whiteColor];
    [lengthLabel sizeToFit];
    lengthLabel.frame = CGRectMake(self.frame.size.width - lengthLabel.frame.size.width - 4, self.frame.size.width - lengthLabel.frame.size.height - 4, lengthLabel.frame.size.width, lengthLabel.frame.size.height);
    [self addSubview:lengthLabel];
    
    UIImageView *videoIconIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    videoIconIV.center = lengthLabel.center;
    videoIconIV.frame = CGRectMake(4, videoIconIV.frame.origin.y, 14, 14);
    videoIconIV.contentMode = UIViewContentModeScaleAspectFit;
    videoIconIV.image = [UIImage imageNamed:@"video-thumb"];
    [self addSubview:videoIconIV];
}

-(NSString *)stringWithDuration:(NSTimeInterval)duration{
    NSInteger minutes = duration / 60;
    NSInteger seconds = (NSInteger)duration % 60;
    
    NSString *secondsString = seconds > 9 ? [NSString stringWithFormat:@"%lu", seconds] : [NSString stringWithFormat:@"0%lu",seconds];
    
    return [NSString stringWithFormat:@"%lu:%@", minutes, secondsString];
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
