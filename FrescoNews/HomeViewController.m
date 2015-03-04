//
//  FirstViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "HomeViewController.h"
#import "UIViewController+Additions.h"
#import "FRSDataManager.h"
#import "FRSTag.h"
#import "FRSStoryListCell.h"

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _posts = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setFrescoImageHeader];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *storyCellNib = [UINib nibWithNibName:@"FRSStoryListCell" bundle:[NSBundle mainBundle]];
    [_collectionView registerNib:storyCellNib forCellWithReuseIdentifier:[FRSStoryListCell identifier]];

    [self performNecessaryFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Loading
- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock
{
   // [self setActivityIndicatorVisible:YES];
    
    if([self tag] || !self.savedPosts){
        NSArray *tags = [self tag] ? @[[self tag]] : nil;
        [[FRSDataManager sharedManager] getPostsWithTags:tags limit:@5 responseBlock:^(NSArray *responseObject, NSError *error) {
            if (!error) {
                [[self posts] setArray:responseObject];
                [self cacheAndReload];
                [self setActivityIndicatorVisible:NO];
                if(responseBlock)
                    responseBlock(YES, nil);
            }
            
        }];
    }
    else if(self.savedPosts){
        [[self posts] setArray:self.savedPosts];
        [self cacheAndReload];
        [self setActivityIndicatorVisible:NO];
        if(responseBlock)
            responseBlock(YES, nil);
    }
    else
        [self setActivityIndicatorVisible:NO];
    
}
-(void)refreshData
{
    NSArray *tags = [self tag] ? @[[self tag]] : nil;
    
    [[FRSDataManager sharedManager] getPostsWithTags:tags limit:@([_posts count]) responseBlock:^(NSArray *responseObject, NSError *error) {
        if(!error){
            [[self posts] setArray:responseObject];
            [self cacheAndReload];
           // [self.refreshControl endRefreshing];
           // [[self listCollectionView] setContentOffset:CGPointZero animated:YES];
            
        }
    }];
}

- (void)cacheImagesForCurrentStories
{
    return;
    NSMutableArray *imageURLs = [[NSMutableArray alloc] initWithCapacity:[[self posts] count] * 3];
    
    for (FRSPost *story in [self posts]) {
        if ([story largeImageURL]) [imageURLs addObject:[story largeImageURL]];
    }
    
   // [[FRSCacheManager sharedManager] precacheImages:imageURLs];
}

- (void)reloadData
{
  //  [[self listCollectionView] reloadData];
  //  [[self detailCollectionView] reloadData];
    [self.collectionView reloadData];
}

- (void)cacheAndReload
{
    [self reloadData];
    [self cacheImagesForCurrentStories];
}

#pragma mark - loading view

- (void)setActivityIndicatorVisible:(BOOL)visible{
/*
    [_loadingView removeFromSuperview];
    
    [self setLoadingView:nil];
    
    if (visible) {
        UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGPoint viewCenter = [[self view] center];
        [actIndicator setCenter:viewCenter];
        [[self listCollectionView] addSubview:actIndicator];
        [actIndicator startAnimating];
        [self setLoadingView:actIndicator];
    }*/
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.posts count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger index = [indexPath item];
    
    //Get story for cell at this index
    FRSPost *cellStory = [[self posts] objectAtIndex:index];
   
    //If we are in the master list
    // if (collectionView == [self listCollectionView]) {
    
    FRSStoryListCell *storyCell = [collectionView dequeueReusableCellWithReuseIdentifier:[FRSStoryListCell identifier] forIndexPath:indexPath];
    [storyCell setPost:cellStory];
    
    return storyCell;
    
    //}
    /*
    //If we are in the detail list
    else if ([collectionView isEqual:[self detailCollectionView]]) {
        
        FRSStoryDetailCell *detailViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:[FRSStoryDetailCell identifier] forIndexPath:indexPath];
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"photoClicked"]){
            [detailViewCell.tapView setHidden:YES];
        } else {
            CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            pulseAnimation.duration = .5;
            pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
            pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pulseAnimation.autoreverses = YES;
            pulseAnimation.repeatCount = FLT_MAX;
            [detailViewCell.tapView.layer addAnimation:pulseAnimation forKey:nil];
        }
        UITapGestureRecognizer *tapGestureRecognizer =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        
        [tapGestureRecognizer setCancelsTouchesInView:NO];
        
        [detailViewCell addGestureRecognizer:tapGestureRecognizer];
        
        [detailViewCell.scrollView setDelegate:self];
        [detailViewCell setPost:cellStory];
        detailViewCell.isWeb = false;
        
        return detailViewCell;
    }
    
    return nil;*/
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, 339);
}
@end
