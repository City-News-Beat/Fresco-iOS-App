//
//  FRSGalleryStatusView.h
//  Fresco
//
//  Created by Arthur De Araujo on 1/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGalleryExpandedViewController.h"

@interface FRSGalleryStatusView : UIView

@property (strong, nonatomic) FRSGalleryExpandedViewController *parentVC;

-(void)configureWithArray:(NSArray *)postPurchases rating:(int)rating;

@end
