//
//  FRSGalleryExpandedViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSComment.h"

@class FRSGallery;

@interface FRSGalleryExpandedViewController : FRSBaseViewController <UITextViewDelegate> {
    NSDate *dateEntered;
    float percentageScrolled;
}

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) NSString *openedFrom;

- (instancetype)initWithGallery:(FRSGallery *)gallery;
- (void)presentFlagCommentSheet:(FRSComment *)comment;

@end
