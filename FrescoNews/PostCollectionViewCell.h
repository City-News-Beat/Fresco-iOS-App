//
//  PostCollectionViewCell.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSPost;

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) FRSPost *post;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImageView *playPause;

@property (nonatomic, strong) UIActivityIndicatorView *videoIndicatorView;

@property (nonatomic, assign) BOOL processingVideo;

+ (NSString *)identifier;

@end
