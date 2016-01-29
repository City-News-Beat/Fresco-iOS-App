//
//  GalleryPostCollectionViewCell.m
//  Fresco
//
//  Created by Daniel Sun on 12/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "GalleryPostCollectionViewCell.h"

#import "FRSPost.h"
#import "FRSImage.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@import Photos;

static NSString * const kCellIdentifier = @"PostCollectionViewCell";

@interface GalleryPostCollectionViewCell ()

@property (nonatomic, strong) UIImageView *transcodeImage;

@property (nonatomic, strong) UILabel *transcodeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewAspectRatio;

@property (strong, nonatomic) UIColor *color;

@end

@implementation GalleryPostCollectionViewCell

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
    
    __weak GalleryPostCollectionViewCell *weakSelf = self;
    
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

        //Add subviews and bring to the front so they don't get hidden
        [weakSelf addSubview:weakSelf.playPause];
        [weakSelf addSubview:weakSelf.mutedImage];
        [weakSelf bringSubviewToFront:weakSelf.playPause];
        
    }

    // local
    [[PHImageManager defaultManager]
     requestImageForAsset:post.image.asset
     targetSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
     contentMode:PHImageContentModeDefault
     options:nil
     resultHandler:^(UIImage * result, NSDictionary * info) {
         
         weakSelf.imageView.image  = result;
         
     }];
    
    [self configureTranscodingImage];
}

- (void)configureTranscodingImage {
    
    [self GetCurrentPixelColorAtPoint:CGPointMake(self.imageView.center.x, self.imageView.center.y)];
    
    
    const CGFloat* components = CGColorGetComponents(self.color.CGColor);
    NSLog(@"Red: %f", components[0]);
    NSLog(@"Green: %f", components[1]);
    NSLog(@"Blue: %f", components[2]);
    NSLog(@"Alpha: %f", CGColorGetAlpha(self.color.CGColor));
    
    CGFloat colorValue = components[0] + components[1] + components[2] +components[3];
    NSLog(@"colorValue = %f", colorValue);
    
    
    if (colorValue < 1) {
        NSLog(@"transcode image should be light");
        self.transcodeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transcoding-light"]];
    } else {
        NSLog(@"transcode image should be dark");
        self.transcodeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transcoding-dark"]];
        self.transcodeImage.alpha = 0.87;
    }
    
    self.transcodeImage.frame = CGRectMake(self.frame.size.width/2 - self.transcodeImage.frame.size.width/2, self.frame.size.height/2 - self.transcodeImage.frame.size.height/2, self.transcodeImage.frame.size.width, self.transcodeImage.frame.size.height);
    [self addSubview:self.transcodeImage];
    
    self.transcodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2 + 40, self.frame.size.width, 20)];
    self.transcodeLabel.text = @"Processing image";
    self.transcodeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.transcodeLabel.alpha = 0.87;
    self.transcodeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.transcodeLabel];
    
}




- (UIColor *) GetCurrentPixelColorAtPoint:(CGPoint)point {
    
    unsigned char centerPixel[4] = {0};

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(centerPixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [self.imageView.layer renderInContext:context];
    NSLog(@"centerPixel: %d %d %d %d", centerPixel[0], centerPixel[1], centerPixel[2], centerPixel[3]);
    
//    self.color should = average RGB value
    self.color = [UIColor colorWithRed:centerPixel[0]/255.0 green:centerPixel[1]/255.0 blue:centerPixel[2]/255.0 alpha:centerPixel[3]/255.0];

    return self.color;
}




//- (BOOL)isWallPixel:(UIImage *)image xCoordinate:(int)x yCoordinate:(int)y {
//    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
//    const UInt8* data = CFDataGetBytePtr(pixelData);
//    
//    int pixelInfo = ((image.size.width  * y) + x ) * 4; // The image is png
//    
//    UInt8 red = data[pixelInfo];         // If you need this info, enable it
//    UInt8 green = data[(pixelInfo + 1)]; // If you need this info, enable it
//    UInt8 blue = data[pixelInfo + 2];    // If you need this info, enable it
//    UInt8 alpha = data[pixelInfo + 3];     // I need only this info for my maze game
//    CFRelease(pixelData);
//    
//    UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
//    
//    NSLog(@"color = %@", color);
//    
//    if (alpha) return YES;
//    else return NO;
//}

- (void)createTranscodingPlaceHolder{
   
    self.transcodeLabel.hidden = NO;
    self.transcodeImage.hidden = NO;
}


- (void)removeTranscodePlaceHolder{
    
    self.transcodeLabel.hidden = YES;
    self.transcodeImage.hidden = YES;
    
    [self.transcodeImage removeFromSuperview];
    [self.transcodeLabel removeFromSuperview];
}

@end
