//
//  FRSGalleryItemsView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryMediaView.h"
#import "FRSGalleryMediaImageCollectionViewCell.h"
#import "FRSGalleryMediaVideoCollectionViewCell.h"
#import "FRSGallery.h"

static NSString *ImageCellIdentifier = @"FRSGalleryMediaImageCellIdentifier";
static NSString *VideoCellIdentifier = @"FRSGalleryMediaVideoCellIdentifier";

@interface FRSGalleryMediaView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FRSGalleryMediaVideoCollectionViewCellDelegate>

@property (weak, nonatomic) NSObject<FRSGalleryMediaViewDelegate> *delegate;
@property (strong, nonatomic) NSArray *orderedPosts;
//@property (strong, nonatomic) FRSGalleryMediaCollectionViewCell *currentCell;

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

-(instancetype)initWithFrame:(CGRect)frame posts:(NSArray *)posts delegate:(id<FRSGalleryMediaViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self commonInit];
        [self loadPosts:posts];
    }
    return self;
}

-(void)commonInit {
    //register nib
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FRSGalleryMediaImageCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:ImageCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FRSGalleryMediaVideoCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:VideoCellIdentifier];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delaysContentTouches = FALSE;
}

-(void)loadPosts:(NSArray *)posts {
    self.userInteractionEnabled = YES;
    self.orderedPosts = posts;
    [self updateScrollView];
    [self.collectionView reloadData];
}

- (void)updateScrollView {
    if (self.collectionView.contentOffset.x >= 0 && self.orderedPosts.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.orderedPosts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *mediaCell;
    
    FRSPost *post = self.orderedPosts[indexPath.row];
    if(post.videoUrl){
        FRSGalleryMediaVideoCollectionViewCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCellIdentifier forIndexPath:indexPath];
        if(!videoCell.delegate) {
            videoCell.delegate = self;
        }
        [videoCell loadPost:post];
        mediaCell = videoCell;
    }
    else {
        FRSGalleryMediaImageCollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier forIndexPath:indexPath];
        [imageCell loadPost:post];
        [self configureMuteIconDisplay:NO];
        mediaCell = imageCell;
    }
    
    //    self.currentCell = cell;
    return mediaCell;
}

#pragma mark - UICollectionViewDelegateFlowLayouts

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width, [self imageViewHeight]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Mostly sure we can select only once its loaded.
    //    [self.currentCell tap];
    //    UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    //    if ([cell isKindOfClass:[FRSGalleryMediaVideoCollectionViewCell class]]) {
    //        [(FRSGalleryMediaVideoCollectionViewCell *)cell tap];
    //    }
    //
    //    if (collectionView.visibleCells.count == 0) {
    //        return;
    //    }
    
    //    UICollectionViewCell *firstCell = collectionView.visibleCells[0];
    //    if ([firstCell isKindOfClass:[FRSGalleryMediaVideoCollectionViewCell class]]) {
    //        [(FRSGalleryMediaVideoCollectionViewCell *)firstCell tap];
    //    }
    
    //    cell.videoPlayer.muted = !cell.videoPlayer.muted;
    //    [cell tap];
}

#pragma mark - Utilities

- (NSInteger)imageViewHeight {
    //TODO: Scroll - we can avoid calculation everytime by saving against a gallery obj.
    NSInteger totalHeight = 0;
    
    for (FRSPost *post in self.orderedPosts) {
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight == 0 || rawWidth == 0) {
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        } else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width / rawWidth);
            totalHeight += scaledHeight;
        }
    }
    
    float divider = self.orderedPosts.count;
    if (divider == 0) {
        divider = 1;
    }
    
    NSInteger averageHeight = totalHeight / divider;
    
    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4 / 3);
    
    return averageHeight > 0 ? averageHeight : 280;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"media scrollViewDidScroll");
    if ([self.delegate respondsToSelector:@selector(mediaScrollViewDidScroll:)]) {
        [self.delegate mediaScrollViewDidScroll:scrollView];
    }
    
    //pause all visible players
    [self pause];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"media scrollViewDidEndDecelerating");
    //    if ([self.delegate respondsToSelector:@selector(mediaScrollViewDidEndDecelerating:)]) {
    //        [self.delegate mediaScrollViewDidEndDecelerating:scrollView];
    //    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"Current page -> %ld",(long)page);
    
    if ([self.delegate respondsToSelector:@selector(mediaDidChangeToPage:)]) {
        [self.delegate mediaDidChangeToPage:page];
    }
    
    [self play];
    //    self.pageControl.currentPage = page;
    
    //    self.currentPage = page;
    //    if (self.players.count > page) {
    //        self.videoPlayer = ([self.players[page] respondsToSelector:@selector(play)]) ? self.players[page] : Nil;
    //        [self.videoPlayer play];
    //    }
    
    //    [self configureMuteIcon];
}


/*
 - (void)dealloc {
 for (FRSPlayer *player in self.players) {
 if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
 [player.currentItem cancelPendingSeeks];
 [player.currentItem.asset cancelLoading];
 }
 }
 
 self.players = Nil;
 self.videoPlayer = Nil;
 }
 
 */

-(void)play {
    if (!self.collectionView.visibleCells.count) {
        NSLog(@"oops no visible cells. This can never occur though.");
        return;
    }
    
    //pause all visible players before playing the current one.
    //    [self pause];
    
    //visible cells doesnot work when we drag very little and leave. So consider current page number. play is called only after the scroll did end decelerate. just check which visible cell matches the current xposition of the current page.
    
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger page = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"rev play collection view current page -> %ld",(long)page);
    
    for (UICollectionViewCell *visibleCell in self.collectionView.visibleCells) {
        //get the accurate visible cell matching the page.
        NSLog(@"rev visibleCell x: %f expected page x: %f \nCELL: %@", visibleCell.frame.origin.x, pageWidth*page, visibleCell);
        if (visibleCell.frame.origin.x != pageWidth*page) {
            continue;
        }
        BOOL displayMuteIcon = NO;
        if ([visibleCell isKindOfClass:[FRSGalleryMediaVideoCollectionViewCell class]]) {
            NSLog(@"rev visibleCell is video cell ");
            NSLog(@"visibleCell playing");
            displayMuteIcon = YES;
            [(FRSGalleryMediaVideoCollectionViewCell *)visibleCell play];
        }
        else {
            NSLog(@"rev visibleCell is image");
        }
        [self configureMuteIconDisplay:displayMuteIcon];
        //we should have decided the landed cell by now. So get out of this loop.
        break;

    }
    //    UICollectionViewCell *visibleCell = self.collectionView.visibleCells[0];
    //    if ([visibleCell isKindOfClass:[FRSGalleryMediaVideoCollectionViewCell class]]) {
    //        [(FRSGalleryMediaVideoCollectionViewCell *)visibleCell play];
    //    }
}

-(void)configureMuteIconDisplay:(BOOL)display {
    if([self.delegate respondsToSelector:@selector(mediaShouldShowMuteIcon:)]) {
        [self.delegate mediaShouldShowMuteIcon:display];
    }
}

-(void)pause {
    for (UICollectionViewCell *visibleCell in self.collectionView.visibleCells) {
        if ([visibleCell isKindOfClass:[FRSGalleryMediaVideoCollectionViewCell class]]) {
            NSLog(@"pausing.. cell.. : %@", visibleCell);
            [(FRSGalleryMediaVideoCollectionViewCell *)visibleCell pause];
        }
    }
}

-(void)offScreen {
    /*
     for (FRSPlayer *player in self.players) {
     if ([[player class] isSubclassOfClass:[FRSPlayer class]]) {
     [player.currentItem cancelPendingSeeks];
     [player.currentItem.asset cancelLoading];
     
     for (CALayer *layer in player.container.layer.sublayers) {
     [layer removeFromSuperlayer];
     }
     
     player.hasEstablished = FALSE;
     }
     }
     
     */
}

#pragma mark - FRSGalleryMediaVideoCollectionViewCellDelegate

-(void)mediaShouldShowMuteIcon:(BOOL)show {
    [self configureMuteIconDisplay:show];
}


@end
