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
#import "AWFileHash.h" // md5 etc.
#import "FRSAPIClient.h"
#import <Photos/Photos.h>
#import "FRSUploadTask.h"

@interface FRSUploadViewController () {
    NSMutableArray *dictionaryRepresentations;
    BOOL notFirstFetch;
}

@property (strong, nonatomic) UIView *navigationBarView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *assignmentsTableView;
@property (strong, nonatomic) UITableView *galleryTableView;
@property (strong, nonatomic) NSArray *assignmentsArray;
@property (strong, nonatomic) UITextView *captionTextView;
@property (strong, nonatomic) UIView *captionContainer;
@property (strong, nonatomic) UIView *bottomContainer;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (nonatomic, retain) NSMutableArray *assignmentIDs;
@property (strong, nonatomic) FRSAssignment *selectedAssignment;
@property (nonatomic) BOOL postToFacebook;
@property (nonatomic) BOOL postToTwitter;
@property (nonatomic) BOOL postAnon;
@property (nonatomic) BOOL isFetching;
@property (nonatomic) BOOL globalAssignmentsEnabled;
@property (strong, nonatomic) NSArray *assignments;
@property (strong, nonatomic) NSArray *globalAssignments;
@property (strong, nonatomic) UIView *globalAssignmentsDrawer;
@property (strong, nonatomic) UITableView *globalAssignmentsTableView;
@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardGestureRecognizer;
@property (strong, nonatomic) UICollectionView *galleryCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *galleryCollectionViewFlowLayout;
@property (strong, nonatomic) FRSCarouselCell *carouselCell;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIImageView *muteImageView;

@property (strong, nonatomic) NSMutableArray *players;

@property NSInteger galleryCollectionViewHeight;

@end

@implementation FRSUploadViewController

static NSString * const cellIdentifier = @"assignment-cell";



-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self checkButtonStates];
    
    self.postToTwitter  = NO;
    self.postToFacebook = NO;
    self.postAnon = NO;
    [self checkBottomBar];
    
    self.assignmentIDs = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self.galleryCollectionView reloadData];
    [self configurePageController];
    
    [self.galleryCollectionView setContentOffset:CGPointMake(0, 0)];
    
    self.carouselCell.assets = self.content;

    self.players = [[NSMutableArray alloc] init];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
    [self.pageControl removeFromSuperview];
    
    [self.carouselCell removePlayers];
    [self.carouselCell removeFromSuperview];
}


-(void)configureUI {
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self addObservers];
    
    [self configureScrollView];
    [self configureGalleryCollectionView];
    [self configurePageController];
    [self configureNavigationBar];
    [self configureAssignments]; //Tableview configures are called here
    [self configureBottomBar];
}

-(void)checkButtonStates {

}

#pragma mark - UICollectionView

-(void)configureGalleryCollectionView {

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
    self.galleryCollectionView.collectionViewLayout = self.galleryCollectionViewFlowLayout;//?
    self.galleryCollectionView.pagingEnabled = YES;
    self.galleryCollectionView.delegate = self;
    self.galleryCollectionView.dataSource = self;
    self.galleryCollectionView.bounces = NO;
    self.galleryCollectionView.backgroundColor = [UIColor whiteColor];
    [self.galleryCollectionView registerNib:[UINib nibWithNibName:@"FRSCarouselCell" bundle:nil] forCellWithReuseIdentifier:@"FRSCarouselCell"];
    [self.scrollView addSubview:self.galleryCollectionView];

    /* DEBUG */
    //self.galleryCollectionView.backgroundColor = [UIColor redColor];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.carouselCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FRSCarouselCell" forIndexPath:indexPath];
    
    PHAsset *asset = [self.content objectAtIndex:indexPath.row];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        [self.carouselCell loadImage:asset];
        self.carouselCell.muteImageView.alpha = 0;
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [self.carouselCell loadVideo:asset];
        [self.players addObject:asset];
    } else if (asset.mediaType == PHAssetMediaTypeAudio) {
        // 3.x feature
    }
    
    [self.carouselCell pausePlayer];
    
    return self.carouselCell;
}

-(BOOL)currentPageIsVideo {
    CGFloat pageWidth = self.galleryCollectionView.frame.size.width;
    NSInteger page = self.galleryCollectionView.contentOffset.x / pageWidth;
    
    //does not work, self.players is nil
    return (self.players.count > page && [self.players[page] respondsToSelector:@selector(pause)]);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, collectionView.frame.size.height);
}

-(void)configurePageController {
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

-(void)configureNavigationBar {

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
    UIButton *squareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    squareButton.frame = CGRectMake(self.navigationBarView.frame.size.width-12-24, 30, 24, 24);
    [squareButton setImage:[UIImage imageNamed:@"square"] forState:UIControlStateNormal];
    [squareButton setTintColor:[UIColor whiteColor]];
    [squareButton addTarget:self action:@selector(square) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:squareButton];
    
    /* Configure titleLabel */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -66/2, 35, 66, 19)];
    [titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [titleLabel setText:@"GALLERY"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self.navigationBarView addSubview:titleLabel];
    
    
    self.navigationBarView.alpha = 0;
    titleLabel.alpha = 0;
}

-(void)configureBottomBar {
    
    /* Configure bottom container */
    self.bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -44, self.view.frame.size.width, 44)];
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
    self.anonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.anonButton addTarget:self action:@selector(postAnonymously:) forControlEvents:UIControlEventTouchDown];
    [self.anonButton setImage:[UIImage imageNamed:@"eye-26"] forState:UIControlStateNormal];
    [self.anonButton setImage:[UIImage imageNamed:@"eye-filled"] forState:UIControlStateSelected];
    self.anonButton.frame = CGRectMake(96, 10, 24, 24);
    [self.bottomContainer addSubview:self.anonButton];
    
    //Configure anonymous label (default alpha = 0)
    self.anonLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 15, 83, 17)];
    self.anonLabel.text = @"ANONYMOUS";
    self.anonLabel.font = [UIFont notaBoldWithSize:15];
    self.anonLabel.textColor = [UIColor frescoOrangeColor];
    self.anonLabel.alpha = 0;
    [self.bottomContainer addSubview:self.anonLabel];
    
    //Configure next button
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem]; //Should be green when valid
    [sendButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [sendButton setTintColor:[UIColor frescoLightTextColor]];
    sendButton.frame = CGRectMake(self.view.frame.size.width-64, 0, 64, 44);
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    //sendButton.userInteractionEnabled = NO;
    [self.bottomContainer addSubview:sendButton];
}


#pragma mark - UIScrollView

-(void)configureScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.scrollView];

}

-(void)adjustScrollViewContentSize {
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height + self.globalAssignmentsDrawer.frame.size.height + self.globalAssignmentsTableView.frame.size.height + self.captionContainer.frame.size.height +44);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //check mute toggle
    [self.carouselCell pausePlayer];
    
    CGFloat offset = scrollView.contentOffset.y + 20;
    
    //If user is scrolling down, return and act like a normal scroll view
    if (offset > self.scrollView.contentSize.height - self.scrollView.frame.size.height) {
        return;
    }
    
    //If user is scrolling up, scale with content offset.
    if (offset <= 0) {
        self.galleryCollectionView.frame = CGRectMake(self.galleryCollectionView.frame.origin.x, offset, self.galleryCollectionView.frame.size.width, self.galleryCollectionViewHeight + (-offset));
        [self.galleryCollectionViewFlowLayout invalidateLayout];
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //Update pageControl in galleryCollectionView
    CGFloat pageWidth = self.galleryCollectionView.frame.size.width;
    if (scrollView == self.galleryCollectionView) {
        self.pageControl.currentPage = self.galleryCollectionView.contentOffset.x / pageWidth;
    }
    
    [self.carouselCell playPlayer];
}


#pragma mark - UITableViewx

-(void)configureAssignmentsTableView {
    
    self.assignmentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height, self.view.frame.size.width, self.assignmentsArray.count *44)];
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

-(void)configureGlobalAssignmentsDrawer {
    self.globalAssignmentsDrawer = [[UIView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height, self.view.frame.size.width, 44)];
    self.globalAssignmentsDrawer.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.scrollView addSubview:self.globalAssignmentsDrawer];
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    label.text = @"6 global assignments";
    [label sizeToFit];
    label.frame = CGRectMake(self.globalAssignmentsDrawer.frame.size.width/2 - label.frame.size.width/2, 6, label.frame.size.width, 14);
    [self.globalAssignmentsDrawer addSubview:label];
    
    UIImageView *globe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earth-16"]]; //swap with 16x16 earth
    globe.frame = CGRectMake(label.frame.origin.x -16 -6, 8, 16, 16);
    [self.globalAssignmentsDrawer addSubview:globe];
    
    UIImageView *caret = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-caret"]];
    caret.frame = CGRectMake(self.view.frame.size.width/2 - 8/2, 28, 8, 8);
    [self.globalAssignmentsDrawer addSubview:caret];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleGlobalAssignmentsDrawer)];
    [self.globalAssignmentsDrawer addGestureRecognizer:tap];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, self.globalAssignmentsDrawer.frame.size.width, .5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.globalAssignmentsDrawer addSubview:line];
}

-(void)toggleGlobalAssignmentsDrawer {
    
    if (self.globalAssignmentsEnabled) {
        self.globalAssignmentsEnabled = NO;
        [self hideAndRemoveGlobalAssignments];
        NSLog(@"disabled");
    } else {
        self.globalAssignmentsEnabled = YES;
        [self configureAndShowGlobalAssignments];
        NSLog(@"enabled");
    }
}

-(void)toggleGestureRecognizer {
    
    if (self.dismissKeyboardGestureRecognizer.enabled) {
        self.dismissKeyboardGestureRecognizer.enabled = NO;
    } else {
        self.dismissKeyboardGestureRecognizer.enabled = YES;
    }
}


-(void)configureAndShowGlobalAssignments {
    
    //create tableview and animate in
    //textfield should move down (*number of global assignments+1) with animation
}

-(void)hideAndRemoveGlobalAssignments {
    //animate out and remove from superview in completion
    //textfield should move up (*number of gloal assignments+1) with animation
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"self.assignmentsArray.count = %llu", (unsigned long long)self.assignmentsArray.count);

    
    if (tableView == self.assignmentsTableView) {
        return self.assignmentsArray.count;
    } else if (tableView == self.globalAssignmentsTableView) {
        return self.globalAssignments.count;
    } else {
        return 0; //will never get called
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSAssignmentPickerTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [cell configureCellForIndexPath:indexPath];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.assignmentsTableView) {
        FRSAssignmentPickerTableViewCell *cell = [[FRSAssignmentPickerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:[self.assignmentsArray objectAtIndex:indexPath.row]];
        
        [cell configureCellForIndexPath:indexPath];
        
        return cell;
    } else if (tableView == self.globalAssignmentsTableView) {
        //configure global cells
    } else {
        FRSAssignmentPickerTableViewCell *cell;
        return cell;
    }
    return nil;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    FRSAssignmentPickerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.isSelectedAssignment){
        cell.isSelectedAssignment = NO;
        self.selectedAssignment = nil;
    }
    else {
        [self resetOtherCells];
        cell.isSelectedAssignment = YES;
        self.selectedAssignment = [self.assignmentsArray objectAtIndex:indexPath.row];
    }
}

-(void)resetOtherCells {
    for (NSInteger i = 0; i < self.assignmentsArray.count + 1; i++){
        FRSAssignmentPickerTableViewCell *cell = [self.assignmentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.isSelectedAssignment = NO;
    }
}

#pragma mark - Text View

-(void)configureTextView {
    
    NSInteger textViewHeight = 200;
    
    self.captionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.galleryCollectionView.frame.size.height + self.assignmentsTableView.frame.size.height +self.globalAssignmentsDrawer.frame.size.height, self.view.frame.size.width, textViewHeight + 16)];
    [self.scrollView addSubview:self.captionContainer];
    
    self.captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, textViewHeight)];
    self.captionTextView.delegate = self;
    self.captionTextView.clipsToBounds = YES;
    self.captionTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.captionTextView.textColor = [UIColor frescoDarkTextColor];
    self.captionTextView.tintColor = [UIColor frescoOrangeColor];
    self.captionTextView.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self.captionContainer addSubview:self.captionTextView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-16, 0, self.view.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.captionContainer addSubview:line];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, 17)];
    self.placeholderLabel.text = @"What's happening?";
    self.placeholderLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.placeholderLabel.textColor = [UIColor frescoLightTextColor];
    [self.captionContainer addSubview:self.placeholderLabel];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) { //Check for spaces
        self.placeholderLabel.alpha = 1;
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeholderLabel.alpha = 0;
    
    return YES;
}

-(void)dismissKeyboard {
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - Keyboard

-(void)handleKeyboardWillShow:(NSNotification *)sender {
    [self toggleGestureRecognizer];
    
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.view.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
}

-(void)handleKeyboardWillHide:(NSNotification *)sender{
    [self toggleGestureRecognizer];
    
    self.view.transform  = CGAffineTransformMakeTranslation(0, 0);
}

#pragma mark - Assignments

-(void)configureAssignments {

    [self fetchAssignmentsNearLocation:[FRSLocator sharedLocator].currentLocation radius:50];
    self.assignmentsArray = self.assignments;
}



-(void)fetchAssignmentsNearLocation:(CLLocation *)location radius:(NSInteger)radii {
    
    if (self.isFetching) return;
    
    self.isFetching = YES;
    
    [[FRSAPIClient sharedClient] getAssignmentsWithinRadius:radii ofLocation:@[@(location.coordinate.longitude), @(location.coordinate.latitude)] withCompletion:^(id responseObject, NSError *error) {
        
        NSArray *assignments = (NSArray *)responseObject[@"nearby"];
        NSArray *globalAssignments = (NSArray *)responseObject[@"global"];

        FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        if (globalAssignments.count > 0) {
            self.globalAssignmentsDrawer.alpha = 0;
            //and globalAssignments tableview.alpha?
        } else {
            self.globalAssignmentsDrawer.alpha = 0;
        }

        self.assignmentsArray  = [assignments copy];
        self.globalAssignments = [globalAssignments copy];
        
        self.isFetching = NO;
        
        if (!notFirstFetch) {
            notFirstFetch = TRUE;
            [self cacheAssignments];
        }
        
        [delegate.managedObjectContext save:Nil];
        [delegate saveContext];
        NSArray *nearBy = responseObject[@"nearby"];
        NSArray *global = responseObject[@"global"];

        if ([global count] >  0) {
            self.globalAssignmentsDrawer.alpha = 0;
        }
        
        self.assignmentsArray = nearBy;
        [self configureAssignmentsTableView];
        [self configureGlobalAssignmentsDrawer];
        [self configureTextView];
        [self adjustScrollViewContentSize];
    }];
}

-(BOOL)assignmentExists:(NSString *)assignment {
    
    __block BOOL returnValue = FALSE;
    
    [self.assignmentIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *currentID = (NSString *)obj;
        
        if ([currentID isEqualToString:assignment]) {
            returnValue = TRUE;
        }
    }];
    
    return returnValue;
}

-(void)fetchLocalAssignments {
    FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(expirationDate >= %@)", [NSDate date]];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FRSAssignment"];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *stored = [moc executeFetchRequest:request error:&error];
    self.assignmentsArray= [NSMutableArray arrayWithArray:stored];
}

-(void)cacheAssignments {
    
}

#pragma mark - Actions

/* Navigation bar*/
    //Back button action
-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

    //Next button action
-(void)send {
    
    if (![[FRSAPIClient sharedClient] isAuthenticated]) {
        
        FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
        [self.navigationController pushViewController:onboardVC animated:NO];
        return;
    }
        
    [self dismissKeyboard];
    

    if (self.postToFacebook) {
        [self facebook:self.captionTextView.text];

    }
    
    
    if (self.postToTwitter) {
        [self tweet:@"test"]; //does not work, fix before release
    }
    
    
    if (self.postAnon) {
        NSLog(@"Post anonymously");
    }
    else {
        [self getPostData:[NSMutableArray arrayWithArray:self.content] current:[[NSMutableArray alloc] init]];
    }
}

-(void)getPostData:(NSMutableArray *)posts current:(NSMutableArray *)current {
    if (posts.count > 0) {
        PHAsset *firstAsset = posts[0];
        [[FRSAPIClient sharedClient] digestForAsset:firstAsset callback:^(id responseObject, NSError *error) {
            [posts removeObject:firstAsset];
            [current addObject:responseObject];
            [self getPostData:posts current:current];
        }];
    }
    else {
        // upload
        NSMutableDictionary *gallery = [[NSMutableDictionary alloc] init];
        gallery[@"posts"] = current;
        gallery[@"caption"] = self.captionTextView.text;

        
        [[FRSAPIClient sharedClient] post:createGalleryEndpoint withParameters:gallery completion:^(id responseObject, NSError *error) {
            if (!error) {
                NSLog(@"Gallery creation success... (1/2)");
                [self moveToUpload:responseObject];
            }
            else {
                NSLog(@"Gallery creation error... (%@)", error);
            }
        }];
    }
}

-(void)moveToUpload:(NSDictionary *)postData {
    int currentIndex = 0;
    
    for (NSDictionary *post in postData[@"posts"]) {
        PHAsset *currentAsset = self.content[currentIndex];
        
        if (currentAsset.mediaType == PHAssetMediaTypeVideo) {

            
            PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            options.networkAccessAllowed = YES;
            options.progressHandler =  ^(double progress,NSError *error,BOOL* stop, NSDictionary* dict) {
                NSLog(@"progress %lf",progress);  //never gets called
            };
            
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:currentAsset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
                AVURLAsset* myAsset = (AVURLAsset*)avasset;
                
                FRSUploadTask  *task = [[FRSUploadTask alloc] init];
                NSLog(@"UPLOADING");
                
                [task createUploadFromData:[NSData dataWithContentsOfURL:myAsset.URL] destination:[NSURL URLWithString:post[@"urls"][0]] progress:^(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                    NSLog(@"UPLOADING");
                } completion:^(id task, NSData *responseData, NSError *error, BOOL success, NSURLResponse *response) {
                   
                }];
                
                [task start];

            }];
        }
        else {
            [[PHImageManager defaultManager] requestImageDataForAsset:currentAsset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                
                FRSUploadTask  *task = [[FRSUploadTask alloc] init];
                NSLog(@"UPLOADING");
                
                [task createUploadFromData:imageData destination:[NSURL URLWithString:post[@"urls"][0]] progress:^(id task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                    NSLog(@"UPLOADING");
                } completion:^(id task, NSData *responseData, NSError *error, BOOL success, NSURLResponse *response) {
                    if (success) {
                        if (success) {
                            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
                            NSLog(@"%@", headers);
                        }
                    }
                }];
                
                [task start];
            }];

        }

        currentIndex++;
    }
}

-(void)tweet:(NSString *)string {
    
    //DOES NOT TWEET

    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];

    NSString *tweetEndpoint = @"https://api.twitter.com/1.1/statuses/update.json";
    NSDictionary *params = @{@"status" : @"hello my friend"};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:tweetEndpoint parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            NSLog(@"Twitter Ressponse: %@", response);
            
            if (data) {
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                NSLog(@"Twitter Response: %@", json);
            }
            else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
    
}




-(void)facebook:(NSString *)text {

    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters: @{ @"message" : text} HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        }];
        
    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters: @{ @"message" : @"test"} HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            }];
        }];
    }
}


-(void)square {
    
}


/* Bottom Bar */
    //Post to Facebook
-(void)postToFacebook:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebook-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

    //Post to Twitter
-(void)postToTwitter:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitter-tapped-uploadvc" object:self];

    [self updateStateForButton:sender];
}

    //Post Anonymously
-(void)postAnonymously:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"anon-tapped-uploadvc" object:self];
    
    [self updateStateForButton:sender];
}

-(void)updateStateForButton:(UIButton *)button {
    
    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }
    
    /* Check for self.anonButton to change associated label */
    if (button == self.anonButton && self.anonButton.selected) {
        self.anonLabel.alpha = 1;
    } else if (button == self.anonButton){
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

-(void)checkBottomBar {
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

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)addObservers {
    
    /* Bottom bar notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"anon-tapped-filevc"     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"twitter-tapped-filevc"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"facebook-tapped-filevc" object:nil];
    
    /* Keyboard notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}


-(void)receiveNotifications:(NSNotification *)notification {
    
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
