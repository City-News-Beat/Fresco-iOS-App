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

static NSString * const kCellIdentifier = @"PostCollectionViewCell";

@interface PostCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation PostCollectionViewCell
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    __weak PostCollectionViewCell *weakSelf = self;
    
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[_post largeImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

    }];
}

@end
