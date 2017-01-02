//
//  FRSUploadViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/3/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUploadViewController.h"
#import "FRSAssignmentPickerTableViewCell.h"
#import "FRSAssignment.h"
#import "FRSOnboardingViewController.h"
#import "FRSCarouselCell.h"
#import <Twitter/Twitter.h>
#import "FRSImageViewCell.h"
#import "FRSFileLoader.h"
#import "FRSPlayer.h"
#import "FRSAPIClient.h"
#import <Photos/Photos.h>
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSAppDelegate.h"
#import "FRSUploadManager.h"

@interface FRSUploadViewController () {
    NSMutableArray *dictionaryRepresentations;
    BOOL notFirstFetch;
}

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@property (strong, nonatomic) UIView *navigationBarView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *assignmentsTableView;
@property (strong, nonatomic) UITableView *galleryTableView;
@property (strong, nonatomic) UITextView *captionTextView;
@property (strong, nonatomic) UIView *captionContainer;
@property (strong, nonatomic) UIView *bottomContainer;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (nonatomic, retain) NSMutableArray *assignmentIDs;
@property (strong, nonatomic) FRSAssignmentPickerTableViewCell *prevCell;
@property (strong, nonatomic) FRSAssignment *selectedAssignment;
@property int closestAssignmentIndex;
@property (nonatomic) BOOL postToFacebook;
@property (nonatomic) BOOL postToTwitter;
@property (nonatomic) BOOL postAnon;
@property (nonatomic) BOOL isFetching;
@property (nonatomic) BOOL globalAssignmentsEnabled;
@property (strong, nonatomic) NSArray *assignments;
@property (strong, nonatomic) UIView *globalAssignmentsDrawer;
@property (strong, nonatomic) UITableView *globalAssignmentsTableView;
@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardGestureRecognizer;
@property (strong, nonatomic) UICollectionView *galleryCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *galleryCollectionViewFlowLayout;
@property (strong, nonatomic) FRSCarouselCell *carouselCell;
@property (strong, nonatomic) NSIndexPath *prevIndexPath;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIImageView *muteImageView;
@property (strong, nonatomic) UIImageView *globalAssignmentsCaret;
@property (nonatomic) NSInteger numberOfRowsInAssignmentTableView;
@property (nonatomic) NSInteger numberOfRowsInGlobalAssignmentTableView;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *spinner;
@property (strong, nonatomic) UIButton *sendButton;
@property BOOL showingOutlets;
@property BOOL showingAssignmentOutlets;
@property BOOL showingGlobalOutlets;

@property NSInteger galleryCollectionViewHeight;
@property (strong, nonatomic) NSIndexPath *previouslySelectedAssignmentIndexPath;
@property (strong, nonatomic) NSIndexPath *previouslySelectedGlobalIndexPath;

@end

@implementation FRSUploadViewController

static NSString *const cellIdentifier = @"assignment-cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureUI];
    [self checkButtonStates];

    self.postToTwitter = NO;
    self.postToFacebook = NO;
    self.postAnon = NO;
    self.showingOutlets = NO;
    self.showingGlobalOutlets = NO;
    self.showingAssignmentOutlets = NO;
    [self checkBottomBar];

    self.assignmentIDs = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self configureAssignments]; //Tableview configures are called here

    [FRSTracker screen:@"Submission"];

    [self.galleryCollectionView reloadData];
    [self configurePageController];

    [self.galleryCollectionView setContentOffset:CGPointMake(0, 0)];

    self.carouselCell.assets = self.content;

    self.players = [[NSMutableArray alloc] init];

    self.numberOfRowsInAssignmentTableView = self.assignmentsArray.count + numberOfOutlets;
    //self.numberOfRowsInGlobalAssignmentTableView = self.globalAssignments.count + numberOfOutlets;

    [self resetFrames:false];

    if (!self.spinner) {
        self.spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    }

    if (!self.assignmentsTableView) {
        self.spinner.frame = CGRectMake(self.view.frame.size.width / 2 - 20 / 2, (self.view.frame.size.height + self.galleryCollectionViewHeight) / 2 - 64 + 20 / 2, 20, 20);
        self.spinner.tintColor = [UIColor frescoOrangeColor];
        [self.spinner setPullProgress:90];
        [self.spinner startAnimating];
        [self.view addSubview:self.spinner];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
    [self resetOtherCells];
    [self resetOtherOutlets];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)configureUI {

    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];

    [self addObservers];

    [self configureScrollView];
    [self configureGalleryCollectionView];
    [self configurePageController];
    [self configureNavigationBar];
    [self configureBottomBar];
}

- (void)configureSpinner {

    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
}

- (void)startSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    spinner.frame = CGRectMake(button.frame.size.width - 20 - 16, button.frame.size.height / 2 - 10, 20, 20);
    [spinner startAnimating];
    [button addSubview:spinner];

    button.enabled = FALSE;
}

- (void)stopSpinner:(DGElasticPullToRefreshLoadingViewCircle *)spinner onButton:(UIButton *)button {
    [button setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [spinner removeFromSuperview];
    [spinner startAnimating];

    button.enabled = TRUE;
}

- (void)resetFrames:(BOOL)animate {

    NSLog(@"RESET FRAMES: %ld", self.numberOfRowsInAssignmentTableView);
    NSLog(@"Count: %lu", (unsigned long)self.assignmentsArray.count);

    if (animate) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [UIView beginAnimations:nil context:nil];
          [UIView setAnimationDuration:0.3];
          //[UIView setAnimationCurve:UIViewAnimationTransitionCurlUp];
          self.assignmentsTableView.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height, self.view.frame.size.width, (self.numberOfRowsInAssignmentTableView + 1) * 44);
          self.globalAssignmentsDrawer.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height, self.view.frame.size.width, 44);
          if (self.globalAssignmentsTableView) {
              self.globalAssignmentsTableView.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height, self.view.frame.size.width, (self.numberOfRowsInGlobalAssignmentTableView) * 44);
          }
          self.captionContainer.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height + self.globalAssignmentsTableView.frame.size.height + 14, self.view.frame.size.width, 200 + 16);

          [self adjustScrollViewContentSize];
          [UIView commitAnimations];
        });
    } else {
        self.assignmentsTableView.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height, self.view.frame.size.width, (self.numberOfRowsInAssignmentTableView + 1) * 44);
        self.globalAssignmentsDrawer.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height, self.view.frame.size.width, 44);
        if (self.globalAssignmentsTableView) {
            self.globalAssignmentsTableView.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height, self.view.frame.size.width, (self.globalAssignments.count) * 44);
        }
        self.captionContainer.frame = CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height + self.globalAssignmentsTableView.frame.size.height + 14, self.view.frame.size.width, 200 + 16);

        [self adjustScrollViewContentSize];
    }
}

- (void)checkButtonStates {
}

#pragma mark - UICollectionView

- (void)configureGalleryCollectionView {

    if (IS_IPHONE_5) {
        self.galleryCollectionViewHeight = 240;
    } else if (IS_IPHONE_6) {
        self.galleryCollectionViewHeight = 280;
    } else if (IS_IPHONE_6_PLUS) {
        self.galleryCollectionViewHeight = 310;
    }

    self.galleryCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.galleryCollectionViewFlowLayout.itemSize = CGSizeMake(50, 50);
    [self.galleryCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.galleryCollectionViewFlowLayout.minimumInteritemSpacing = 0;
    self.galleryCollectionViewFlowLayout.minimumLineSpacing = 0;

    self.galleryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.galleryCollectionViewHeight) collectionViewLayout:self.galleryCollectionViewFlowLayout];
    self.galleryCollectionView.showsHorizontalScrollIndicator = NO;
    self.galleryCollectionView.collectionViewLayout = self.galleryCollectionViewFlowLayout;
    self.galleryCollectionView.pagingEnabled = YES;
    self.galleryCollectionView.delegate = self;
    self.galleryCollectionView.dataSource = self;
    self.galleryCollectionView.bounces = NO;
    self.galleryCollectionView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.galleryCollectionView registerNib:[UINib nibWithNibName:@"FRSCarouselCell" bundle:nil] forCellWithReuseIdentifier:@"FRSCarouselCell"];
    [self.scrollView addSubview:self.galleryCollectionView];

    /* DEBUG */
    //self.galleryCollectionView.backgroundColor = [UIColor redColor];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.carouselCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FRSCarouselCell" forIndexPath:indexPath];

    PHAsset *asset = [self.content objectAtIndex:indexPath.row];

    if (asset.mediaType == PHAssetMediaTypeImage) {
        self.carouselCell.muteImageView.alpha = 0;
        [self.carouselCell removePlayers];
        [self.carouselCell loadImage:asset];

    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [self.carouselCell removePlayers];
        [self.carouselCell loadVideo:asset];
        CGRect newFrame = self.carouselCell.frame;
        newFrame.size.width = self.view.frame.size.width;
        [self.carouselCell setFrame:newFrame];

        if (![self.players containsObject:asset]) {
            [self.players addObject:asset];
        }
    } else if (asset.mediaType == PHAssetMediaTypeAudio) {
        // 3.x feature
    }

    [self.carouselCell pausePlayer];

    return self.carouselCell;
}

- (BOOL)currentPageIsVideo {
    CGFloat pageWidth = self.galleryCollectionView.frame.size.width;
    NSInteger page = self.galleryCollectionView.contentOffset.x / pageWidth;

    //does not work, self.players is nil
    return (self.players.count > page && [self.players[page] respondsToSelector:@selector(pause)]);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, collectionView.frame.size.height);
}

- (void)configurePageController {
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.content.count;
    self.pageControl.currentPage = 0;
    self.pageControl.userInteractionEnabled = NO;

    self.pageControl.currentPageIndicatorTintColor = [UIColor frescoBackgroundColorDark];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.7];

    [self.pageControl sizeToFit];
    [self.pageControl setFrame:CGRectMake(self.galleryCollectionView.frame.size.width - 16 - self.pageControl.frame.size.width, self.galleryCollectionView.frame.size.height - 15 - 8, self.pageControl.frame.size.width, 8)];

    self.pageControl.hidesForSinglePage = YES;

    [self.scrollView addSubview:self.pageControl];
}

#pragma mark - Navigation Bar

- (void)configureNavigationBar {

    /* Configure sudo navigationBar */
    // Used UIView instead of UINavigationBar for increased flexibility when animating
    self.navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    self.navigationBarView.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:self.navigationBarView];

    /* Configure backButton */
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(12, 30, 24, 24);
    [backButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    /* Configure squareButton */
    /*UIButton *squareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    squareButton.frame = CGRectMake(self.navigationBarView.frame.size.width-12-24, 30, 24, 24);
    [squareButton setImage:[UIImage imageNamed:@"square"] forState:UIControlStateNormal];
    [squareButton setTintColor:[UIColor whiteColor]];
    [squareButton addTarget:self action:@selector(square) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:squareButton];*/

    /* Configure titleLabel */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 66 / 2, 35, 66, 19)];
    [titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [titleLabel setText:@"GALLERY"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self.navigationBarView addSubview:titleLabel];

    self.navigationBarView.alpha = 0;
    titleLabel.alpha = 0;
}

- (void)configureBottomBar {

    /* Configure bottom container */
    self.bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    self.bottomContainer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.view addSubview:self.bottomContainer];

    UIView *bottomContainerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    bottomContainerLine.backgroundColor = [UIColor frescoShadowColor];
    [self.bottomContainer addSubview:bottomContainerLine];

    /* Configure bottom bar */
    //Configure Twitter post button
    self.twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.twitterButton addTarget:self action:@selector(postToTwitter:) forControlEvents:UIControlEventTouchDown];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"social-twitter"] forState:UIControlStateSelected];
    self.twitterButton.frame = CGRectMake(16, 10, 24, 24);
    [self.bottomContainer addSubview:self.twitterButton];

    //Configure Facebook post button
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookButton addTarget:self action:@selector(postToFacebook:) forControlEvents:UIControlEventTouchDown];
    [self.facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [self.facebookButton setImage:[UIImage imageNamed:@"social-facebook"] forState:UIControlStateSelected];
    self.facebookButton.frame = CGRectMake(56, 10, 24, 24);
    [self.bottomContainer addSubview:self.facebookButton];

    //Configure anonymous posting button
    //    self.anonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.anonButton addTarget:self action:@selector(postAnonymously:) forControlEvents:UIControlEventTouchDown];
    //    [self.anonButton setImage:[UIImage imageNamed:@"eye-26"] forState:UIControlStateNormal];
    //    [self.anonButton setImage:[UIImage imageNamed:@"eye-filled"] forState:UIControlStateSelected];
    //    self.anonButton.frame = CGRectMake(96, 10, 24, 24);
    //    [self.bottomContainer addSubview:self.anonButton];

    //    //Configure anonymous label (default alpha = 0)
    //    self.anonLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 15, 83, 17)];
    //    self.anonLabel.text = @"ANONYMOUS";
    //    self.anonLabel.font = [UIFont notaBoldWithSize:15];
    //    self.anonLabel.textColor = [UIColor frescoOrangeColor];
    //    self.anonLabel.alpha = 0;
    //    [self.bottomContainer addSubview:self.anonLabel];

    //Configure next button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem]; //Should be green when valid
    [_sendButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [_sendButton setTintColor:[UIColor frescoLightTextColor]];
    _sendButton.frame = CGRectMake(self.view.frame.size.width - 64, 0, 64, 44);
    [_sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    _sendButton.userInteractionEnabled = NO;
    [_sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.userInteractionEnabled = NO;
    [self.bottomContainer addSubview:_sendButton];
}

#pragma mark - UIScrollView

- (void)configureScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.scrollView];
}

- (void)adjustScrollViewContentSize {
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height + self.globalAssignmentsTableView.frame.size.height + self.captionContainer.frame.size.height + 38);

    if (self.scrollView.contentSize.height <= self.view.frame.size.height) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.view.frame.size.height + 1);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    //check mute toggle
    [self.carouselCell pausePlayer];

    CGFloat offset = scrollView.contentOffset.y + 20;

    //If user is scrolling down, return and act like a normal scroll view
    if (offset > self.scrollView.contentSize.height - self.scrollView.frame.size.height) {
        return;
    }

    //If user is scrolling up, scale with content offset.
    if (offset <= 0) {
        self.galleryCollectionView.clipsToBounds = NO;

        //self.galleryCollectionView.layer.masksToBounds = NO;
        //NSLog(@"COLLECTIONVIEW HEIGHT: %f", self.galleryCollectionView.frame.size.height);
        [self.galleryCollectionView setFrame:CGRectMake(0, offset, self.galleryCollectionView.frame.size.width, self.galleryCollectionViewHeight + (-offset))];

        for (FRSCarouselCell *cell in self.galleryCollectionView.visibleCells) {
            for (CALayer *layer in cell.layer.sublayers) {
                CGRect newFrame = layer.frame;
                newFrame.size.height = self.galleryCollectionView.frame.size.height;

                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [layer setFrame:newFrame];
                [CATransaction commit];
            }
            [cell.layer setFrame:self.galleryCollectionView.frame];
        }

        [self.galleryCollectionView.collectionViewLayout invalidateLayout];
        //NSLog(@"COLLECTIONVIEW HEIGHT: %f", self.galleryCollectionView.frame.size.height);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    //Update pageControl in galleryCollectionView
    CGFloat pageWidth = self.galleryCollectionView.frame.size.width;
    if (scrollView == self.galleryCollectionView) {
        self.pageControl.currentPage = self.galleryCollectionView.contentOffset.x / pageWidth;
    }
    [self.carouselCell playPlayer];

    //    for (UICollectionViewCell *cell in [self.galleryCollectionView visibleCells]) {
    //        NSIndexPath *indexPath = [self.galleryCollectionView indexPathForCell:cell];
    //        NSLog(@"%@", indexPath);
    //    }
}

#pragma mark - UITableView

- (void)configureAssignmentsTableView {

    self.assignmentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height, self.view.frame.size.width, (self.assignmentsArray.count + 1) * 44)];
    self.assignmentsTableView.scrollEnabled = NO;
    self.assignmentsTableView.delegate = self;
    self.assignmentsTableView.dataSource = self;
    self.assignmentsTableView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.assignmentsTableView.showsVerticalScrollIndicator = NO;
    self.assignmentsTableView.delaysContentTouches = NO;
    self.assignmentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.dismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    self.dismissKeyboardGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.dismissKeyboardGestureRecognizer];

    [self.scrollView addSubview:self.assignmentsTableView];
}

- (void)configureGlobalAssignmentsDrawer {

    if (!_globalAssignments || _globalAssignments.count == 0) {
        return;
    }

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2];
    self.globalAssignmentsDrawer = [[UIView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height, self.view.frame.size.width, 44)];
    self.globalAssignmentsDrawer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.globalAssignmentsDrawer];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    label.text = [NSString stringWithFormat:@"%lu global assignments", self.globalAssignments.count];
    if (self.globalAssignments.count == 1) {
        label.text = [NSString stringWithFormat:@"%lu global assignment", self.globalAssignments.count];
    }
    [label sizeToFit];
    label.frame = CGRectMake(self.globalAssignmentsDrawer.frame.size.width / 2 - label.frame.size.width / 2, 6, label.frame.size.width, 14);
    [self.globalAssignmentsDrawer addSubview:label];

    UIImageView *globe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earth-16"]]; //swap with 16x16 earth
    globe.frame = CGRectMake(label.frame.origin.x - 16 - 6, 8, 16, 16);
    [self.globalAssignmentsDrawer addSubview:globe];

    self.globalAssignmentsCaret = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-caret"]];
    self.globalAssignmentsCaret.transform = CGAffineTransformMakeRotation(M_PI);
    self.globalAssignmentsCaret.frame = CGRectMake(self.view.frame.size.width / 2 - 8 / 2, 28, 8, 8);
    [self.globalAssignmentsDrawer addSubview:self.globalAssignmentsCaret];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleGlobalAssignmentsDrawer)];
    [self.globalAssignmentsDrawer addGestureRecognizer:tap];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, self.globalAssignmentsDrawer.frame.size.width, .5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.globalAssignmentsDrawer addSubview:line];
    [CATransaction commit];
}

- (void)toggleGlobalAssignmentsDrawer {

    if (self.globalAssignmentsEnabled) {
        self.globalAssignmentsEnabled = NO;
        [self hideAndRemoveGlobalAssignments];
        self.globalAssignmentsCaret.transform = CGAffineTransformMakeRotation(M_PI);
        NSLog(@"disabled");
    } else {
        self.globalAssignmentsEnabled = YES;
        [self configureAndShowGlobalAssignments];
        self.globalAssignmentsCaret.transform = CGAffineTransformMakeRotation(0);
        NSLog(@"enabled");
    }
}

- (void)toggleGestureRecognizer {

    if (self.dismissKeyboardGestureRecognizer.enabled) {
        self.dismissKeyboardGestureRecognizer.enabled = NO;
    } else {
        self.dismissKeyboardGestureRecognizer.enabled = YES;
    }
}

- (void)configureAndShowGlobalAssignments {

    self.globalAssignmentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height, self.view.frame.size.width, (self.globalAssignments.count) * 44)];
    self.globalAssignmentsTableView.scrollEnabled = NO;
    self.globalAssignmentsTableView.delegate = self;
    self.globalAssignmentsTableView.dataSource = self;
    self.globalAssignmentsTableView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.globalAssignmentsTableView.showsVerticalScrollIndicator = NO;
    self.globalAssignmentsTableView.delaysContentTouches = NO;
    self.globalAssignmentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollView addSubview:self.globalAssignmentsTableView];

    [self resetFrames:false];
}

- (void)hideAndRemoveGlobalAssignments {

    self.globalAssignmentsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);

    [self.globalAssignmentsTableView removeFromSuperview];
    self.globalAssignmentsTableView = nil;
    [self resetFrames:false];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.assignmentsTableView) {
        return self.numberOfRowsInAssignmentTableView + 1;
    } else if (tableView == self.globalAssignmentsTableView) {
        return self.numberOfRowsInGlobalAssignmentTableView;
    } else {
        return 0; //will never get called
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FRSAssignmentPickerTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell configureAssignmentCellForIndexPath:indexPath];
    NSLog(@"Displaying Row #%li", (long)indexPath.row);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == self.assignmentsTableView) {
        NSLog(@"Setup cells");
        if (indexPath.row < _assignmentsArray.count + numberOfOutlets) {
            if (_showingOutlets) {
                if (indexPath.row > selectedRow && indexPath.row <= selectedRow + numberOfOutlets) {
                    FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:nil];

                    [cell configureOutletCellWithOutlet:[cell.outlets objectAtIndex:indexPath.row]];
                    //NSDictionary *outlet = [cell.outlets objectAtIndex:indexPath.row];
                    //cell.representedOutletID = [outlet objectForKey:@"id"];

                    //[self resetFrames:true];
                    return cell;
                }
            }

            NSInteger row = 0;

            if (_showingOutlets && indexPath.row > selectedRow) {
                row = indexPath.row - numberOfOutlets;
            } else {
                row = indexPath.row;
            }
            FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:[self.assignmentsArray objectAtIndex:row]];
            [cell configureAssignmentCellForIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];

            return cell;
        } else {
            FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:nil];
            return cell;
        }
    } else if (tableView == self.globalAssignmentsTableView) {

        if (indexPath.row < _globalAssignments.count + numberOfOutlets) {
            if (_showingOutlets) {
                if (indexPath.row > selectedRow && indexPath.row <= selectedRow + numberOfOutlets) {
                    FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:nil];

                    [cell configureOutletCellWithOutlet:[cell.outlets objectAtIndex:indexPath.row]];
                    //NSDictionary *outlet = [cell.outlets objectAtIndex:indexPath.row];
                    //cell.representedOutletID = [outlet objectForKey:@"id"];

                    //[self resetFrames:true];
                    return cell;
                }
            }

            NSInteger row = 0;

            if (_showingOutlets && indexPath.row > selectedRow) {
                row = indexPath.row - numberOfOutlets;
            } else {
                row = indexPath.row;
            }
            FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:[self.globalAssignments objectAtIndex:row]];
            [cell configureAssignmentCellForIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];

            return cell;
        }

        //FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:[self.globalAssignments objectAtIndex:indexPath.row]];
        //[cell configureAssignmentCellForIndexPath:indexPath];
        //return cell;
    } else {
        FRSAssignmentPickerTableViewCell *cell;
        return cell;
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"Selected an assignment");
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = 0;

    if (_showingOutlets && indexPath.row > selectedRow) {
        row = indexPath.row - numberOfOutlets;
    } else {
        row = indexPath.row;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FRSAssignmentPickerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    BOOL cellIsOutlet = cell.isAnOutlet;
    BOOL prevCellIsOutlet = self.prevCell.isAnOutlet;

    if (cellIsOutlet && !cell.isSelectedOutlet) {
        [self resetOtherOutlets];
        cell.isSelectedOutlet = YES;
        selectedOutlet = cell.representedOutletID;

        NSLog(@"SELECTED OUTLET: %@", selectedOutlet);
    } else if (!cell.isSelectedAssignment && !cellIsOutlet) {
        [self resetOtherCells];
        [self resetOtherOutlets];
        cell.isSelectedAssignment = YES;

        if (tableView == self.assignmentsTableView) {
            if (indexPath.row < self.assignmentsArray.count) {
                self.selectedAssignment = [self.assignmentsArray objectAtIndex:indexPath.row];
            } else {
                self.selectedAssignment = Nil;
            }
        } else if (tableView == self.globalAssignmentsTableView) {
            self.selectedAssignment = [self.globalAssignments objectAtIndex:indexPath.row];
        }

        selectedRow = indexPath.row;

        //Checks if the current cell has more than one outlet
        if (cell.outlets.count > 1 && tableView != self.globalAssignmentsTableView && !_showingAssignmentOutlets) {

            if ((self.numberOfRowsInGlobalAssignmentTableView > self.globalAssignments.count && self.prevCell != nil && !cellIsOutlet && !prevCellIsOutlet) && self.prevCell != cell) {
                self.numberOfRowsInGlobalAssignmentTableView = self.globalAssignments.count;
                [self collapseTableView:self.globalAssignmentsTableView assignments:self.globalAssignments currentCell:cell];
            }

            self.numberOfRowsInAssignmentTableView += cell.outlets.count;

            numberOfOutlets = cell.outlets.count;
            self.showingOutlets = YES;
            self.showingAssignmentOutlets = YES;

            //set prevcell so the outlets will be removed if user selects a different assignment
            self.prevCell = cell;

            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

            for (int i = 1; i <= cell.outlets.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + i inSection:0]];
            }

            [CATransaction begin];
            [self resetFrames:true];

            [CATransaction setCompletionBlock:^{
              [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
              for (int i = 0; i < indexPaths.count; i++) {
                  FRSAssignmentPickerTableViewCell *outletCell = [tableView cellForRowAtIndexPath:[indexPaths objectAtIndex:i]];
                  outletCell.isAnOutlet = true;
                  NSDictionary *outletDic = [cell.outlets objectAtIndex:i];
                  [outletCell.titleLabel setText:outletDic[@"title"]];
                  outletCell.representedOutletID = outletDic[@"id"];
              }
              [self tableView:tableView willSelectRowAtIndexPath:[indexPaths objectAtIndex:0]];
              [self tableView:tableView didSelectRowAtIndexPath:[indexPaths objectAtIndex:0]];
              // animation has finished
            }];
            [CATransaction commit];

            return; //Return to avoid removing cells twice
        }

        //Checks if the current cell has more than one outlet
        if (cell.outlets.count > 1 && tableView != self.assignmentsTableView && !_showingGlobalOutlets) {
            self.numberOfRowsInGlobalAssignmentTableView += cell.outlets.count;

            if ((self.numberOfRowsInAssignmentTableView > self.assignmentsArray.count + 1 && self.prevCell != nil && !cellIsOutlet && !prevCellIsOutlet) && self.prevCell != cell) {
                self.numberOfRowsInAssignmentTableView = self.assignmentsArray.count;
                [self collapseTableView:self.assignmentsTableView assignments:self.assignmentsArray currentCell:cell];
            }

            numberOfOutlets = cell.outlets.count;
            self.showingOutlets = YES;
            self.showingGlobalOutlets = YES;

            //set prevcell so the outlets will be removed if user selects a different assignment
            self.prevCell = cell;

            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

            for (int i = 1; i <= cell.outlets.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + i inSection:0]];
            }

            [CATransaction begin];
            [self resetFrames:true];

            [CATransaction setCompletionBlock:^{
              [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
              for (int i = 0; i < indexPaths.count; i++) {
                  FRSAssignmentPickerTableViewCell *outletCell = [tableView cellForRowAtIndexPath:[indexPaths objectAtIndex:i]];
                  outletCell.isAnOutlet = true;
                  NSDictionary *outletDic = [cell.outlets objectAtIndex:i];
                  [outletCell.titleLabel setText:outletDic[@"title"]];
                  outletCell.representedOutletID = outletDic[@"id"];
              }
              [self tableView:tableView willSelectRowAtIndexPath:[indexPaths objectAtIndex:0]];
              [self tableView:tableView didSelectRowAtIndexPath:[indexPaths objectAtIndex:0]];
              // animation has finished
            }];
            [CATransaction commit];

            return; //Return to avoid removing cells twice
        }
    }

    //Removes previously added outlet cells when the user selects a cell that does not contain outlets
    //Ex: User selects cell with outlets, user selects "No assignment"
    if (tableView == self.assignmentsTableView) {
        if ((self.numberOfRowsInAssignmentTableView > self.assignmentsArray.count + 1 && self.prevCell != nil && !cellIsOutlet && !prevCellIsOutlet) && self.prevCell != cell) {
            self.numberOfRowsInAssignmentTableView = self.assignmentsArray.count;
            [self collapseTableView:self.assignmentsTableView assignments:self.assignmentsArray currentCell:cell];
        }
    } else if (tableView == self.globalAssignmentsTableView) {
        if ((self.numberOfRowsInGlobalAssignmentTableView > self.globalAssignments.count && self.prevCell != nil && !cellIsOutlet && !prevCellIsOutlet) && self.prevCell != cell) {
            self.numberOfRowsInGlobalAssignmentTableView = self.globalAssignments.count;
            [self collapseTableView:self.globalAssignmentsTableView assignments:self.globalAssignments currentCell:cell];
        }
    }

    //Call at the end
    if (tableView == self.assignmentsTableView) {
        self.previouslySelectedAssignmentIndexPath = indexPath;
    } else if (tableView == self.globalAssignmentsTableView) {
        self.previouslySelectedGlobalIndexPath = indexPath;
    }
}

- (void)collapseTableView:(UITableView *)tableView assignments:(NSArray *)assignments currentCell:(FRSAssignmentPickerTableViewCell *)cell {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 1; i <= self.prevCell.outlets.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:[tableView indexPathForCell:self.prevCell].row + i inSection:0]];
    }
    self.showingOutlets = false;
    if (tableView == self.globalAssignmentsTableView) {
        self.showingGlobalOutlets = NO;
    } else if (tableView == self.assignmentsTableView) {
        self.showingAssignmentOutlets = NO;
    }
    [self resetOtherOutlets];

    _prevCell.isSelectedAssignment = false;
    [CATransaction begin];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [CATransaction setCompletionBlock:^{
      [self resetFrames:true];
    }];
    [CATransaction commit];
}

- (void)resetOtherCells {
    numberOfOutlets = 0;
    for (NSInteger i = 0; i < [self.assignmentsTableView indexPathsForVisibleRows].count; i++) {
        FRSAssignmentPickerTableViewCell *cell = [self.assignmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedAssignment = NO;
    }
    for (NSInteger i = 0; i < [self.globalAssignmentsTableView indexPathsForVisibleRows].count; i++) {
        FRSAssignmentPickerTableViewCell *cell = [self.globalAssignmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedAssignment = NO;
    }
}

- (void)resetOtherOutlets {
    for (NSInteger i = 0; i < [self.assignmentsTableView indexPathsForVisibleRows].count; i++) {
        FRSAssignmentPickerTableViewCell *cell = [self.assignmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedOutlet = NO;
    }
    for (NSInteger i = 0; i < [self.globalAssignmentsTableView indexPathsForVisibleRows].count; i++) {
        FRSAssignmentPickerTableViewCell *cell = [self.globalAssignmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedOutlet = NO;
    }
}

#pragma mark - Text View

- (void)configureTextView {

    NSInteger textViewHeight = 200;

    self.captionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height + self.globalAssignmentsTableView.frame.size.height + 14, self.view.frame.size.width, 200 + 16)];
    [self.scrollView addSubview:self.captionContainer];

    self.captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, textViewHeight)];
    self.captionTextView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.captionTextView.clipsToBounds = YES;
    self.captionTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.captionTextView.textColor = [UIColor frescoDarkTextColor];
    self.captionTextView.tintColor = [UIColor frescoOrangeColor];
    self.captionTextView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.captionContainer addSubview:self.captionTextView];

    //    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-16, 0, self.view.frame.size.width, 0.5)];
    //    line.backgroundColor = [UIColor frescoShadowColor];
    //    [self.captionContainer addSubview:line];

    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, 17)];
    self.placeholderLabel.text = @"What's happening?";
    self.placeholderLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.placeholderLabel.textColor = [UIColor frescoLightTextColor];
    [self.captionContainer addSubview:self.placeholderLabel];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) { //Check for spaces
        self.placeholderLabel.alpha = 1;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    //Check the send button state
    self.sendButton.userInteractionEnabled = (_captionTextView.text.length > 0);
    if (self.sendButton.userInteractionEnabled) {
        [self.sendButton setTintColor:[UIColor frescoBlueColor]];
    } else {
        [self.sendButton setTintColor:[UIColor frescoLightTextColor]];
        self.sendButton.userInteractionEnabled = NO;
    }
    [textView setText:[textView.text stringByReplacingOccurrencesOfString:@"arthurdearaujo" withString:@"💩🎉"]];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeholderLabel.alpha = 0;

    return YES;
}

- (void)dismissKeyboard {
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - Keyboard

- (void)handleKeyboardWillShow:(NSNotification *)sender {
    [self toggleGestureRecognizer];

    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.view.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
}

- (void)handleKeyboardWillHide:(NSNotification *)sender {
    [self toggleGestureRecognizer];

    self.view.transform = CGAffineTransformMakeTranslation(0, 0);
}

#pragma mark - Assignments

- (void)configureAssignments {
    [self fetchAssignmentsNearLocation:[FRSLocator sharedLocator].currentLocation radius:50];
}

- (void)fetchAssignmentsNearLocation:(CLLocation *)location radius:(NSInteger)radii {

    if (self.isFetching)
        return;

    self.isFetching = YES;

    [[FRSAPIClient sharedClient] getAssignmentsWithinRadius:radii
                                                 ofLocation:@[ @(location.coordinate.longitude), @(location.coordinate.latitude) ]
                                             withCompletion:^(id responseObject, NSError *error) {

                                               NSArray *assignments = (NSArray *)responseObject[@"nearby"];
                                               NSArray *globalAssignments = (NSArray *)responseObject[@"global"];

                                               FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
                                               // self.assignmentsArray = [[NSMutableArray alloc] init];
                                               //  self.assignmentsArray  = [assignments mutableCopy];
                                               self.globalAssignments = [globalAssignments copy];
                                               self.assignments = [assignments copy];

                                               self.isFetching = NO;

                                               if (!notFirstFetch) {
                                                   notFirstFetch = TRUE;
                                                   [self cacheAssignments];
                                               }

                                               [delegate.managedObjectContext save:Nil];
                                               [delegate saveContext];
                                               NSMutableArray *nearBy = responseObject[@"nearby"];
                                               NSArray *global = responseObject[@"global"];
                                               self.assignmentsArray = [[NSMutableArray alloc] init];
                                               for (NSDictionary *assignment in nearBy) {
                                                   NSLog(@"NEAR BY: %@", assignment);
                                                   NSArray *coords = assignment[@"location"][@"coordinates"];
                                                   CLLocation *assigmentLoc = [[CLLocation alloc] initWithLatitude:[[coords objectAtIndex:1] floatValue] longitude:[[coords objectAtIndex:0] floatValue]];
                                                   float radius = [assignment[@"radius"] floatValue];

                                                   BOOL shouldAdd = FALSE;

                                                   for (PHAsset *asset in self.content) {
                                                       CLLocation *location = asset.location;
                                                       CLLocationDistance distanceFromAssignment = [location distanceFromLocation:assigmentLoc];
                                                       float miles = distanceFromAssignment / 1609.34;
                                                       if (miles < radius) {
                                                           shouldAdd = TRUE;
                                                       }
                                                       //1609.34
                                                   }

                                                   if (shouldAdd) {
                                                       [self.assignmentsArray addObject:assignment];
                                                   }

                                                   // CLLocationDistance distanceFromAssignment = [[FRSLocator sharedLocator].currentLocation distanceFromLocation:assigmentLoc];
                                               }

                                               //  self.assignmentsArray = nearBy;
                                               self.numberOfRowsInAssignmentTableView = _assignmentsArray.count;
                                               NSLog(@"ASSIGNMENT ARRAY COUNT: %lu", (unsigned long)self.assignmentsArray.count);

                                               self.globalAssignments = global;
                                               self.numberOfRowsInGlobalAssignmentTableView = _globalAssignments.count;

                                               [self.spinner stopLoading];
                                               [self.spinner removeFromSuperview];

                                               /*
        NSLog(@"Response Object: %@", responseObject);
        NSLog(@"Assignments: %@", nearBy);
        NSLog(@"Global Assignments: %@", global);
        NSLog(@"Error: %@", error);
        */
                                               //Get the closest assignment to the user
                                               CLLocationDistance closestDistance = 9999999999999999999.0;
                                               int closestIndex = 0;
                                               for (int i = 0; i < self.assignmentsArray.count; i++) {
                                                   NSDictionary *assignmentDic = [self.assignmentsArray objectAtIndex:i];
                                                   NSArray *coords = assignmentDic[@"location"][@"coordinates"];
                                                   //NSLog(@"Lat: %@ Long: %@",[coords objectAtIndex:0], [coords objectAtIndex:1]);
                                                   CLLocation *assigmentLoc = [[CLLocation alloc] initWithLatitude:[[coords objectAtIndex:0] floatValue] longitude:[[coords objectAtIndex:1] floatValue]];
                                                   CLLocationDistance distanceFromAssignment = [[FRSLocator sharedLocator].currentLocation distanceFromLocation:assigmentLoc];
                                                   //NSLog(@"Distance: %f",distanceFromAssignment);
                                                   if (closestDistance > distanceFromAssignment) {
                                                       closestDistance = distanceFromAssignment;
                                                       //NSLog(@"Closest Distance: %f",closestDistance);
                                                       closestIndex = i;
                                                   }
                                               }

                                               [self configureAssignmentsTableView];

                                               self.closestAssignmentIndex = closestIndex;

                                               //If there is a preselectedGlobalAssignment then change the index
                                               if (self.preselectedGlobalAssignment) {

                                                   for (int i = 0; i < self.globalAssignments.count; i++) {
                                                       if ([[self.globalAssignments objectAtIndex:i] isEqual:self.preselectedGlobalAssignment]) {
                                                           self.closestAssignmentIndex = i;
                                                       }
                                                   }
                                               }

                                               if (self.preselectedAssignment) {

                                                   for (int i = 0; i < self.assignments.count; i++) {
                                                       if ([[self.assignments objectAtIndex:i] isEqual:self.preselectedAssignment]) {
                                                           self.closestAssignmentIndex = i;
                                                           NSString *assignmentTitle = [[self.assignments objectAtIndex:i] objectForKey:@"title"];
                                                           [self selectAssignmentWithTitle:assignmentTitle];
                                                       }
                                                   }
                                               }

                                               [self configureGlobalAssignmentsDrawer];
                                               if (self.preselectedGlobalAssignment) {
                                                   [self toggleGlobalAssignmentsDrawer];
                                               }
                                               [self configureTextView];
                                               [self adjustScrollViewContentSize];

                                               [self.assignmentsTableView reloadData];
                                               [self.globalAssignmentsTableView reloadData];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self tableView:self.assignmentsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.closestAssignmentIndex inSection:0]];
                                                 if (self.preselectedGlobalAssignment) {
                                                     [self tableView:self.globalAssignmentsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.closestAssignmentIndex inSection:0]];
                                                 }
                                                 if (self.preselectedAssignment) {
                                                     [self tableView:self.assignmentsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.closestAssignmentIndex inSection:0]];
                                                 }
                                               });
                                             }];
}

- (void)selectAssignmentWithTitle:(NSString *)title {

    for (FRSAssignmentPickerTableViewCell *cell in [self.assignmentsTableView visibleCells]) {

        if ([cell.titleLabel.text isEqualToString:title]) {
            NSIndexPath *indexPath = [self.assignmentsTableView indexPathForCell:cell];
            // need to delay and dispatch to the main thread here to override any other didSelects
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [self tableView:self.assignmentsTableView didSelectRowAtIndexPath:indexPath];
            });
        }
    }
}

- (BOOL)assignmentExists:(NSString *)assignment {

    __block BOOL returnValue = FALSE;

    [self.assignmentIDs enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      NSString *currentID = (NSString *)obj;

      if ([currentID isEqualToString:assignment]) {
          returnValue = TRUE;
      }
    }];

    return returnValue;
}

- (void)cacheAssignments {
}

#pragma mark - Actions

/* Navigation bar*/
//Back button action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];

    //Delay to avoid white flash
    [self performSelector:@selector(resetView) withObject:self afterDelay:0.35];
}

- (void)resetView {
    [self.pageControl removeFromSuperview];
    self.content = nil;
    self.players = nil;
    [self.carouselCell removePlayers];
    [self.carouselCell removeFromSuperview];
    [self.galleryCollectionView reloadData];
}
//Next button action
- (void)send {

    /* if authenticated */
    if (![[FRSAPIClient sharedClient] isAuthenticated]) {
        FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
        [self.navigationController pushViewController:onboardVC animated:NO];
        return;
    }

    if (!self.loadingView) {
        [self configureSpinner];
    }

    [self startSpinner:self.loadingView onButton:self.sendButton];
    self.sendButton.userInteractionEnabled = NO;
    [self.sendButton setTintColor:[UIColor frescoLightTextColor]];

    [self dismissKeyboard];

    NSInteger videosCounted = 0;
    NSInteger photosCounted = 0;

    for (PHAsset *asset in self.content) {
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            videosCounted++;
        } else {
            photosCounted++;
        }
    }

    [FRSTracker track:submissionsEvent
           parameters:@{ @"videos_submitted" : @(videosCounted),
                         @"photos_submitted" : @(photosCounted) }];

    [self getPostData:[NSMutableArray arrayWithArray:self.content] current:[[NSMutableArray alloc] init]];
}

- (void)getPostData:(NSMutableArray *)posts current:(NSMutableArray *)current {
    if (posts.count > 0) {
        PHAsset *firstAsset = posts[0];
        [[FRSAPIClient sharedClient] digestForAsset:firstAsset
                                           callback:^(id responseObject, NSError *error) {
                                             NSNumber *fileSize = responseObject[@"fileSize"];
                                             contentSize += [fileSize longLongValue];

                                             [posts removeObject:firstAsset];
                                             [current addObject:responseObject];

                                             if (error) {
                                                 [self creationError:error];
                                                 [self stopSpinner:self.loadingView onButton:self.sendButton];
                                                 self.sendButton.userInteractionEnabled = YES;
                                                 return;
                                             }

                                             [self getPostData:posts current:current];
                                           }];
    } else {
        // upload
        NSMutableDictionary *gallery = [[NSMutableDictionary alloc] init];

        if (self.selectedAssignment) {
            gallery[@"assignment_id"] = [(NSDictionary *)self.selectedAssignment objectForKey:@"id"];
            NSLog(@"attaching assignment: %@", gallery[@"assignment_id"]);
        } else if (selectedRow < self.assignmentsArray.count) {
            gallery[@"assignment_id"] = self.assignmentsArray[selectedRow][@"id"];
            NSLog(@"attaching assignment: %@", gallery[@"assignment_id"]);
        }

        gallery[@"posts_new"] = current;
        gallery[@"caption"] = self.captionTextView.text;

        if (_showingOutlets && selectedOutlet) {
            gallery[@"outlet_id"] = selectedOutlet;
        }

        NSLog(@"CREATING: %@", gallery);

        [[FRSAPIClient sharedClient] post:createGalleryEndpoint
                           withParameters:gallery
                               completion:^(id responseObject, NSError *error) {
                                 if (!error) {
                                     NSLog(@"Gallery creation success... (1/2)");
                                     [self moveToUpload:responseObject];
                                 } else {
                                     NSLog(@"Gallery creation error... (%@)", error);
                                     [self creationError:error];
                                     [self stopSpinner:self.loadingView onButton:self.sendButton];
                                     self.sendButton.userInteractionEnabled = YES;
                                     return;
                                 }
                               }];
    }
}

- (void)creationError:(NSError *)error {
    if (error.code == -1009) {
        [self connectionError:error];
        return;
    }

    FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY ERROR" message:@"We encountered an issue creating your gallery. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
    [alert show];
}

- (void)connectionError:(NSError *)error {
    FRSAlertView *alert = [[FRSAlertView alloc] initNoConnectionAlert];
    [alert show];
}

- (void)moveToUpload:(NSDictionary *)postData {
    /* upload started */
    NSString *galleryID = postData[@"id"];

    if (galleryID && ![galleryID isEqual:[NSNull null]]) {

        NSString *shareString = [[[self.captionTextView.text stringByAppendingString:@" "] stringByAppendingString:@"https://fresconews.com/gallery/"] stringByAppendingString:galleryID];

        if (self.twitterButton.selected) {
            [self tweet:shareString];
        }

        if (self.facebookButton.selected) {
            [self facebook:shareString];
        }
    }
    // instantiate upload process
    // start upload process
    NSArray *posts = postData[@"posts_new"];

    int i = 0;
    for (PHAsset *asset in self.content) {
        NSDictionary *post = posts[i];
        NSString *key = post[@"key"];
        [[FRSUploadManager sharedUploader] addAsset:asset withToken:key withPostID:post[@"post_id"]];
        i++;
    }

    [self.carouselCell pausePlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tweet:(NSString *)string {
    //DOES NOT TWEET
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];

    NSString *tweetEndpoint = @"https://api.twitter.com/1.1/statuses/update.json";
    NSDictionary *params = @{ @"status" : string };
    NSError *clientError;

    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:tweetEndpoint parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request
                        completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                          NSLog(@"Twitter Response: %@", response);

                          if (data) {
                              NSError *jsonError;
                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                              NSLog(@"Twitter Response: %@", json);
                          } else {
                              NSLog(@"Error: %@", connectionError);
                          }
                        }];
    } else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)facebook:(NSString *)text {
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters:@{ @"message" : text } HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
        }];

    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[ @"publish_actions" ]
                               fromViewController:self
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters:@{ @"message" : text } HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
                                            }];
                                          }];
    }
}

- (void)square {
}

/* Bottom Bar */
//Post to Facebook
- (void)postToFacebook:(UIButton *)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebook-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

//Post to Twitter
- (void)postToTwitter:(UIButton *)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitter-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

//Post Anonymously
- (void)postAnonymously:(UIButton *)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"anon-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

- (void)updateStateForButton:(UIButton *)button {

    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }

    /* Check for self.anonButton to change associated label */
    if (button == self.anonButton && self.anonButton.selected) {
        self.anonLabel.alpha = 1;
    } else if (button == self.anonButton) {
        self.anonLabel.alpha = 0;
    }

    //Sets BOOL toggles for bottom bar
    [self checkBottomBar];

    if (self.postToFacebook) {
        NSLog(@"Post to Facebook");
    }

    if (self.postToTwitter) {
        NSLog(@"Post to Twitter");
    }

    if (self.postAnon) {
        NSLog(@"Post Anonymously");
    }
}

- (void)checkBottomBar {
    if (self.facebookButton.selected) {
        self.postToFacebook = YES;
    } else {
        self.postToFacebook = NO;
    }

    if (self.twitterButton.selected) {
        self.postToTwitter = YES;
    } else {
        self.postToTwitter = NO;
    }

    if (self.anonButton.selected) {
        self.postAnon = YES;
    } else {
        self.postAnon = NO;
    }
}

#pragma mark - NSNotification Center

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObservers {

    /* Bottom bar notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"anon-tapped-filevc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"twitter-tapped-filevc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"facebook-tapped-filevc" object:nil];

    /* Keyboard notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)receiveNotifications:(NSNotification *)notification {
    NSString *notif = [notification name];

    if ([notif isEqualToString:@"twitter-tapped-filevc"]) {
        [self updateStateForButton:self.twitterButton];
    } else if ([notif isEqualToString:@"facebook-tapped-filevc"]) {
        [self updateStateForButton:self.facebookButton];
    } else if ([notif isEqualToString:@"anon-tapped-filevc"]) {
        [self updateStateForButton:self.anonButton];
    }
}

@end
