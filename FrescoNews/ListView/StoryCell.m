//
//  StoryCell.m
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "StoryCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FRSUser.h"
#import "FRSImage.h"

static NSString * const kCellIdentifier = @"StoryCell";

@interface StoryCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@end
@implementation StoryCell

+ (NSString *)identifier
{
    return kCellIdentifier;
}

+ (NSAttributedString *)attributedStringForCaption:(NSString *)caption date:(NSString *)date
{
    return [[NSMutableAttributedString alloc] initWithString:caption attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
}

- (void)awakeFromNib
{
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setPost:(FRSPost *)post
{
    _post = post;
    
    // set the caption
    [[self captionLabel] setAttributedText:[[self class] attributedStringForCaption:self.post.caption date:[MTLModel relativeDateStringFromDate:self.post.date]]];
    
    // set the image
    __weak StoryCell *weakSelf = self;
    
    CGSize size = [self imageSizeInPoints];
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor redColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.postImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[_post largeImageURL]] placeholderImage:image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.postImageView.image = image;
        /*[weakSelf updateConstraints];
        [weakSelf layoutIfNeeded];
        [weakSelf setNeedsLayout];
        [weakSelf setNeedsDisplay];*/
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //[weakSelf updateConstraints];
    }];
    [self updateConstraints];
    [weakSelf layoutIfNeeded];
    [weakSelf setNeedsLayout];
    [weakSelf setNeedsDisplay];
}

- (void)layoutSubviews
{
    CGSize size = [self imageSizeInPoints];
    self.constraintHeight.priority = 999;
    self.constraintHeight.constant = size.height;
    [self updateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];

}

- (void)dealloc
{
    [[self imageView] cancelImageRequestOperation];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageView cancelImageRequestOperation];
    self.constraintHeight.priority = 1;
    self.constraintHeight.constant = 208;
    self.imageView.image = nil;
}

- (CGSize)imageSizeInPoints
{
    CGFloat inverseAspectRatio = [self.post.largeImage.height floatValue] / [self.post.largeImage.width floatValue];
    CGFloat height = self.frame.size.width * inverseAspectRatio;
    NSLog(@"w: %f h: %f", self.frame.size.width, height);
    return CGSizeMake(self.frame.size.width, height);
}
@end
