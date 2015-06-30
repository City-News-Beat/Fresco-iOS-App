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

@interface PostCollectionViewCell ()

@property (nonatomic, strong) UIImageView *transcodeImage;

@property (nonatomic, strong) UILabel *transcodeLabel;

@end

@implementation PostCollectionViewCell
+ (NSString *)identifier
{
    return kCellIdentifier;
}

-(void)prepareForReuse{
    [[self imageView] setImage:nil];
    [[self imageView] cancelImageRequestOperation];
    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    __weak PostCollectionViewCell *weakSelf = self;
    
    if(self.post.isVideo) {
    
        self.playPause = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x, self.center.y, 132/2, 132/2)];
        self.playPause.center = self.center;
        self.playPause.contentMode = UIViewContentModeScaleAspectFit;
        self.playPause.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.20].CGColor;
        self.playPause.layer.shadowOffset = CGSizeMake(0, 1);
        self.playPause.layer.shadowOpacity = 1;
        self.playPause.layer.shadowRadius = 1.0;
        self.playPause.clipsToBounds = NO;
        self.playPause.image = [UIImage imageNamed:@"pause"];
        
        [self addSubview:self.playPause];
        [self bringSubviewToFront:self.playPause];
        self.playPause.alpha = 0;
    
    }

    if (_post.postID) {
        [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[_post largeImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            [self.transcodeImage removeFromSuperview];
            [self.transcodeLabel removeFromSuperview];
            
            weakSelf.imageView.image = image;
            
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
            if(response.statusCode == 403 && self.post.isVideo){
                
                self.processingVideo = true;
            
                self.transcodeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transcoding"]];

                self.transcodeImage.image = [UIImage imageNamed:@"transcoding"];
                self.transcodeImage.frame = CGRectMake(0, 0, 150, 150);
                self.transcodeImage.center = self.center;
            
                self.transcodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 80)];
                self.transcodeLabel.text = @"We’re still processing this video!";
                self.transcodeLabel.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                self.transcodeLabel.center = CGPointMake(self.center.x, self.center.y + 100);
                self.transcodeLabel.textAlignment = NSTextAlignmentCenter;

                [weakSelf addSubview:self.transcodeImage];
                [weakSelf addSubview:self.transcodeLabel];
                
            }
            
        }];
    }
    else {
        // local
        self.imageView.image = [UIImage imageFromAsset:post.image.asset];
   
    }
}

@end
