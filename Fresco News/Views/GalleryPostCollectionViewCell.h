//
//  GalleryPostCollectionViewCell.h
//  Fresco
//
//  Created by Daniel Sun on 12/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSPost;

@interface GalleryPostCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) FRSPost *post;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *playPause;

@property (nonatomic, strong) UIImageView *mutedImage;

@property (nonatomic, strong) UIActivityIndicatorView *photoIndicatorView;

@property (nonatomic, assign) BOOL playingVideo;

+ (NSString *)identifier;

@end
