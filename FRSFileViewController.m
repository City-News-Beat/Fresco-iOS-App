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

static NSInteger const maxAssets = 8;

@interface FRSFileViewController ()
@property (strong, nonatomic) UIButton *backTapButton;
@property (strong, nonatomic) FRSUploadViewController *uploadViewController;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@end

@implementation FRSFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    selectedAssets = [[NSMutableArray alloc] init];
    self.selectedIndexPaths = [[NSMutableArray alloc] initWithCapacity:0];

    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                    NSFontAttributeName : [UIFont notaBoldWithSize:18] }];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupCollectionView];
    [self setupSecondaryUI];

    self.navigationItem.title = @"CHOOSE MEDIA";

    UIImage *backButtonImage = [UIImage imageNamed:@"back-arrow-light"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [container addSubview:backButton];

    backButton.tintColor = [UIColor whiteColor];
    backButton.frame = CGRectMake(-3, 0, 24, 24);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:container];

    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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

    fileLoader = [[FRSFileLoader alloc] initWithDelegate:self]; // single instance of class which manages requesting file info to populate UI

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
    int numberOfAssets = (int)[fileLoader numberOfAssets];
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
    return [fileLoader numberOfAssets];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(screenWidth, 225);
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

    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *representedAsset = [fileLoader assetAtIndex:indexPath.row]; // pulls asset from array

    // dequeues cell, as we've registered a nib we will always get a non-nil value
    FRSImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
    cell.fileLoader = fileLoader; // gives the cell our (weakly stored) instance of our file loader
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
    PHAsset *representedAsset = [fileLoader assetAtIndex:indexPath.row]; // pulls asset from array

    if ([selectedAssets containsObject:representedAsset]) {
        [selectedAssets removeObject:representedAsset];
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
    if (![self.selectedIndexPaths containsObject:indexPath]) {
        [self.selectedIndexPaths addObject:indexPath];
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

- (void)filesLoaded {
    if ([fileLoader numberOfAssets] == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [fileCollectionView reloadData];
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


#pragma mark - NSNotification Center

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


@end
