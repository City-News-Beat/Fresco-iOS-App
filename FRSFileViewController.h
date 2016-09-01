//
//  FRSFileViewController.h
//  fresco
//
//  Created by Philip Bernstein on 2/27/16.
//  Copyright © 2016 Philip Bernstein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSFileLoader.h"
#import "FRSImageViewCell.h"
#import "FRSScrollingViewController.h"
#import "MissingSomethingCollectionReusableView.h"
/*
 Image / Video file picker, lets user choose what to upload. No limit on selection. Spent a lot of time getting scrolling very smooth, Photos Library offers good support for async asset loading
 
    Used footer from spec, which is just a supplemental view.
    Ideally footer would normally be a reusable supplemental view, but already had the nib made, doesn't break any rules or affect efficiency
 */


@interface FRSFileViewController : FRSBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FRSFileLoaderDelegate>
{
    FRSFileLoader *fileLoader;
    UICollectionView *fileCollectionView;
    
    // fit spec
    UIView *line;
    
    // select / deselect
    NSMutableArray *selectedAssets;
    NSMutableDictionary *cellHash;
    
    UIButton *nextButton;
}


@property (strong, nonatomic) UIButton *twitterButton;
@property (strong, nonatomic) UIButton *facebookButton;
@property (strong, nonatomic) UIButton *anonButton;
@property (strong, nonatomic) UILabel *anonLabel;
@property (strong, nonatomic) NSDictionary *preselectedGlobalAssignment;
@property (strong, nonatomic) NSDictionary *preselectedAssignment;



@end
