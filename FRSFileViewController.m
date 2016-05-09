//
//  FRSFileViewController.m
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import "FRSFileViewController.h"
#import "VideoTrimmerViewController.h"
#import "FRSUploadViewController.h"
#import "UIFont+Fresco.h"

@interface FRSFileViewController ()
@property CMTime currentTime;
@property (strong, nonatomic) UIButton *backTapButton;
@end

@implementation FRSFileViewController

// NOTE last cell in collection view must be the "last 24 hour" prompt
static NSString *imageTile = @"ImageTile";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    selectedAssets = [[NSMutableArray alloc] init];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont notaBoldWithSize:18]}]; // why'd you send me a font w this name

    self.automaticallyAdjustsScrollViewInsets = NO; // keeps collection view from misbehaving
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
    
    self.backTapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [self.backTapButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backTapButton];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

}

-(void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    //Checks if going back to camera
    if ([viewControllers indexOfObject:self] == NSNotFound) {
        [self.backTapButton removeFromSuperview];
    }
}

-(void)setupSecondaryUI {
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, fileCollectionView.frame.origin.y + fileCollectionView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 1)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.view addSubview:line];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [nextButton setTintColor:[UIColor frescoLightTextColor]];
    nextButton.frame = CGRectMake(screenWidth-64, [UIScreen mainScreen].bounds.size.height-41, 60, 40);
    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    nextButton.userInteractionEnabled = NO;
    [self.view addSubview:nextButton];
    
    self.twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.twitterButton addTarget:self action:@selector(twitterTapped:) forControlEvents:UIControlEventTouchDown];
    self.twitterButton.frame = CGRectMake(16, self.view.frame.size.height -24 -10, 24, 24);
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter-icon"] forState:UIControlStateNormal];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter-icon-filled"] forState:UIControlStateSelected];
    [self.view addSubview:self.twitterButton];
    
    self.facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookButton addTarget:self action:@selector(facebookTapped:) forControlEvents:UIControlEventTouchDown];
    self.facebookButton.frame = CGRectMake(56, self.view.frame.size.height -24 -10, 24, 24);
    [self.facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [self.facebookButton setImage:[UIImage imageNamed:@"facebook-icon-filled"] forState:UIControlStateSelected];
    [self.view addSubview:self.facebookButton];
    
    self.anonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.anonButton addTarget:self action:@selector(anonTapped:) forControlEvents:UIControlEventTouchDown];
    UIImage *eye = [UIImage imageNamed:@"eye-26"];
    [self.anonButton setImage:eye forState:UIControlStateNormal];
    self.anonButton.frame = CGRectMake(96, self.view.frame.size.height -24 -10, 24, 24);
    [self.view addSubview:self.anonButton];
    
    self.anonLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, self.view.frame.size.height -17 -12, 83, 17)];
    self.anonLabel.text = @"ANONYMOUS";
    self.anonLabel.font = [UIFont notaBoldWithSize:15];
    self.anonLabel.textColor = [UIColor frescoOrangeColor];
    self.anonLabel.alpha = 0;
    [self.view addSubview:self.anonLabel];
    
}

-(void)setupCollectionView {
    // Do any additional setup after loading the view.
    UINib *imageNib = [UINib nibWithNibName:@"FRSImageViewCell" bundle:[NSBundle mainBundle]]; // used a xib for cell b/c originally I was going to have separate cells for video and image.
    UINib *footerNib = [UINib nibWithNibName:@"FRSFileFooterCell" bundle:[NSBundle mainBundle]];
    
    fileLoader = [[FRSFileLoader alloc] initWithDelegate:self]; // single instance of class which manages requesting file info to populate UI
    
    // layout for collection view (3 across, 1px spacing, like in sketch)
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellSize = screenWidth/3.0 - 1;
    
    UICollectionViewFlowLayout *fileLayout = [[UICollectionViewFlowLayout alloc] init];
    fileLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    fileLayout.itemSize = CGSizeMake(cellSize, cellSize);
    fileLayout.minimumInteritemSpacing = 1;
    fileLayout.minimumLineSpacing = 1;
    fileLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // actual collection view
    fileCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) collectionViewLayout:fileLayout];
    [fileCollectionView registerNib:imageNib forCellWithReuseIdentifier:imageTile];
    [fileCollectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter];
    [self.view addSubview:fileCollectionView];
    fileCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // constraints on collection view (did collection view manually b/c changing layout after instantiation (i.e from a nib, the spacing can get really messed up.)
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:64];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:fileCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-44];
    
    [self.view addConstraints:@[top, left, bottom, right]];
    [self.view layoutIfNeeded];
    
    fileCollectionView.delegate = self;
    fileCollectionView.dataSource = self;

    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    fileCollectionView.backgroundColor = [UIColor frescoBackgroundColorLight];

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self shouldShowStatusBar:YES animated:YES];
    
//    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    //Navigation bar color is not Fresco Yellow. Not sure where it's set
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

-(void)next:(id)sender {
    FRSUploadViewController *uploadViewController = [[FRSUploadViewController alloc] init];
    [self.navigationController pushViewController:uploadViewController animated:YES];
}

/* Footer Related */

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int numberOfAssets = (int)[fileLoader numberOfAssets];
    int currentAsset = (int)indexPath.row;
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float cellSize = screenWidth/3.0 - 1;

    if (currentAsset == numberOfAssets) {
        // show footer
        return  CGSizeMake(screenWidth, 175);
    }
    
    return CGSizeMake(cellSize, cellSize);
}

/* Not Footer Related */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// match yellow
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [fileLoader numberOfAssets];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    return  CGSizeMake(screenWidth, 175);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

    if (kind == UICollectionElementKindSectionFooter){
        MissingSomethingCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter forIndexPath:indexPath];
        
        [footer setup];
        
        return footer;
    }
    
    return Nil;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *representedAsset = [fileLoader assetAtIndex:indexPath.row]; // pulls asset from array
    
    // dequeues cell, as we've registered a nib we will always get a non-nil value
    FRSImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageTile forIndexPath:indexPath];
    cell.fileLoader = fileLoader; // gives the cell our (weakly stored) instance of our file loader
    [cell loadAsset:representedAsset]; // gives instruction to update UI
    
    if ([selectedAssets containsObject:representedAsset]) {
        [cell selected:TRUE];
        //if video and if > 60 seconds
    }
    else {
        [cell selected:FALSE];
    }

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *representedAsset = [fileLoader assetAtIndex:indexPath.row]; // pulls asset from array
    FRSImageViewCell *cell = (FRSImageViewCell *)[fileCollectionView cellForItemAtIndexPath:indexPath];

    if ([selectedAssets containsObject:representedAsset]) {
        [selectedAssets removeObject:representedAsset];
        [cell selected:FALSE];
        [nextButton.titleLabel setTextColor:[UIColor frescoLightTextColor]];
        nextButton.userInteractionEnabled = NO;
    }
    else {
        if (cell.currentAVAsset) {
            self.currentTime = cell.currentAVAsset.duration;
            [self presentVideoTrimmerViewController];
        }
        [selectedAssets addObject:representedAsset];
        [cell selected:TRUE];
        [nextButton.titleLabel setTextColor:[UIColor frescoBlueColor]];
        nextButton.userInteractionEnabled = YES;
    }
}

-(void)applicationNotAuthorized {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Camera Roll" message:@"Sadly, you chose not to let us see your photos. To use the app, go to settings, privacy, and allow Phresco to see what's poppin'!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

-(void)presentVideoTrimmerViewController {
    
//    VideoTrimmerViewController *vc = [VideoTrimmerViewController new];
//    [self presentViewController:vc animated:YES completion:nil];
//    
//    [self shouldShowStatusBar:NO animated:YES];
}

-(void)filesLoaded {
    NSLog(@"permission granted");
    
    if ([fileLoader numberOfAssets] == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [fileCollectionView reloadData];
    });
}


#pragma mark - Bottom Bar Buttons

-(void)twitterTapped:(UIButton *)sender {
    
    if (sender.selected) {
        sender.selected = NO;
    } else {
        sender.selected = YES;
    }
}

-(void)facebookTapped:(UIButton *)sender {
    
    if (sender.selected) {
        sender.selected = NO;
    } else {
        sender.selected = YES;
    }
}

-(void)anonTapped:(UIButton *)sender {

    if (sender.selected) {
        sender.selected = NO;
    } else {
        self.anonLabel.alpha = 1;
        sender.selected = YES;
    }
}













@end
