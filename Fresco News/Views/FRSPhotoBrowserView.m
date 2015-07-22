//
//  FRSPhotoBrowserView.m
//  Fresco
//
//  Created by Team Fresco on 3/4/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSPhotoBrowserView.h"
#import "FRSPhotoMotionCollectionViewCell.h"

@interface FRSPhotoBrowserView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSArray *images;

- (void)commonInit;

@end

@implementation FRSPhotoBrowserView

#pragma mark - view lifecycle

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
         [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumInteritemSpacing:0.f];
    [layout setMinimumLineSpacing:0.f];
    [layout setSectionInset:UIEdgeInsetsZero];
    _collectionView = [[UICollectionView alloc] initWithFrame:[self bounds] collectionViewLayout:layout];
    
    [_collectionView registerClass:[FRSPhotoMotionCollectionViewCell class] forCellWithReuseIdentifier:[FRSPhotoMotionCollectionViewCell identifier]];
    [_collectionView setPagingEnabled:YES];
    
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    
    [self addSubview:_collectionView];
    
    [_collectionView setBackgroundColor:[UIColor blackColor]];
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect collectionViewFrame = [self bounds];
    [[self collectionView] setFrame:collectionViewFrame];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[[self collectionView] collectionViewLayout];
    
    [layout setItemSize:collectionViewFrame.size];
    
    [[[self collectionView] collectionViewLayout] invalidateLayout];
}

#pragma mark - images

- (void)setImages:(NSArray *)images withInitialIndex:(NSUInteger)imageIndex
{
    if (_images != images) {
        
        _images = images;
        
        [[self collectionView] reloadData];
        
        CGFloat width = CGRectGetWidth([[self collectionView] bounds]);
        CGFloat offset = imageIndex * width;
        
        [[self collectionView] setContentOffset:CGPointMake(offset, 0.f)];
        
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self images] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FRSPhotoMotionCollectionViewCell *cell = (FRSPhotoMotionCollectionViewCell *)[collectionView
                                                                                  dequeueReusableCellWithReuseIdentifier:[FRSPhotoMotionCollectionViewCell identifier]
                                                                                  forIndexPath:indexPath];
    
    if ([[self captions] count] > [indexPath item]) {
        [cell setCaption:[[self captions] objectAtIndex:[indexPath item]]];
    }
    
    NSURL *imageURL = [[self images] objectAtIndex:[indexPath item]];
    
    [cell setImageWithURL:imageURL];
    
    return cell;
}

@end

