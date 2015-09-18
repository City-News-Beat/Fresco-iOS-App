//
//  PostCollectionViewCell.m
//  FrescoNews
//
//  Created by Fresco News on 3/25/15.
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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewAspectRatio;

@end

@implementation PostCollectionViewCell

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
    
    __weak PostCollectionViewCell *weakSelf = self;

    if (_post.postID) {

        CGRect spinnerFrame = CGRectMake(weakSelf.frame.size.width/2, weakSelf.frame.size.height/2, 0, 0);
        
        self.photoIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.photoIndicatorView.frame = spinnerFrame;
        [self addSubview:weakSelf.photoIndicatorView];
        [self bringSubviewToFront:weakSelf.photoIndicatorView];

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
            
            //Set up for muted icon button
            weakSelf.mutedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            weakSelf.mutedImage.center = CGPointMake(weakSelf.frame.size.width - 24 , 20);
            weakSelf.mutedImage.contentMode = UIViewContentModeScaleAspectFit;
            weakSelf.mutedImage.clipsToBounds = NO;
            weakSelf.mutedImage.alpha = 1;
            weakSelf.mutedImage.image = [UIImage imageNamed:@"volume-off"];
    
           
            //Add subviews and bring to the front so they don't get hidden
            [weakSelf addSubview:weakSelf.playPause];
            [weakSelf addSubview:weakSelf.mutedImage];
            [weakSelf bringSubviewToFront:weakSelf.playPause];
            [weakSelf bringSubviewToFront:weakSelf.mutedImage];

        }
    
        
        //back to the main thread for the UI call
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.photoIndicatorView startAnimating];
        });
    
        [weakSelf.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.post largeImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            weakSelf.imageView.image = image;
            
            weakSelf.imageView.alpha = 1.0f;
            
            //back to the main thread for the UI call
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.photoIndicatorView stopAnimating];
            });

        } failure:nil];
        
    }
    else {
        // local
        weakSelf.imageView.image = [UIImage imageFromAsset:post.image.asset];
    }
}

- (void)removeTranscodePlaceHolder{
    
    self.transcodeLabel.hidden = YES;
    self.transcodeImage.hidden = YES;

    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];

}

@end
