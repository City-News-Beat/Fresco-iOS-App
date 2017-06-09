//
//  FRSFileViewController.m
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSFileViewController.h"
#import "FRSUploadViewController.h"
#import "UIFont+Fresco.h"
#import "FRSImageViewCell.h"
#import "FRSFileFooterCell.h"
#import "FRSFileProgressWithTextView.h"
#import "FRSFileSourceNavTitleView.h"
#import "FRSFileSourcePickerTableView.h"
#import "FRSFileSourcePickerViewModel.h"
#import "FRSFileLoader.h"
#import "FRSFileTagViewManager.h"
#import "FRSFilePackageGuidelinesAlertView.h"
#import "FRSTipsViewController.h"

static NSInteger const maxAssets = 8;

@interface FRSFileViewController () <FRSFileLoaderDelegate, FRSFileTagViewManagerDelegate>
@property (strong, nonatomic) UIButton *backTapButton;
@property (strong, nonatomic) FRSUploadViewController *uploadViewController;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;

@property (weak, nonatomic) FRSFileSourceNavTitleView *fileSourceNavTitleView;
@property (strong, nonatomic) FRSFileSourcePickerTableView *fileSourcePickerTableView;
@property (strong, nonatomic) FRSFileLoader *fileLoader;
@property (strong, nonatomic) PHAssetCollection *currentAssetCollection;
@property (strong, nonatomic) FRSFileTagViewManager *fileTagViewManager;
@property (strong, nonatomic) PHAsset *tappedAsset;
@property (strong, nonatomic) NSIndexPath *tappedIndexPath;

@end

@implementation FRSFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    selectedAssets = [[NSMutableArray alloc] init];
    self.selectedIndexPaths = [[NSMutableArray alloc] initWithCapacity:0];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setupFileSourcePickerTableView];
    [self setupCollectionView];
    [self setupSecondaryUI];
    [self setupFileLoader];
    [self setupTagViewManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationBarViews];

    [self shouldShowStatusBar:YES animated:YES];

    if (selectedAssets.count >= 1) {
        nextButton.enabled = YES;
    } else {
        nextButton.enabled = NO;
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [container addSubview:backButton];

    backButton.tintColor = [UIColor whiteColor];
    backButton.frame = CGRectMake(-15, -12, 48, 48);
    backButton.imageView.frame = CGRectMake(-12, 0, 48, 48); //this doesnt change anything
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:container];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

-(void)viewDidAppear:(BOOL)animated {
    
    // This is a hotfix. We're recreating the UploadVC to reset the carousel and keyboard.
    self.uploadViewController = [[FRSUploadViewController alloc] init];
    self.uploadViewController.preselectedGlobalAssignment = self.preselectedGlobalAssignment;
    self.uploadViewController.preselectedAssignment = self.preselectedAssignment;
    [self.uploadViewController view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.backTapButton.userInteractionEnabled = NO;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    [self.backTapButton removeFromSuperview];
}

- (void)setupNavigationBarViews {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{ NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont notaBoldWithSize:18] }];
    
    [self setupNavigationBarButtons];
}

-(void)setupFileSourcePickerTableView {
    self.fileSourcePickerTableView = [[FRSFileSourcePickerTableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 4*44) style:UITableViewStylePlain];
    [self.view addSubview:self.fileSourcePickerTableView];
    self.fileSourcePickerTableView.alpha = 0;
    self.fileSourcePickerTableView.isExpanded = NO;
    
    self.fileSourcePickerTableView.sourceViewModelsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.fileSourcePickerTableView addObserver:self forKeyPath:@"selectedSourceViewModel" options:0 context:nil];
    [self.fileSourcePickerTableView addObserver:self forKeyPath:@"isExpanded" options:0 context:nil];
    
}

- (void)setupNavigationBarButtons {
    //left
    UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *backContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [backContainer addSubview:backButton];
    
    backButton.tintColor = [UIColor whiteColor];
    backButton.frame = CGRectMake(-3, 0, 24, 24);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backContainer];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    //right
    UIImage *questionButtonImage = [UIImage imageNamed:@"question-white"];
    UIButton *questionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *questionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [questionContainer addSubview:questionButton];
    
    questionButton.tintColor = [UIColor whiteColor];
    questionButton.frame = CGRectMake(-3, 0, 24, 24);
    [questionButton setImage:questionButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *questionBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:questionContainer];
    [questionButton addTarget:self action:@selector(questionTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = questionBarButtonItem;

    //title view
    self.fileSourceNavTitleView = [[[NSBundle mainBundle] loadNibNamed:@"FRSFileSourceNavTitleView" owner:self options:nil] lastObject];
    
    //    self.fileSourceNavTitleView = (FRSFileSourceNavTitleView *)self.navigationItem.titleView;
    self.navigationItem.titleView = self.fileSourceNavTitleView;
    
    [self.fileSourceNavTitleView.actionButton addTarget:self action:@selector(navigationBarTapped) forControlEvents:UIControlEventTouchUpInside];
    
//    self.navigationItem.titleView = [[FRSFileSourceNavTitleView alloc] init];
//    self.fileSourceNavTitleView = (FRSFileSourceNavTitleView *)self.navigationItem.titleView;
    [self.fileSourceNavTitleView updateWithTitle:self.fileSourcePickerTableView.selectedSourceViewModel.name];
    [self.fileSourceNavTitleView arrowUp:NO];
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileSourceTapped:)];
//    singleTap.numberOfTapsRequired = 1;
//    self.fileSourceNavTitleView.userInteractionEnabled = YES;
//    [self.fileSourceNavTitleView addGestureRecognizer:singleTap];
    
}

- (void)setupTagViewManager {
    self.fileTagViewManager = [FRSFileTagViewManager sharedInstance];
    self.fileTagViewManager.delegate = self;
    [self.fileTagViewManager addObserver:self forKeyPath:@"tagUpdated" options:0 context:nil];
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.fileSourcePickerTableView && [keyPath isEqualToString:@"selectedSourceViewModel"]) {
        NSLog(@"selectedSourceViewModel changed.");
        [self.fileSourceNavTitleView updateWithTitle:self.fileSourcePickerTableView.selectedSourceViewModel.name];
        [self hideFileSourcePickerTableView];
        [self updateAssetsForCurrentCollection];
    }
    //isExpanded
    if (object == self.fileSourcePickerTableView && [keyPath isEqualToString:@"isExpanded"]) {
        NSLog(@"isExpanded changed.");
        [self.fileSourceNavTitleView arrowUp:self.fileSourcePickerTableView.isExpanded];
    }
    //tagUpdated
    if (object == self.fileTagViewManager && [keyPath isEqualToString:@"tagUpdated"]) {
        NSLog(@"tagUpdated changed.");
        //NSInteger index = [self.fileLoader indexOfAsset:self.tappedAsset];
        //if(index >= 0) {
         //   [fileCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        //}
        [self updateSelectedAssets];
    }

}

- (void)navigationBarTapped {
    if(self.fileSourcePickerTableView.alpha == 0) {
        [self showFileSourcePickerTableView];
    }
    else {
        [self hideFileSourcePickerTableView];
    }
    [self.fileSourcePickerTableView reloadData];
}

- (void)questionTapped {
    [self segueToTipsAction];
}

- (void)showPackageGuidelines {
    FRSFilePackageGuidelinesAlertView *guidelinesView= [[FRSFilePackageGuidelinesAlertView alloc] init];
    guidelinesView.seeTipsAction = ^{
        [self segueToTipsAction];
    };
    [guidelinesView show];
}

- (void)showFileSourcePickerTableView {
    self.fileSourcePickerTableView.alpha = 1;
    self.fileSourcePickerTableView.isExpanded = YES;
    [self.view bringSubviewToFront:self.fileSourcePickerTableView];
}

- (void)hideFileSourcePickerTableView {
    self.fileSourcePickerTableView.alpha = 0;
    self.fileSourcePickerTableView.isExpanded = NO;
}

- (void)fileSourceTapped:(UITapGestureRecognizer *)tap {
    NSLog(@"fileSourceTapped: ");
}

- (void)setupSecondaryUI {

    float screenWidth = [UIScreen mainScreen].bounds.size.width;

    line = [[UIView alloc] initWithFrame:CGRectMake(0, fileCollectionView.frame.origin.y + fileCollectionView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 1)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.view addSubview:line];

    nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [nextButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateDisabled];
    nextButton.frame = CGRectMake(screenWidth - 64, [UIScreen mainScreen].bounds.size.height - 41, 60, 40);
    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    nextButton.enabled = NO;
    [self.view addSubview:nextButton];
}

- (void)setupCollectionView {
    // Do any additional setup after loading the view.
    UINib *imageNib = [UINib nibWithNibName:@"FRSImageViewCell" bundle:[NSBundle mainBundle]]; // used a xib for cell b/c originally I was going to have separate cells for video and image.
    UINib *footerNib = [UINib nibWithNibName:@"FRSFileFooterCell" bundle:[NSBundle mainBundle]];
    UINib *headerNib = [UINib nibWithNibName:@"FRSFileHeaderCell" bundle:[NSBundle mainBundle]];


    // layout for collection view (3 across, 1px spacing, like in sketch)
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellSize = screenWidth / 3.0 - 1;

    UICollectionViewFlowLayout *fileLayout = [[UICollectionViewFlowLayout alloc] init];
    fileLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    fileLayout.itemSize = CGSizeMake(cellSize, cellSize);
    fileLayout.minimumInteritemSpacing = 1;
    fileLayout.minimumLineSpacing = 1;
    fileLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    // actual collection view
    fileCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) collectionViewLayout:fileLayout];

    [fileCollectionView registerNib:imageNib forCellWithReuseIdentifier:imageCellIdentifier];
    [fileCollectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter];
    [fileCollectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader];
    [self.view addSubview:fileCollectionView];
    fileCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

    // constraints on collection view (did collection view manually b/c changing layout after instantiation (i.e from a nib, the spacing can get really messed up.)
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:64];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-44];

    [self.view addConstraints:@[ top, left, bottom, right ]];
    [self.view layoutIfNeeded];

    fileCollectionView.delegate = self;
    fileCollectionView.dataSource = self;

    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    fileCollectionView.backgroundColor = [UIColor frescoBackgroundColorLight];
}

- (void)setupFileLoader {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.fileLoader = [[FRSFileLoader alloc] initWithDelegate:Nil];
        [self updateFileSourcePickerTableView];
    });
}

- (void)next:(id)sender {
    int numberOfVideos = 0;
    int numberOfPhotos = 0;

    for (PHAsset *asset in selectedAssets) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            numberOfPhotos++;
        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
            numberOfVideos++;
        }
    }

    [FRSTracker track:videosInGallery parameters:@{ @"count" : @(numberOfVideos) }];
    [FRSTracker track:photosInGallery parameters:@{ @"count" : @(numberOfPhotos) }];

    self.uploadViewController.content = nil;
    self.uploadViewController.players = nil;
    self.uploadViewController.content = selectedAssets;
    [self.navigationController pushViewController:self.uploadViewController animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/* Footer Related */

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int numberOfAssets = (int)[self.fileLoader numberOfAssets];
    int currentAsset = (int)indexPath.row;

    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellSize = screenWidth / 3.0 - 1;

    if (currentAsset == numberOfAssets) {
        // show footer
        return CGSizeMake(screenWidth, 175);
    }

    return CGSizeMake(cellSize, cellSize);
}

/* Not Footer Related */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// match yellow
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.fileLoader numberOfAssets];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(screenWidth, 225);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(screenWidth, 80);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionFooter) {
        FRSFileFooterCell *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter forIndexPath:indexPath];
        
        CGRect newFrame = footer.frame;
        newFrame.size.height = 225;
        [footer setFrame:newFrame];
        [footer setup];
        
        return footer;
    }
    else if (kind == UICollectionElementKindSectionHeader) {
        __weak typeof(self) weakSelf = self;

        FRSFileProgressWithTextView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader forIndexPath:indexPath];
        
        CGRect newFrame = header.frame;
        newFrame.size.height = 80;
        [header setFrame:newFrame];
        [header setupWithShowPackageGuidelinesBlock:^{
            [weakSelf showPackageGuidelines];
        }];
        
        return header;
    }

    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *representedAsset = [self.fileLoader assetAtIndex:indexPath.row]; // pulls asset from array

    // dequeues cell, as we've registered a nib we will always get a non-nil value
    FRSImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
    cell.fileLoader = self.fileLoader; // gives the cell our (weakly stored) instance of our file loader
    [cell loadAsset:representedAsset]; // gives instruction to update UI

    if ([selectedAssets containsObject:representedAsset]) {
        [cell selected:YES];
        [cell updateFileNumber:([selectedAssets indexOfObject:representedAsset] + 1)];
    } else {
        [cell selected:NO];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.tappedAsset = [self.fileLoader assetAtIndex:indexPath.row]; // pulls asset from array
    self.tappedIndexPath = indexPath;
    
    if(indexPath.row % 2 == 0) {
        [self.fileTagViewManager showTagViewForCaptureMode:FRSCaptureModeVideoWide andTagViewMode:FRSTagViewModeEditTag];
    }
    else {
        [self.fileTagViewManager showTagViewForCaptureMode:FRSCaptureModeVideoWide andTagViewMode:FRSTagViewModeNewTag];
    }
    
    [self.fileTagViewManager showTagViewForAsset:self.tappedAsset];
        
}

- (void)removeTappedAsset {
    PHAsset *representedAsset = self.tappedAsset;
    
    if ([selectedAssets containsObject:representedAsset]) {
        [selectedAssets removeObject:representedAsset];
    }
    
    //indexPaths
    if (![self.selectedIndexPaths containsObject:self.tappedIndexPath]) {
        [self.selectedIndexPaths addObject:self.tappedIndexPath];
    } else {
    }
    [fileCollectionView reloadItemsAtIndexPaths:self.selectedIndexPaths];

}

- (void)updateSelectedAssets {
    PHAsset *representedAsset = self.tappedAsset;
    
    if ([selectedAssets containsObject:representedAsset]) {
        //[selectedAssets removeObject:representedAsset];
    } else {
        if ([selectedAssets count] == maxAssets) {
            //should tell user why they can't select anymore cc:imogen
            return;
        }
        
        [selectedAssets addObject:representedAsset];
    }
    
    if (selectedAssets.count >= 1) {
        nextButton.enabled = YES;
    } else {
        nextButton.enabled = NO;
    }
    
    //indexPaths
    if (![self.selectedIndexPaths containsObject:self.tappedIndexPath]) {
        [self.selectedIndexPaths addObject:self.tappedIndexPath];
    } else {
    }
    [fileCollectionView reloadItemsAtIndexPaths:self.selectedIndexPaths];

}

- (void)applicationNotAuthorized {
    dispatch_async(dispatch_get_main_queue(), ^{
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Roll" message:@"Sadly, you chose not to let us see your photos. To use the app, go to settings, privacy, and allow Fresco to see what's poppin'!" preferredStyle:UIAlertControllerStyleAlert];

      UIAlertAction *ok = [UIAlertAction
          actionWithTitle:@"OK"
                    style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction *action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                  }];

      [alert addAction:ok];
      [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - FRSFileLoaderDelegate

- (void)filesLoaded {
    if ([self.fileLoader numberOfAssets] == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [fileCollectionView reloadData];
    });
}

- (void)updateFileSourcePickerTableView {
    if ([self.fileLoader numberOfCollections] == 0) {
        return;
    }

    [self.fileSourcePickerTableView.sourceViewModelsArray removeAllObjects];
    
    for (PHAssetCollection *assetCollection in [self.fileLoader collections]) {
        FRSFileSourcePickerViewModel *sourceViewModel = [[FRSFileSourcePickerViewModel alloc] initWithName:assetCollection.localizedTitle];
        sourceViewModel.isSelected = YES;
        [self.fileSourcePickerTableView.sourceViewModelsArray addObject:sourceViewModel];

    }

    if(self.fileSourcePickerTableView.sourceViewModelsArray.count > 0) {
        self.fileSourcePickerTableView.selectedSourceViewModel = self.fileSourcePickerTableView.sourceViewModelsArray[0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fileSourcePickerTableView reloadData];        
    });

}

- (void)updateAssetsForCurrentCollection {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.currentAssetCollection = [[self.fileLoader collections] objectAtIndex:self.fileSourcePickerTableView.selectedIndex];
        [self.fileLoader fetchAssetsForCollection:self.currentAssetCollection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [fileCollectionView reloadData];
        });

    });
}

#pragma mark - Bottom Bar Buttons

-(void)twitterTapped:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitter-tapped-filevc" object:self];
    
    [self updateStateForButton:sender];
    
}

-(void)facebookTapped:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebook-tapped-filevc" object:self];
    
    [self updateStateForButton:sender];

}

-(void)anonTapped:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"anon-tapped-filevc" object:self];

    [self updateStateForButton:sender];
}


-(void)updateStateForButton:(UIButton *)button {
    
    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }
}

#pragma mark - Tips 
- (void)segueToTipsAction {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        FRSTipsViewController *tipsViewController = [[FRSTipsViewController alloc] init];
        [weakSelf.navigationController pushViewController:tipsViewController animated:YES];
    });
}

#pragma mark - NSNotification Center

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.fileSourcePickerTableView removeObserver:self forKeyPath:@"selectedSourceViewModel"];
    [self.fileSourcePickerTableView removeObserver:self forKeyPath:@"isExpanded"];

    [self.fileTagViewManager removeObserver:self forKeyPath:@"tagUpdated"];

}

-(void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"anon-tapped-uploadvc"     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"twitter-tapped-uploadvc"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:@"facebook-tapped-uploadvc" object:nil];
}


-(void)receiveNotifications:(NSNotification *)notification {
    
    NSString *notif = [notification name];
    
    if ([notif isEqualToString:@"twitter-tapped-uploadvc"]) {
        
        [self updateStateForButton:self.twitterButton];
        
    } else if ([notif isEqualToString:@"facebook-tapped-uploadvc"]) {
        
        [self updateStateForButton:self.facebookButton];
        
    } else if ([notif isEqualToString:@"anon-tapped-uploadvc"]) {
        
        [self updateStateForButton:self.anonButton];
    }
}

#pragma mark - FRSFileTagViewManagerDelegate

- (void)removeSelection {
    [self removeTappedAsset];
}

@end
