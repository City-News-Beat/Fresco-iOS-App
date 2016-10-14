//
//  FRSIdentityViewController.h
//  Fresco
//
//  Created by Philip Bernstein on 8/16/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"

@interface FRSIdentityViewController : FRSBaseViewController <UITextFieldDelegate>
@property (nonatomic, strong) DGElasticPullToRefreshLoadingViewCircle *loadingView;
@end
