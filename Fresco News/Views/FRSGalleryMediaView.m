//
//  FRSGalleryItemsView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaView.h"
#import "FRSGalleryMediaCollectionViewCell.h"
#import "FRSGallery.h"

static NSString *cellIdentifier = @"FRSGalleryMediaCollectionViewCellIdentifier";

@interface FRSGalleryMediaView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) NSArray *orderedPosts;
@end

@implementation FRSGalleryMediaView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {cal
    // Drawing code
}
*/

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame andGallery:(FRSGallery *)gallery {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        
        [self loadGallery:gallery];
    }
    return self;
}

-(void)commonInit {
    //register nib
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FRSGalleryMediaCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delaysContentTouches = FALSE;
}

-(void)loadGallery:(FRSGallery *)gallery {
    self.gallery = gallery;
    
    self.orderedPosts = [gallery.posts allObjects];
    self.orderedPosts = [self.orderedPosts sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:TRUE] ]];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.orderedPosts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRSGalleryMediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell loadPost:self.orderedPosts[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayouts

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width, [self imageViewHeight]);
}

#pragma mark - Utilities

- (NSInteger)imageViewHeight {
    NSInteger totalHeight = 0;
    
    for (FRSPost *post in self.gallery.posts) {
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight == 0 || rawWidth == 0) {
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        } else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width / rawWidth);
            totalHeight += scaledHeight;
        }
    }
    
    float divider = self.gallery.posts.count;
    if (divider == 0) {
        divider = 1;
    }
    
    NSInteger averageHeight = totalHeight / divider;
    
    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4 / 3);
    
    return averageHeight > 0 ? averageHeight : 280;
}

@end
