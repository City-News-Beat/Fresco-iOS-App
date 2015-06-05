//
//  PostCollectionViewCell.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PostCollectionViewCell.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "UIImage+ALAsset.h"

static NSString * const kCellIdentifier = @"PostCollectionViewCell";


@implementation PostCollectionViewCell
+ (NSString *)identifier
{
    return kCellIdentifier;
}

-(void)prepareForReuse{
    [[self imageView] setImage:nil];
    [[self imageView] cancelImageRequestOperation];
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    __weak PostCollectionViewCell *weakSelf = self;

    if (_post.postID) {
        [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[_post largeImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.imageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

        }];
    }
    else {
        // local
        self.imageView.image = [UIImage imageFromAsset:post.image.asset];
    }
}

@end
