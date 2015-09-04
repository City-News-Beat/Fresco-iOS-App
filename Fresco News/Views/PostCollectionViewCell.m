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

    [self.videoIndicatorView removeFromSuperview];
    [self.photoIndicatorView removeFromSuperview];
    
    [self removeTranscodePlaceHolder];
    
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    __weak PostCollectionViewCell *weakSelf = self;

    if (_post.postID) {

        CGRect spinnerFrame = CGRectMake(self.frame.size.width/2, self.frame.size.height/2, 0, 0);
        CGPoint spinnerCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        self.photoIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.photoIndicatorView.frame = spinnerFrame;
        [self addSubview:self.photoIndicatorView];
        [self bringSubviewToFront:self.photoIndicatorView];

        if(self.post.isVideo) {
            
            //Set up for play/pause button
            self.playPause = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 132/2, 132/2)];
            self.playPause.center = CGPointMake(weakSelf.frame.size.width / 2 , weakSelf.center.y);
            self.playPause.contentMode = UIViewContentModeScaleAspectFit;
            self.playPause.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.20].CGColor;
            self.playPause.layer.shadowOffset = CGSizeMake(0, 1);
            self.playPause.layer.shadowOpacity = 1;
            self.playPause.layer.shadowRadius = 1.0;
            self.playPause.clipsToBounds = NO;
            self.playPause.alpha = 0;
            self.playPause.image = [UIImage imageNamed:@"pause"];
            
            //Set up for indicator view
            self.videoIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
            self.videoIndicatorView.center = spinnerCenter;
            self.videoIndicatorView.transform = CGAffineTransformMakeScale(1.25, 1.25);
            self.videoIndicatorView.alpha = 0;
            self.videoIndicatorView.hidden = YES;
            
           
            //Add subviews and bring to the front so they don't get hidden
            [self addSubview:self.playPause];
            [self addSubview:self.videoIndicatorView];
            [self bringSubviewToFront:self.videoIndicatorView];
            [self bringSubviewToFront:self.playPause];

        }
    
        
        //back to the main thread for the UI call
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoIndicatorView startAnimating];
        });
    
        [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.post largeImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            self.processingVideo = false;
            
            weakSelf.imageView.image = image;
            
            weakSelf.imageView.alpha = 1.0f;
            
            [weakSelf removeTranscodePlaceHolder];
            
            //back to the main thread for the UI call
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photoIndicatorView stopAnimating];
                [self.photoIndicatorView removeFromSuperview];
            });

        } failure:nil];
        
    }
    else {
        // local
        self.imageView.image = [UIImage imageFromAsset:post.image.asset];
    }
}

- (void)removeTranscodePlaceHolder{
    
    self.transcodeLabel.hidden = YES;
    self.transcodeImage.hidden = YES;

    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];

}

@end
