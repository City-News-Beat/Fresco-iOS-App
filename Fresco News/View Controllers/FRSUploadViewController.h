//
//  FRSUploadViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 5/3/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface FRSUploadViewController : FRSBaseViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) UIButton *twitterButton;
@property (strong, nonatomic) UIButton *facebookButton;
@property (strong, nonatomic) UIButton *anonButton;
@property (strong, nonatomic) UILabel *anonLabel;

@end
