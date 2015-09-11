//
//  PostCollectionViewCell.h
//  FrescoNews
//
//  Created by Fresco News on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSPost;

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) FRSPost *post;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImageView *playPause;

@property (nonatomic, strong) UIImageView *mutedImage;

@property (nonatomic, strong) UIActivityIndicatorView *photoIndicatorView;

@property (nonatomic, assign) BOOL playingVideo;


+ (NSString *)identifier;

@end
