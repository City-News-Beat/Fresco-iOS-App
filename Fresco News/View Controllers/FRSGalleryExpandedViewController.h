//
//  FRSGalleryExpandedViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
@class FRSGallery;

@interface FRSGalleryExpandedViewController : FRSScrollingViewController <UITextViewDelegate>
{
    UITextField *commentField;
    NSString *last;
    UIButton *topButton;
    BOOL showsMoreButton;
    NSDate *dateEntered;
    float percentageScrolled;
}

@property BOOL isLoadingUser;
@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) NSString *openedFrom;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

-(void)focusOnPost:(NSString *)postID;
-(instancetype)initWithGallery:(FRSGallery *)gallery;
-(void)loadGallery:(FRSGallery *)gallery;
@end
