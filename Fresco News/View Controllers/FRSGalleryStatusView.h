//
//  FRSGalleryStatusView.h
//  Fresco
//
//  Created by Arthur De Araujo on 1/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGalleryExpandedViewController.h"
#import "FRSGalleryDetailView.h"

@interface FRSGalleryStatusView : UIView

@property (strong, nonatomic) FRSGalleryExpandedViewController *parentVC;
@property (strong, nonatomic) FRSGalleryDetailView *parentView;

-(void)configureWithArray:(NSArray *)postPurchases rating:(int)rating;
- (void)removeLoadingSpinner;

@end
