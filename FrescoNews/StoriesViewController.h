//
//  StoriesViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError* error);

@class FRSTag;

@interface StoriesViewController : FRSBaseViewController
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) FRSTag *tag;

@end

