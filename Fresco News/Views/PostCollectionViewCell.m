//
//  PostCollectionViewCell.m
//  FrescoNews
//
//  Created by Fresco News on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//


#import "PostCollectionViewCell.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@import Photos;

static NSString * const kCellIdentifier = @"PostCollectionViewCell";

@interface PostCollectionViewCell ()

@property (nonatomic, strong) UIImageView *transcodeImage;

@property (nonatomic, strong) UILabel *transcodeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewAspectRatio;

@property (strong, nonatomic) UIColor *color;

@property BOOL isWhite;

@end

@implementation PostCollectionViewCell

+ (NSString *)identifier
{
    return kCellIdentifier;
}

-(void)prepareForReuse{
    
    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];
    
    
//    [[self imageView] setImage:nil];
//    
//    [[self imageView] cancelImageRequestOperation];
//    
//    [self.photoIndicatorView removeFromSuperview];
//    
//    [self.mutedImage removeFromSuperview];
//    
//    [self.transcodeImage removeFromSuperview];
//    
//    [self.transcodeLabel removeFromSuperview];
    
}

-(void)clearCell{
    self.imageView.image = nil;
    self.playPause = nil;
    self.mutedImage = nil;
    [self.photoIndicatorView removeFromSuperview];
    
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    
}

-(void)configureCell{
    
    if (_post.postID) {
        
        CGRect spinnerFrame = CGRectMake(self.frame.size.width/2, self.frame.size.height/2, 0, 0);
        
        self.photoIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.photoIndicatorView.frame = spinnerFrame;
        [self addSubview:self.photoIndicatorView];
        [self bringSubviewToFront:self.photoIndicatorView];
        
        if(self.post.isVideo) {
            
            //Set up for play/pause button
            self.playPause = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            self.playPause.center = CGPointMake(self.frame.size.width / 2 , self.center.y);
            self.playPause.contentMode = UIViewContentModeScaleAspectFit;
            self.playPause.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.20].CGColor;
            self.playPause.layer.shadowOffset = CGSizeMake(0, 1);
            self.playPause.layer.shadowOpacity = 1;
            self.playPause.layer.shadowRadius = 1.0;
            self.playPause.clipsToBounds = NO;
            self.playPause.alpha = 0;
            self.playPause.image = [UIImage imageNamed:@"pause"];
            
            //Set up for muted icon button
            self.mutedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            self.mutedImage.center = CGPointMake(self.frame.size.width - 24 , 20);
            self.mutedImage.contentMode = UIViewContentModeScaleAspectFit;
            self.mutedImage.clipsToBounds = NO;
            self.mutedImage.alpha = 1;
            self.mutedImage.image = [UIImage imageNamed:@"volume-off"];
            
            
            //Add subviews and bring to the front so they don't get hidden
            [self addSubview:self.playPause];
            [self addSubview:self.mutedImage];
            [self bringSubviewToFront:self.playPause];
            [self bringSubviewToFront:self.mutedImage];
            
        }
        
        //back to the main thread for the UI call
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoIndicatorView startAnimating];
        });
        
        [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[self.post.image mediumImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            self.imageView.image = image;
            
            self.imageView.alpha = 1.0f;
            
            //back to the main thread for the UI call
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photoIndicatorView stopAnimating];
            });
            
        } failure:nil];
        
    }
    else {
        // local
        [[PHImageManager defaultManager]
         requestImageForAsset:self.post.image.asset
         targetSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
         contentMode:PHImageContentModeDefault
         options:nil
         resultHandler:^(UIImage * result, NSDictionary * info) {
             
             self.imageView.image  = result;
             
         }];
    }
}

- (void)removeTranscodePlaceHolder{
    
    self.transcodeLabel.hidden = YES;
    self.transcodeImage.hidden = YES;
    
    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];
    
}

- (void)configureTranscodingImage {
    
    [self getCurrentPixelValueFromPoint:CGPointMake(self.imageView.center.x, self.imageView.center.y)];
    
    const CGFloat* components = CGColorGetComponents(self.color.CGColor);
    NSLog(@"Red: %f", components[0]);
    NSLog(@"Green: %f", components[1]);
    NSLog(@"Blue: %f", components[2]);
    NSLog(@"Alpha: %f", CGColorGetAlpha(self.color.CGColor));
    
    CGFloat colorValue = components[0] + components[1] + components[2] +components[3];
    NSLog(@"colorValue = %f", colorValue);
    
    //    if (colorValue < 1.5) {
    //        self.isWhite = YES;
    //        NSLog(@"transcode image should be light");
    //        self.transcodeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transcoding-light"]];
    //        self.transcodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2 + 40, self.frame.size.width, 20)];
    //        [self.transcodeLabel setTextColor:[UIColor whiteColor]];
    //
    //    } else {
    self.isWhite = NO;
    NSLog(@"transcode image should be dark");
    self.transcodeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transcoding-dark"]];
    self.transcodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2 + 40, self.frame.size.width, 20)];
    
    //    }
    
    self.transcodeImage.frame = CGRectMake(self.frame.size.width/2 - self.transcodeImage.frame.size.width/2, self.frame.size.height/2 - self.transcodeImage.frame.size.height/2, self.transcodeImage.frame.size.width, self.transcodeImage.frame.size.height);
    self.transcodeImage.alpha = 0;
    [self addSubview:self.transcodeImage];
    
    self.transcodeLabel.text = @"Processing image";
    self.transcodeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.transcodeLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.transcodeLabel];
}




- (UIColor *) getCurrentPixelValueFromPoint:(CGPoint)centerPoint {
    
    unsigned char centerPixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(centerPixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -centerPoint.x, -centerPoint.y);
    [self.imageView.layer renderInContext:context];
    NSLog(@"centerPixel: %d %d %d %d", centerPixel[0], centerPixel[1], centerPixel[2], centerPixel[3]);
    
    //    self.color should = average RGB value
    self.color = [UIColor colorWithRed:centerPixel[0]/255.0 green:centerPixel[1]/255.0 blue:centerPixel[2]/255.0 alpha:centerPixel[3]/255.0];
    return self.color;
}

-(void)showTranscodingImage{
    if (self.isWhite) {
        self.transcodeLabel.alpha = 1;
        self.transcodeImage.alpha = 1;
    } else {
        self.transcodeLabel.alpha = 0.54;
        self.transcodeImage.alpha = 0.54;
    }
}


-(void)hideTranscodingImage{
    self.transcodeLabel.alpha = 0;
    self.transcodeImage.alpha = 0;
}


@end
