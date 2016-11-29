//
//  FRSCarousel.m
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSCarousel.h"

@implementation FRSCarousel
@synthesize media = _media;

static NSString * const photoCell = @"photoCell";
static NSString * const videoCell = @"videoCell";

-(instancetype)init { 
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    self.delegate = self;
    self.dataSource = self;
    
    [self registerNib:[UINib nibWithNibName:@"FRSCarouselCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:photoCell];
    [self registerNib:[UINib nibWithNibName:@"FRSCarouselCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:videoCell];
}

-(UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_media count]) {
        return Nil;
    }
    
    PHAsset *representedAsset = [_media objectAtIndex:indexPath.row];
    
    if (representedAsset.mediaType == PHAssetMediaTypeVideo) {
        
    }
    else if (representedAsset.mediaType == PHAssetMediaTypeImage) {
        
    }
    return Nil;
}
@end
