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
    
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.selectedView.frame) - 30 , 8, 22, 22)];
    shadowView.layer.shadowColor = [UIColor frescoShadowColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 3);
    shadowView.layer.shadowRadius = 3.0;
    shadowView.layer.shadowOpacity = 1.0;
    shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowView.bounds cornerRadius:shadowView.frame.size.width/2].CGPath;
    [self.selectedView addSubview:shadowView];
    
    UIImageView *checkMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    checkMark.image = [UIImage imageNamed:@"picker-checkmark"];
    checkMark.layer.cornerRadius = checkMark.frame.size.width/2;
    checkMark.clipsToBounds = YES;
    [shadowView addSubview:checkMark];
    
    [self addSubview:self.selectedView];
    [self addSubview:photoImageView];

}

-(void)configureForVideoAssetWithDuration:(NSTimeInterval)duration{
    
    UILabel *lengthLabel = [[UILabel alloc] init];
    lengthLabel.text = [self stringWithDuration:duration];
    lengthLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:11];
    lengthLabel.textColor = [UIColor whiteColor];
    [lengthLabel sizeToFit];
    lengthLabel.frame = CGRectMake(self.frame.size.width - lengthLabel.frame.size.width - 6, self.frame.size.width - lengthLabel.frame.size.height - 5, lengthLabel.frame.size.width, lengthLabel.frame.size.height);
    lengthLabel.layer.shadowColor = [UIColor frescoShadowColor].CGColor;
    lengthLabel.layer.shadowOffset = CGSizeMake(0, 2);
    lengthLabel.layer.shadowRadius = 2.0;
    lengthLabel.layer.shadowOpacity = 1.0;
    
    [self addSubview:lengthLabel];
    
    UIImageView *videoIconIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    videoIconIV.center = lengthLabel.center;
    videoIconIV.frame = CGRectMake(8, videoIconIV.frame.origin.y, 12, 12);
    videoIconIV.contentMode = UIViewContentModeScaleAspectFit;
    videoIconIV.image = [UIImage imageNamed:@"video-thumb"];
    videoIconIV.layer.shadowColor = [UIColor frescoShadowColor].CGColor;
    videoIconIV.layer.shadowOffset = CGSizeMake(0, 2);
    videoIconIV.layer.shadowRadius = 2.0;
    videoIconIV.layer.shadowOpacity = 1.0;
    
    
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
