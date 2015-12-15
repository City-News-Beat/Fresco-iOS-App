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
#import "PostCollectionViewCell.h"

@interface GalleryPostViewController () <UITextViewDelegate, UIAlertViewDelegate, FRSUploadManagerDelegate, UITableViewDataSource, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FRSBackButtonDelegate>

@property (strong, nonatomic) UITableView *assignmentTV;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UICollectionView *galleryCV;

@property (strong, nonatomic) FRSBackButton *backButton;



@end

@implementation GalleryPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeNavBar];
    [self configureUI];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark - UI Configuration

-(void)customizeNavBar {
    [self.navigationController.navigationBar setHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.backButton = [FRSBackButton createLightBackButtonWithTitle:@"Media"];
    [self.view addSubview:self.backButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 53, self.backButton.frame.origin.y, 53, self.backButton.frame.size.height)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
    cancelButton.layer.shadowColor = [UIColor frescoShadowColor].CGColor;
    cancelButton.layer.shadowOffset = CGSizeMake(1, 1);
    cancelButton.layer.shadowOpacity =  1.0;
    cancelButton.layer.shadowRadius = 1.0;
    
    [cancelButton addTarget:self action:@selector(handleCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
}

-(void)configureUI{
    self.view.backgroundColor = [UIColor whiteBackgroundColor];
    
    [self setupCollectionView];
}

#pragma mark - Collection View
-(void)setupCollectionView{
    
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLayout setItemSize:CGSizeMake(self.view.frame.size.width, [self heightForCollectionView])];
    [collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    collectionViewLayout.minimumInteritemSpacing = 0.0f;
    
    self.galleryCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForCollectionView]) collectionViewLayout:collectionViewLayout];
    [self.galleryCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.galleryCV.bounces = YES;
    self.galleryCV.showsHorizontalScrollIndicator = YES;
    self.galleryCV.dataSource = self;
    self.galleryCV.delegate = self;
    [self.view insertSubview:self.galleryCV belowSubview:self.backButton];
}

-(NSInteger)heightForCollectionView{
    if ([self.gallery.posts count]) {
        
        NSInteger height = 0;
        for (FRSPost *post in self.gallery.posts){
            height += [post.image.height integerValue];
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


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PostCollectionViewCell identifier] forIndexPath:indexPath];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
//    [cell setPost:[self.gallery.posts objectAtIndex:indexPath.item]];
    cell.backgroundColor = [UIColor redCircleStrokeColor];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return collectionView.bounds.size;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0.0f;
//}
//
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 0.0f;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    //If the cell has a video
//    if(cell.post.isVideo && cell.playingVideo){
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            //Check if the player is muted, then set it to play audio
//            if(self.sharedPlayer.muted){
//                
//                self.sharedPlayer.muted = NO;
//                
//                [UIView animateWithDuration:.5 animations:^{
//                    cell.mutedImage.alpha = 0.0f;
//                }];
//                
//            }
//            //Check if the player is playing
//            else if(self.sharedPlayer.rate > 0){
//                
//                [self.sharedPlayer pause];
//                cell.playPause.image = [UIImage imageNamed:@"pause"];
//                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
//                [cell bringSubviewToFront:cell.playPause];
//                
//                cell.playPause.alpha = 1.0f;
//                
//                [UIView animateWithDuration:.5 animations:^{
//                    cell.playPause.alpha = 0.0f;
//                    cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
//                }];
//                
//            }
//            //If it's not playing
//            else{
//                
//                [self.sharedPlayer play];
//                if(cell.mutedImage.alpha == 1.0f)
//                    cell.playPause.alpha = 0.0f;
//                cell.playPause.image = [UIImage imageNamed:@"play"];
//                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
//                [cell bringSubviewToFront:cell.playPause];
//                
//                cell.playPause.alpha = 1.0f;
//                
//                [UIView animateWithDuration:.5 animations:^{
//                    cell.playPause.alpha = 0.0f;
//                    cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
//                }];
//                
//            }
//            
//        });
//        
//    }
    //Post is a picture, not a video
//    else if(!cell.post.isVideo && [cell.post largeImageURL] != nil){
//        
//        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//        
//        FRSPhotoBrowserView *browserView = [[FRSPhotoBrowserView alloc] initWithFrame:[window bounds]];
//        [self setPhotoBrowserView:browserView];
//        
//        [[self photoBrowserView] setImages:@[cell.post.largeImageURL] withInitialIndex:0];
//        
//        [window addSubview:[self photoBrowserView]];
//        [[self photoBrowserView] setAlpha:0.f];
//        
//        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"messageSeen"]){
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"messageSeen"];
//            
//            UILabel *textLabelView = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, window.bounds.size.width * 0.8, 100)];
//            textLabelView.backgroundColor = [UIColor blackColor];
//            textLabelView.alpha = .7f;
//            textLabelView.layer.cornerRadius = 7;
//            textLabelView.layer.masksToBounds = YES;
//            
//            textLabelView.text = @"Try tilting your device to reveal more of the photo in full resolution";
//            textLabelView.textColor = [UIColor whiteColor];
//            textLabelView.textAlignment = NSTextAlignmentCenter;
//            textLabelView.numberOfLines = 0;
//            
//            textLabelView.font = [UIFont fontWithName:HELVETICA_NEUE_THIN size:18];
//            
//            double delayInSeconds = 3.0; // number of seconds to wait
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [UIView animateWithDuration:0.5
//                                      delay:1.0
//                                    options:UIViewAnimationOptionCurveEaseInOut
//                                 animations:^{
//                                     textLabelView.alpha = 0;
//                                 } completion:nil];
//            });
//            
//            [[self photoBrowserView] addSubview:textLabelView];
//        }
//        
//        CGAffineTransform transformation = CGAffineTransformMakeTranslation(0.f, kImageInitialYTranslation);
//        transformation = CGAffineTransformScale(transformation, kImageInitialScaleAmt, kImageInitialScaleAmt);
//        [[self photoBrowserView] setTransform:transformation];
//        
//        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewShouldDismiss:)];
//        [[self photoBrowserView] addGestureRecognizer:tapRecognizer];
//        
//        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewShouldDismiss:)];
//        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
//        [[self photoBrowserView] addGestureRecognizer:swipeRecognizer];
//        
//        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            [[self photoBrowserView] setAlpha:1.f];
//            [[self photoBrowserView] setTransform:CGAffineTransformIdentity];
//            [[UIApplication sharedApplication] setStatusBarHidden:YES];
//            
//        } completion:nil];
//        
//    }
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
