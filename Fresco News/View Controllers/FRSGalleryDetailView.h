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

@protocol FRSGalleryDetailViewDelegate <NSObject>
@end

@interface FRSGalleryDetailView : UIView <FRSGalleryViewDelegate>

@property (weak, nonatomic) NSObject<FRSGalleryDetailViewDelegate> *delegate;

@property (strong, nonatomic) FRSGallery *gallery;
@property (weak, nonatomic) UINavigationController *navigationController;
@property NSString *defaultPostID;
@property int totalCommentCount;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@property (strong, nonatomic) IBOutlet FRSGalleryView *galleryView;
@property (nonatomic, retain) NSMutableArray *comments;
@property (strong, nonatomic) FRSGalleryExpandedViewController *parentVC;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (strong, nonatomic) FRSActionBar *actionBar;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UITableView *articlesTableView;
@property (strong, nonatomic) ShareSheetBlock shareBlock;

-(void)configureUI;
-(void)fetchCommentsWithID:(NSString*)galleryID;
-(void)sendComment;
-(void)loadGalleryDetailViewWithGallery:(FRSGallery *)gallery parentVC:(FRSGalleryExpandedViewController *)parentVC;
- (void)dismissKeyboard:(UITapGestureRecognizer *)tap;

@end
