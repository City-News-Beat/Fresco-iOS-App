//
//  FRSUploadViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 5/3/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface FRSUploadViewController : FRSBaseViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (retain, nonatomic) UIButton *twitterButton;
@property (retain, nonatomic) UIButton *facebookButton;
@property (retain, nonatomic) UIButton *anonButton;
@property (retain, nonatomic) UILabel *anonLabel;

@end
