//
//  FRSGalleryMediaImageCollectionViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaImageCollectionViewCell.h"
#import "FRSPost.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSURL+Fresco.h"

@interface FRSGalleryMediaImageCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) FRSPost *post;

@end

@implementation FRSGalleryMediaImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.imageView.alpha = 0.0;
    
    self.post = nil;
}

-(void)loadPost:(FRSPost *)post {
    
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.userInteractionEnabled = YES;
        weakSelf.post = post;
        
        [weakSelf loadImage];
    });
}

- (void)loadImage {
    if(!self.post.imageUrl) return;
    
    [self.imageView sd_setImageWithURL:[NSURL
                                        URLResizedFromURLString:self.post.imageUrl
                                        width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                                        ]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 self.imageView.alpha = 1.0;
                             }];
}

- (void)dealloc {
    self.imageView.image = nil;
    self.post = nil;
}

@end
