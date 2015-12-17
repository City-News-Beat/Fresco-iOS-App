//
//  GalleryPostCollectionViewCell.m
//  Fresco
//
//  Created by Daniel Sun on 12/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "GalleryPostCollectionViewCell.h"

#import "FRSPost.h"
#import "FRSImage.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@import Photos;

static NSString * const kCellIdentifier = @"PostCollectionViewCell";

@interface GalleryPostCollectionViewCell ()

@property (nonatomic, strong) UIImageView *transcodeImage;

@property (nonatomic, strong) UILabel *transcodeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewAspectRatio;

@end

@implementation GalleryPostCollectionViewCell

+ (NSString *)identifier
{
    return kCellIdentifier;
}

-(void)prepareForReuse{
    
    [[self imageView] setImage:nil];
    
    [[self imageView] cancelImageRequestOperation];
    
    [self.photoIndicatorView removeFromSuperview];
    
    [self.mutedImage removeFromSuperview];
    
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    __weak GalleryPostCollectionViewCell *weakSelf = self;
    
    if(weakSelf.post.isVideo) {
        
        //Set up for play/pause button
        weakSelf.playPause = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        weakSelf.playPause.center = CGPointMake(weakSelf.frame.size.width / 2 , weakSelf.center.y);
        weakSelf.playPause.contentMode = UIViewContentModeScaleAspectFit;
        weakSelf.playPause.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.20].CGColor;
        weakSelf.playPause.layer.shadowOffset = CGSizeMake(0, 1);
        weakSelf.playPause.layer.shadowOpacity = 1;
        weakSelf.playPause.layer.shadowRadius = 1.0;
        weakSelf.playPause.clipsToBounds = NO;
        weakSelf.playPause.alpha = 0;
        weakSelf.playPause.image = [UIImage imageNamed:@"pause"];

        
        
        //Add subviews and bring to the front so they don't get hidden
        [weakSelf addSubview:weakSelf.playPause];
        [weakSelf addSubview:weakSelf.mutedImage];
        [weakSelf bringSubviewToFront:weakSelf.playPause];
        
    }

    // local
    [[PHImageManager defaultManager]
     requestImageForAsset:post.image.asset
     targetSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
     contentMode:PHImageContentModeDefault
     options:nil
     resultHandler:^(UIImage * result, NSDictionary * info) {
         
         weakSelf.imageView.image  = result;
         
     }];
}

- (void)removeTranscodePlaceHolder{
    
    self.transcodeLabel.hidden = YES;
    self.transcodeImage.hidden = YES;
    
    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];
    
}

@end
