//
//  GallleryPostViewController.m
//  Fresco
//
//  Created by Daniel Sun on 12/15/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "GalleryPostViewController.h"

@import Parse;
@import FBSDKCoreKit;
@import FBSDKShareKit;
@import AssetsLibrary;
@import Photos;

#import "AFNetworking.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "GalleryView.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "FRSTabBarController.h"
#import "FRSCameraViewController.h"
#import "FRSDataManager.h"
#import "FirstRunViewController.h"
#import "FRSSocialButton.h"
#import "FRSRootViewController.h"
#import "FRSUploadManager.h"
#import "FRSBackButton.h"
#import "GalleryPostCollectionViewCell.h"
#import "FRSAssignmentChoiceCell.h"
#import "FRSPhotoBrowserView.h"
#import "FRSLocationManager.h"
#import "UIView+Helpers.h"

#import "FRSDataManager.h"

typedef NS_ENUM(NSUInteger, ScrollViewDirection) {
    scrollViewDirectionUp,
    scrollViewDirectionDown
};

@interface GalleryPostViewController () <UITextViewDelegate, UIAlertViewDelegate, FRSUploadManagerDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FRSBackButtonDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UITableView *assignmentTV;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UICollectionView *galleryCV;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIView *tvSeparatorLine;

@property (strong, nonatomic) UIView *topBar;
@property (strong, nonatomic) FRSBackButton *backButton;

@property (strong, nonatomic) FRSSocialButton *facebookButton;
@property (strong, nonatomic) FRSSocialButton *twitterButton;
@property (strong, nonatomic) UIView *socialContainer;

@property (strong, nonatomic) UITextView *captionTextView;

@property (nonatomic, strong) AVPlayer *sharedPlayer;
@property (nonatomic, strong) AVPlayerLayer *sharedLayer;
@property (nonatomic, strong) AVPlayerItem *sharedItem;

@property (strong, nonatomic) UIView *socialTipView;

@property (nonatomic, strong) FRSPhotoBrowserView *photoBrowserView;

@property (strong, nonatomic) UIPageControl *pageControl;

@property (nonatomic) NSInteger lastYOffset;
@property (nonatomic) ScrollViewDirection scrollViewDirection;

@property (strong, nonatomic) GalleryPostCollectionViewCell *zoomCell;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic) CGFloat originalContentOffset;



@property (strong, nonatomic) UITapGestureRecognizer *resignKeyboardGR;

@property (nonatomic) NSIndexPath *playingIndex;

@property (nonatomic) CGFloat keyboardOffset;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskID;


@end

@implementation GalleryPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchNearbyAssignments];
    
    [self customizeNavBar];
    [self configureUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.resignKeyboardGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    [self.navigationController.toolbar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitGalleryPost:)]];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self toggleToolbarAppearance];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self cleanUpVideoPlayer];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - UI Configuration

-(void)customizeNavBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    self.backButton = [FRSBackButton createLightBackButtonWithTitle:@"Media"];
    self.backButton.frame = CGRectMake(self.backButton.frame.origin.x, 12, self.backButton.frame.size.width, self.backButton.frame.size.height);
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topBar addSubview:self.backButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 56, self.backButton.frame.origin.y, 56, self.backButton.frame.size.height)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.layer.shadowColor = [UIColor frescoShadowColor].CGColor;
    cancelButton.layer.shadowOffset = CGSizeMake(0, 2);
    cancelButton.layer.shadowOpacity =  1.0;
    cancelButton.layer.shadowRadius = 2.0;
    
    [cancelButton addTarget:self action:@selector(handleCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:cancelButton];
}

-(void)fetchNearbyAssignments{
    
//    NSMutableArray *locations = [NSMutableArray new];
    
    [[FRSDataManager sharedManager] getAssignmentsWithinRadius:50 ofLocation:[FRSLocationManager sharedManager].location.coordinate withResponseBlock:^(id responseObject, NSError *error) {
        
        // Find a photo that is within an assignment radius
        for (FRSPost *post in self.gallery.posts) {
            
            CLLocation *location = post.image.asset.location;
            
            if(location != nil){
                
                for (FRSAssignment *assignment in responseObject) {
                    if ([assignment.locationObject distanceFromLocation:location] / kMetersInAMile <= [assignment.radius floatValue] ) {
                        self.nearbyAssignments = @[assignment];
                        self.selectedAssignment = assignment;
                        [self adjustTableViewFrame];
                        [self.assignmentTV reloadData];
                        return;
                    }
                }
            }
        }
    }];
}

-(void)configureUI{
    self.view.backgroundColor = [UIColor whiteBackgroundColor];
    
    [self configureScrollView];
    [self configureCollectionView];
    [self configureTableView];
    [self configureSocialButtons];
    [self configureTextView];
    [self updateScrollViewContentSize];
    [self configureSocialTipView];
}

#pragma mark - Scroll View

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.toolbar.frame.size.height - 46)];
    self.scrollView.backgroundColor = [UIColor whiteBackgroundColor];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 10);
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    [self.view insertSubview:self.scrollView belowSubview:self.topBar];
}

#pragma mark - Collection View
-(void)configureCollectionView{
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(self.view.frame.size.width, [self heightForCollectionView])];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    self.flowLayout.minimumLineSpacing = 0.0;
    
    self.galleryCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForCollectionView]) collectionViewLayout:self.flowLayout];
    [self.galleryCV registerClass:[GalleryPostCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.galleryCV.bounces = NO;
    self.galleryCV.pagingEnabled = YES;
    self.galleryCV.showsHorizontalScrollIndicator = NO;
    self.galleryCV.dataSource = self;
    self.galleryCV.delegate = self;
    self.galleryCV.minimumZoomScale = 1.0f;
    self.galleryCV.maximumZoomScale = 2.0f;
    self.galleryCV.backgroundColor = [UIColor whiteBackgroundColor];
    [self.scrollView addSubview:self.galleryCV];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.gallery.posts.count;
    [self.pageControl sizeToFit];
    self.pageControl.center = self.scrollView.center;
    if (self.gallery.posts.count == 1) self.pageControl.hidden = YES;
    
    self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, self.galleryCV.frame.size.height - 36, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
    [self.scrollView addSubview:self.pageControl];
}

-(NSInteger)heightForCollectionView{
    if ([self.gallery.posts count]) {
        
        NSInteger height = 0;
        for (FRSPost *post in self.gallery.posts){
            CGFloat pixelHeight = post.image.asset.pixelHeight;
            CGFloat pixelWidth = post.image.asset.pixelWidth;
            
            CGFloat scaledHeight = self.view.frame.size.width * (pixelHeight/pixelWidth);
            height += scaledHeight;
            
        }
        
        height /= self.gallery.posts.count; //average height of gallery posts
        
        if (height > 0 && height < self.view.frame.size.width * 4/3){
            return height;
        }
        else {
            return self.view.frame.size.width * 4/3;
        }
    }
    return self.view.frame.size.width * 3/4;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gallery.posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryPostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell.imageView){
        cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        [cell addSubview:cell.imageView];
    }
    
    
    [cell setPost:[self.gallery.posts objectAtIndex:indexPath.item]];
    
    if (indexPath.item == 0) self.zoomCell = cell;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(GalleryPostCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if([cell.post isVideo]){
        if(cell.post.video) {
            [self setUpPlayerWithUrl:cell.post.video cell:cell muted:YES buffer:YES];
        }
        else if (cell.post.image.asset.mediaType == PHAssetMediaTypeVideo){
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:cell.post.image.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                [self setUpPlayerWithUrl:((AVURLAsset *)asset).URL cell:cell muted:YES buffer:NO];
                
            }];
        }
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GalleryPostCollectionViewCell *cell = (GalleryPostCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //If the cell has a video
    if(cell.post.isVideo && cell.playingVideo){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Check if the player is muted, then set it to play audio
            if(self.sharedPlayer.muted){
                
                self.sharedPlayer.muted = NO;
            
                
            }
            //Check if the player is playing
            else if(self.sharedPlayer.rate > 0){
                
                [self.sharedPlayer pause];
                cell.playPause.image = [UIImage imageNamed:@"pause"];
                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
                [cell bringSubviewToFront:cell.playPause];
                
                cell.playPause.alpha = 1.0f;
                
                [UIView animateWithDuration:.5 animations:^{
                    cell.playPause.alpha = 0.0f;
                    cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
                }];
                
            }
            //If it's not playing
            else{
                
                [self.sharedPlayer play];

                cell.playPause.alpha = 0.0f;
                cell.playPause.image = [UIImage imageNamed:@"play"];
                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
                [cell bringSubviewToFront:cell.playPause];
                
                cell.playPause.alpha = 1.0f;
                
                [UIView animateWithDuration:.5 animations:^{
                    cell.playPause.alpha = 0.0f;
                    cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
                }];
            }
            
        });
        
    }
}

#pragma mark - Table View

-(void)configureTableView{
    self.assignmentTV = [[UITableView alloc] init];
    self.assignmentTV.backgroundColor = [UIColor whiteBackgroundColor];
    self.assignmentTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.assignmentTV.delegate = self;
    self.assignmentTV.dataSource = self;
    self.assignmentTV.scrollEnabled = NO;
    [self adjustTableViewFrame];
    [self.scrollView addSubview:self.assignmentTV];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (self.nearbyAssignments.count) {
        case 0:
            return 0;
        default:
            return self.nearbyAssignments.count + 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSAssignmentChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    FRSAssignment *assignment;
    if (indexPath.row < self.nearbyAssignments.count){
        assignment = self.nearbyAssignments[indexPath.row];
    }
    
    if (!cell){
        cell = [[FRSAssignmentChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" assignment:assignment];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull FRSAssignmentChoiceCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [cell clearCell];
    
    if (indexPath.row == 0)
        cell.isSelectedAssignment = YES;
    
    [cell configureCell];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSAssignmentChoiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell.isSelectedAssignment){
        cell.isSelectedAssignment = NO;
        self.selectedAssignment = nil;
    }
    else {
        [self resetOtherCells];
        cell.isSelectedAssignment = YES;
        self.selectedAssignment = cell.assignment;
    }
    [cell toggleImage];
}

-(void)resetOtherCells{
    for (NSInteger i = 0; i < self.nearbyAssignments.count + 1; i++){
        FRSAssignmentChoiceCell *cell = [self.assignmentTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedAssignment = NO;
        [cell toggleImage];
    }
}

-(void)adjustTableViewFrame{
    
    NSInteger height = self.nearbyAssignments.count ? (self.nearbyAssignments.count + 1) * 44 : 0;
    
    self.assignmentTV.frame = CGRectMake(0, self.galleryCV.frame.size.height, self.scrollView.frame.size.width, height);
    self.captionTextView.frame = CGRectMake(11, self.assignmentTV.frame.origin.y + self.assignmentTV.frame.size.height + 3, self.view.frame.size.width - 22, 76);
    [self updateScrollViewContentSize];
    
    [self.tvSeparatorLine removeFromSuperview];
    if (height){
        self.tvSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.assignmentTV.frame.size.height - 0.5, self.assignmentTV.frame.size.width, 0.5)];
        self.tvSeparatorLine.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.12];
        [self.assignmentTV addSubview:self.tvSeparatorLine];
    }
}

-(void)configureSocialButtons{
    
    self.socialContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.navigationController.toolbar.frame.size.height - 46, self.view.frame.size.width, 46)];
    self.socialContainer.backgroundColor = [UIColor whiteBackgroundColor];
    [self.view addSubview:self.socialContainer];
    
    self.twitterButton = [[FRSSocialButton alloc] init];
    self.twitterButton.backgroundColor = [UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1.0];
    [self.twitterButton.titleLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17]];
    [self.twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
    self.twitterButton.alpha = 0.54;
    [self.twitterButton setFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 46)];
    [self.twitterButton setUpSocialIcon:SocialNetworkTwitter withRadius:NO];
    [self.twitterButton addTarget:self action:@selector(handleTwitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    if (self.socialOptions){
        self.twitterButton.selected = [self.socialOptions[@"twitter_selected"] boolValue];
        self.twitterButton.alpha = self.twitterButton.selected ? 1.0 : 0.54;
    }
    [self.socialContainer addSubview:self.twitterButton];
    
    self.facebookButton = [[FRSSocialButton alloc] init];
    self.facebookButton.backgroundColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0];
    [self.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    self.facebookButton.alpha = 0.54;
    [self.facebookButton setFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 46)];
    [self.facebookButton.titleLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17]];
    [self.facebookButton addTarget:self action:@selector(handleFacebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookButton setUpSocialIcon:SocialNetworkFacebook withRadius:NO];
    
    if (self.socialOptions){
        self.facebookButton.selected = [self.socialOptions[@"facebook_selected"] boolValue];
        self.facebookButton.alpha = self.facebookButton.selected ? 1.0 : 0.54;
    }
    
    [self.socialContainer addSubview:self.facebookButton];
}

-(void)configureTextView{
    self.captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(11, self.assignmentTV.frame.origin.y + self.assignmentTV.frame.size.height + 3, self.view.frame.size.width - 22, 76)];
    self.captionTextView.delegate = self;
    self.captionTextView.text = [self.gallery.caption isEqualToString:@"No Caption"] ? WHATS_HAPPENING : self.gallery.caption;
    self.captionTextView.textColor = [UIColor colorWithWhite:0 alpha:0.26];
    self.captionTextView.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15];
    self.captionTextView.backgroundColor = [UIColor whiteBackgroundColor];
    [self.scrollView addSubview:self.captionTextView];
}

-(void)updateScrollViewContentSize{
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.galleryCV.frame.size.height + self.assignmentTV.frame.size.height + self.captionTextView.frame.size.height + 15);
}

-(void)configureSocialTipView{
    self.socialTipView = [[UIView alloc] initWithFrame:CGRectMake(0, self.socialContainer.frame.origin.y - 48, 260, 42)];
    [self.socialTipView centerHorizontallyInView:self.view];

    UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.socialTipView.frame.size.width, 32)];
    rectangle.backgroundColor = [UIColor colorWithWhite:0 alpha:0.54];
    rectangle.layer.cornerRadius = 2.0;
    rectangle.clipsToBounds = YES;
    [self.socialTipView addSubview:rectangle];
    
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(0, 0)];
    [trianglePath addLineToPoint:CGPointMake(8, 10)];
    [trianglePath addLineToPoint:CGPointMake(16, 0)];
    [trianglePath closePath];
    
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:trianglePath.CGPath];
    
    UIView *triangle = [[UIView alloc] initWithFrame:CGRectMake(0, 32, 16, 10)];
    [triangle centerHorizontallyInView:self.socialTipView];
    
    triangle.backgroundColor = [UIColor colorWithWhite:0 alpha:.54];
    triangle.layer.mask = triangleMaskLayer;
    [self.socialTipView addSubview:triangle];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.socialTipView.frame.size.width, 32)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:10];
    label.text = @"Press to share this gallery on Facebook and Twitter";
    label.textAlignment = NSTextAlignmentCenter;
    [self.socialTipView addSubview:label];
    
    [self.socialTipView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateSocialTipView)]];
    [self.view addSubview:self.socialTipView];
    
    self.socialTipView.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:UD_GALLERY_POSTED];
}

#pragma mark - Scroll View Delegate


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        
        NSInteger currentYOffset = scrollView.contentOffset.y;
        CGFloat offset = scrollView.contentOffset.y;
        if (currentYOffset > self.scrollView.contentSize.height - self.scrollView.frame.size.height) return;
        
        if (offset <= 0){
            
            self.galleryCV.frame = CGRectMake(self.galleryCV.frame.origin.x, offset, self.galleryCV.frame.size.width, [self heightForCollectionView] + (-offset));
            [self.flowLayout invalidateLayout];
            
            if (self.zoomCell.post.isVideo){
                [self.scrollView setContentOffset:CGPointMake(0, 0)];
            }
            else {
                self.zoomCell.imageView.frame = CGRectMake(offset/2.0, 0, self.view.frame.size.width + (-offset), [self heightForCollectionView] + (-offset));
            }
            
            return;
        };
        
        if (currentYOffset - self.lastYOffset < 0){ //scrolling up
            self.scrollViewDirection = scrollViewDirectionUp;
            if (self.topBar.alpha < 1){
                [UIView animateWithDuration:0.2 animations:^{
                    self.topBar.alpha = 1.0;
                }];
            }
        }
        else if (currentYOffset - self.lastYOffset > 0){ //scrolling down
            self.scrollViewDirection = scrollViewDirectionDown;
            if (self.topBar.alpha > 0){
                [UIView animateWithDuration:0.2 animations:^{
                    self.topBar.alpha = 0;
                }];
            }
        }
        self.lastYOffset = currentYOffset;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == self.galleryCV) {
        
        CGFloat pageWidth = self.galleryCV.frame.size.width;
        self.pageControl.currentPage = self.galleryCV.contentOffset.x / pageWidth;
        
        CGRect visibleRect = (CGRect){.origin = self.galleryCV.contentOffset, .size = self.galleryCV.bounds.size};
        
        CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
        
        NSIndexPath *visibleIndexPath = [self.galleryCV indexPathForItemAtPoint:visiblePoint];
        
        GalleryPostCollectionViewCell *postCell = (GalleryPostCollectionViewCell *) [self.galleryCV cellForItemAtIndexPath:visibleIndexPath];
        self.zoomCell = postCell;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.gallery.galleryID){
                
                NSDictionary *dict = @{
                                       @"postIndex" : [NSNumber numberWithInteger:visibleIndexPath.row],
                                       @"gallery" : self.gallery.galleryID
                                       };
                if (dict)
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GALLERY_HEADER_UPDATE object:nil userInfo:dict];
            }
        });
        
        
        if([postCell.post isVideo]){
            if (postCell.post.image.asset.mediaType == PHAssetMediaTypeVideo && !postCell.playingVideo){
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:postCell.post.image.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    if (((AVURLAsset *)asset).URL && postCell)
                        [self setUpPlayerWithUrl:((AVURLAsset *)asset).URL cell:postCell muted:YES buffer:NO];
                    
                }];
            }
        }
        //If the cell doesn't have a video
        else{
            [self cleanUpVideoPlayer];
        }
    }
    else if (scrollView == self.scrollView){
        if (self.scrollViewDirection == scrollViewDirectionDown){
            [UIView animateWithDuration:0.1 animations:^{
                self.topBar.alpha = 0;
            }];
        }
        else if (self.scrollViewDirection == scrollViewDirectionUp){
            [UIView animateWithDuration:0.1 animations:^{
                self.topBar.alpha = 1.0;
            }];
        }
        
        if (scrollView.contentOffset.y < 5){
            [UIView animateWithDuration:0.1 animations:^{
                self.topBar.alpha = 1.0;
            }];
        }
        
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [self.flowLayout setItemSize:CGSizeMake(self.view.frame.size.width, [self heightForCollectionView])];
        [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.flowLayout.minimumInteritemSpacing = 0.0f;
        self.flowLayout.minimumLineSpacing = 0.0;
        [self.galleryCV setCollectionViewLayout:self.flowLayout];
        
    }
    
}


#pragma mark - Navigation

-(void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)handleCancelButtonTapped:(id)sender{
    
    [self returnToTabBarWithPrevious:YES];
}

/**
 *  Returns to tab bar
 *
 *  @return Takes option of returning to previously selected tab
 */

-(void)returnToTabBarWithPrevious:(BOOL)previous{
    
    FRSTabBarController *tabBarController;
    
    //Check if we're coming from the camera
    if([self.presentingViewController isKindOfClass:[FRSCameraViewController class]]){
        
        ((FRSCameraViewController *)self.presentingViewController).isPresented = NO;
        
        tabBarController = ((FRSRootViewController *)self.presentingViewController.presentingViewController).tbc;
        
    }
    else
        tabBarController = ((FRSRootViewController *)self.presentingViewController).tbc;
    
    tabBarController.selectedIndex = previous ? [[NSUserDefaults standardUserDefaults] integerForKey:UD_PREVIOUSLY_SELECTED_TAB] : 4;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [tabBarController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateSocialTipView];
    
    if ([textView.text isEqualToString:WHATS_HAPPENING])
        textView.text = @"";
    
    if (textView == self.captionTextView){
        [self.view addGestureRecognizer:self.resignKeyboardGR];
    }
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
        textView.text = WHATS_HAPPENING;
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView == self.captionTextView){
        [self.view removeGestureRecognizer:self.resignKeyboardGR];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }
    else if([text isEqualToString:@"\n"]) {
        return YES;
    }
    
    [textView resignFirstResponder];
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    [self toggleToolbarAppearance];
    
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"captionStringInProgress"];
    
    NSInteger difference = textView.contentSize.height - textView.frame.size.height;
    
    if (difference > 0 || (difference < 0 && textView.frame.size.height > 80)){
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height + difference);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.contentSize.height + difference);
        
        CGFloat offset = difference;
        if (difference < 0) offset += 6;
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + offset) animated:YES];
    }
}

#pragma mark - UIToolBar Appearance

- (void)toggleToolbarAppearance {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIColor *textViewColor = [UIColor darkGrayColor];
        UIColor *toolbarColor = [UIColor greenToolbarColor];
        
        if ([self.captionTextView.text length] == 0 || [self.captionTextView.text isEqualToString:WHATS_HAPPENING]) {
            
            toolbarColor = [UIColor disabledToolbarColor];
            
            textViewColor = [UIColor lightGrayColor];
        }
        
        self.navigationController.toolbar.barTintColor = toolbarColor;
        
        [self.captionTextView setTextColor:textViewColor];
        
    });
}


#pragma mark - Notification Delegate

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] animations:^{
                            
                            CGRect viewFrame = self.scrollView.frame;
                            
                            CGRect toolBarFrame = self.navigationController.toolbar.frame;
                            
                            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                
                                viewFrame.origin.y -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                                
                                toolBarFrame.origin.y -= [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
                                
                                self.navigationController.toolbar.frame = toolBarFrame;
                                
                                CGFloat height;
                                
                                height = MAX([notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height - (self.view.frame.size.height - self.scrollView.contentSize.height) + 92,0);
                                
                                self.originalContentOffset = self.scrollView.contentOffset.y;
                                
                                self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height);
                                
                                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, height) animated:NO];
                                
                                self.socialContainer.frame = CGRectOffset(self.socialContainer.frame, 0, -[notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height);
                                self.topBar.alpha = 0.0;
                                
                            }
                            else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])  {
                                
                                viewFrame.origin.y = 0;
                                
                                toolBarFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 44;
                                
                                self.navigationController.toolbar.frame = toolBarFrame;
                                
                                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.originalContentOffset) animated:NO];
                                self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height - [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height);
                                
                                self.socialContainer.frame = CGRectOffset(self.socialContainer.frame, 0, [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height);
                                self.topBar.alpha = 1.0;
                            }
                            
                        } completion:nil];
}

#pragma mark - Social Actions


- (void)handleTwitterButtonTapped:(UIButton *)button{
    
    [self updateSocialTipView];
    
    if (!button.isSelected && ![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        UIAlertController *alertCon = [FRSAlertViewManager
                                       alertControllerWithTitle:@"Whoops"
                                       message:@"It seems like you're not connected to Twitter, click \"Connect\" if you'd like to connect Fresco with Twitter"
                                       action:@"Cancel" handler:^(UIAlertAction *action) {
                                           button.selected = NO;
                                       }];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //Run Twitter link
            [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                
                if(error){
                    
                    [self presentViewController:[FRSAlertViewManager
                                                 alertControllerWithTitle:@"Error"
                                                 message:@"We were unable to link your Twitter account!"
                                                 action:nil]
                                       animated:YES
                                     completion:^{
                                         button.selected = NO;
                                     }];
                }
            }];
            
        }]];
        
        //Bring up alert view
        [self presentViewController:alertCon animated:YES completion:nil];
        
    } else {
        
        
        button.selected = !button.isSelected;
        button.alpha = button.selected ? 1.0 : .54;
        
        
        [[NSUserDefaults standardUserDefaults] setBool:button.isSelected forKey:@"twitterButtonSelected"];
        
    }
}

- (void)handleFacebookButtonTapped:(UIButton *)button{
    
    [self updateSocialTipView];
    
    if (!button.isSelected && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        UIAlertController *alertCon = [FRSAlertViewManager
                                       alertControllerWithTitle:@"Whoops"
                                       message:@"It seems like you're not connected to Facebook, click \"Connect\" if you'd like to connect Fresco with Facebook"
                                       action:@"Cancel" handler:^(UIAlertAction *action) {
                                           button.selected = NO;
                                       }];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            //Run Facebook link
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
                
                if(error){
                    
                    [self presentViewController:[FRSAlertViewManager
                                                 alertControllerWithTitle:ERROR
                                                 message:@"We were unable to link your Facebook account!"
                                                 action:nil]
                                       animated:YES
                                     completion:^{
                                         button.selected = NO;
                                     }];
                    
                }
                
            }];
            
        }]];
        
        //Bring up alert view
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }
    else{
        
        button.selected = !button.isSelected;
        button.alpha = button.selected ? 1.0 : .54;
        
        
        [[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:@"facebookButtonSelected"];
    }
}

-(void)resignKeyboard{
    [self.captionTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disableUploadControls:(BOOL)upload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = !upload;
        self.navigationController.navigationBar.userInteractionEnabled = !upload;
        self.navigationController.toolbar.userInteractionEnabled = !upload;
        self.navigationController.interactivePopGestureRecognizer.enabled = !upload;
        
    });
}

#pragma mark - Toolbar Items

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title =  [[UIBarButtonItem alloc] initWithTitle:GALLERY_TOOLBAR
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(submitGalleryPost:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:self
                                                                           action:@selector(submitGalleryPost:)];
    
    return @[space, title, space];
}


-(void)submitGalleryPost:(id)sender{
    
    [self updateSocialTipView];
    
    //First check if the caption is valid
    if([self.captionTextView.text isEqualToString:WHATS_HAPPENING] || [self.captionTextView.text  isEqual: @""]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (![self.captionTextView isFirstResponder]) {
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.duration = 0.8;
                animation.values = @[@(-8), @(8), @(-6), @(6), @(-4), @(4), @(-2), @(2), @(0)];
                [self.captionTextView.layer addAnimation:animation forKey:@"shake"];
            }
            
        });
        
        return;
        
    }
    //Check if there are less than the max amount of posts
    else if([self.gallery.posts count] > MAX_ASSET_COUNT){
        
        [self presentViewController:[FRSAlertViewManager
                                     alertControllerWithTitle:ERROR
                                     message:MAX_POST_ERROR
                                     action:nil]
                           animated:YES
                         completion:nil];
        
        return;
        
    }
    //Check if the user is logged in before proceeding, send to sign up otherwise
    else if (![[FRSDataManager sharedManager] currentUserIsLoaded]) {
        
        [self presentFirstRun];
        
        return;
    }
    
    
    /**
     *** All conditions passed for upload
     **/
    
    [self disableUploadControls:YES];
    
    self.gallery.caption = self.captionTextView.text;
    
    [self saveGallery:self.gallery forAssignment:self.selectedAssignment];
    
    NSNumber * facebookPost = [NSNumber numberWithBool:NO];
    NSNumber * twitterPost = [NSNumber numberWithBool:NO];
    
    if (self.twitterButton.selected) twitterPost = [NSNumber numberWithBool:YES];
    
    if (self.facebookButton.selected) facebookPost = [NSNumber numberWithBool:YES];
    
    [FRSUploadManager sharedManager].delegate = self;
    
    
    [self beginBackgroundUpdateTask];
    [[FRSUploadManager sharedManager] uploadGallery:self.gallery
                                     withAssignment:self.selectedAssignment
                                  withSocialOptions:@{
                                                      @"facebook" : facebookPost,
                                                      @"twitter" : twitterPost
                                                      }
                                  withResponseBlock:nil];
    
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UD_GALLERY_POSTED];
    
    [self returnToTabBarWithPrevious:YES];
}

- (void) beginBackgroundUpdateTask
{
    [self endBackgroundUpdateTask];
    
    self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTaskID];
    self.backgroundTaskID = UIBackgroundTaskInvalid;
}

-(void)updateSocialTipView{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.socialTipView.hidden == NO) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.socialTipView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                self.socialTipView.hidden = YES;
                
            }];
        }
    });
}

-(void)saveGallery:(FRSGallery *)gallery forAssignment:(FRSAssignment *)assignment{
    NSMutableArray *assetIDs = [NSMutableArray new];
    for (FRSPost *post in gallery.posts){
        NSString *assetID = post.image.asset.localIdentifier;
        [assetIDs addObject:assetID];
    }
    
    /*
     @{
     @"gallery_id" : <gallery.galleryId>
     @"assignment_id" : <assignmentId>
     @"assets" : @[assetId]
     @"caption" : <caption>
     @"facebook_selected" : @BOOL
     @"twitter_selected: @BOOL
     }
     */
    
    NSString *galleryID = gallery.galleryID ? gallery.galleryID : @"";
    NSString *assignmentID = assignment.assignmentId ? : @"";
    
    NSDictionary *galleryDict = @{@"gallery_id" : galleryID, @"assignment_id" : assignmentID, @"assets" : assetIDs, @"caption" : self.captionTextView.text, @"facebook_selected" : @(self.facebookButton.selected), @"twitter_selected" : @(self.twitterButton.selected)};
    
    [[NSUserDefaults standardUserDefaults] setObject:galleryDict forKey:UD_UPLOADING_GALLERY_DICT];
}

#pragma mark - AV Player

- (void)setUpPlayerWithUrl:(NSURL *)url cell:(GalleryPostCollectionViewCell *)postCell muted:(BOOL)muted buffer:(BOOL)buffer
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //update UI in main thread.
        //Start animating the indicator
        postCell.photoIndicatorView.color = [UIColor whiteColor];
        [postCell.photoIndicatorView startAnimating];
        [UIView animateWithDuration:1.0 animations:^{
            postCell.photoIndicatorView.alpha = 1.0f;
        }];
        
    });
    
    //Cleans up the video player if playing
    [self cleanUpVideoPlayer];
    
    self.sharedPlayer = [AVPlayer playerWithURL:url];
    
    self.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:self.sharedPlayer];
    
    self.sharedLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
    
    self.sharedLayer.frame = postCell.imageView.bounds;
    
    self.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    if(buffer){
        
        //Set up the AVPlayerItem
        [self.sharedPlayer.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        self.sharedPlayer.muted = muted;
        
    }
    else{
        
        [self.sharedPlayer play];
        NSLog(@"Video Started");
        
    }
    
    //dispatch adding sublayer to main UI thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [postCell.imageView.layer addSublayer:self.sharedLayer];
        
    });
    
    //Bring play/pause button to front, so it can be visible on click
    [postCell bringSubviewToFront:postCell.playPause];
    
    postCell.playingVideo = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.sharedPlayer currentItem]];
    
    self.playingIndex = [self.galleryCV indexPathForCell:postCell];
    
}

/*
 ** Notification listener for status of AVPlayerItem
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //Check if we have the right notif for the AVPlayer
    if ([keyPath isEqualToString:@"status"]) {
        
        //DISABLE THE UIACTIVITY INDICATOR HERE
        if (self.sharedPlayer.currentItem.status == AVPlayerStatusReadyToPlay) {
            
            [self removeObserverForPlayer];
            
            //Get the collection view cell of the playing item
            GalleryPostCollectionViewCell *postCell = (GalleryPostCollectionViewCell *)[self.galleryCV cellForItemAtIndexPath:self.playingIndex];
            
            postCell.playingVideo = YES;
            
            [self.sharedPlayer play];
            
            NSLog(@"Video Started");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:1.0 animations:^{
                    
                    postCell.photoIndicatorView.alpha = 0.0f;
                    
                } completion:^(BOOL finished){
                    
                    [postCell.photoIndicatorView stopAnimating];
                    postCell.photoIndicatorView.hidden = YES;
                    
                }];
                
            });
            
        }
    }
}

/**
 *  Notification listener for when video reaches the end (tells it to repeat in a loop)
 *
 *  @param notification <#notification description#>
 */

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [(AVPlayerItem *)[notification object] seekToTime:kCMTimeZero];
    
}


/**
 *  Cleans up notificaiton observer on the AVPlayers item
 */

- (void)removeObserverForPlayer{
    
    @try{
        [self.sharedPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    }
    @catch(id anException){
        
    }
    
}

- (void)cleanUpVideoPlayer{
    
    //Check if the player is actually playing
    if(self.sharedPlayer != nil){
        
        [self.sharedLayer removeFromSuperlayer];
        [self.sharedPlayer pause];
        
        @try{
            [self removeObserverForPlayer];
        }
        @catch (id anException){
            
        }
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
