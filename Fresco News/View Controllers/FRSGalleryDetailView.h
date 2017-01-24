//
//  FRSGalleryDetailView.h
//  Fresco
//
//  Created by Arthur De Araujo on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGalleryView.h"
#import "FRSGalleryExpandedViewController.h"

@interface FRSGalleryDetailView : UIView <FRSGalleryViewDelegate>

@property (strong, nonatomic) FRSGallery *gallery;
@property NSString *defaultPostID;
@property int totalCommentCount;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@property (strong, nonatomic) IBOutlet FRSGalleryView *galleryView;
@property (nonatomic, retain) NSMutableArray *comments;
@property (strong, nonatomic) FRSGalleryExpandedViewController *parentVC;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) FRSContentActionsBar *actionBar;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UITableView *articlesTableView;

-(void)configureUI;
-(void)fetchCommentsWithID:(NSString*)galleryID;
-(void)sendComment;
-(void)loadGalleryDetailViewWithGallery:(FRSGallery *)gallery parentVC:(FRSGalleryExpandedViewController *)parentVC;
- (void)dismissKeyboard:(UITapGestureRecognizer *)tap;

@end
