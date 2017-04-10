//
//  FRSGalleryMediaCollectionViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaCollectionViewCell.h"
#import <Haneke/Haneke.h>
#import "NSURL+Fresco.h"
#import "FRSPost.h"

@interface FRSGalleryMediaCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) FRSPost *post;

@end

@implementation FRSGalleryMediaCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)loadPost:(FRSPost *)post {
    self.post = post;
    [self loadImage];
}

- (void)loadImage {
    if(!self.post.imageUrl) return;
        
    [self.imageView
     hnk_setImageFromURL:[NSURL
                          URLResizedFromURLString:self.post.imageUrl
                          width:([UIScreen mainScreen].bounds.size.width * [[UIScreen mainScreen] scale])
                          ]
     ];
}

@end
