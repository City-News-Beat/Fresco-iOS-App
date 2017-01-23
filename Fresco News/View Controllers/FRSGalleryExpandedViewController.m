//
//  FRSGalleryExpandedViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryExpandedViewController.h"
<<<<<<< HEAD
#import "UITextView+Resize.h"
#import "FRSArticlesTableViewCell.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSGallery.h"
#import "FRSArticle.h"
#import "FRSGalleryView.h"
#import "FRSCommentsView.h"
#import "FRSContentActionsBar.h"
#import "FRSProfileViewController.h"
=======

#import "FRSGallery.h"
#import "FRSArticle.h"

>>>>>>> dev
#import "PeekPopArticleViewController.h"
#import "Haneke.h"
#import "Fresco.h"
#import "FRSAlertView.h"
<<<<<<< HEAD
#import "MGSwipeTableCell.h"
#import "FRSCommentCell.h"
#import "FRSDualUserListViewController.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"

#define TOP_NAV_BAR_HEIGHT 64
#define GALLERY_BOTTOM_PADDING 16
#define CELL_HEIGHT 62

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, FRSGalleryViewDelegate, UITableViewDataSource, UITableViewDelegate, FRSCommentsViewDelegate, FRSContentActionBarDelegate, UIViewControllerPreviewingDelegate, FRSAlertViewDelegate, MGSwipeTableCellDelegate, FRSCommentCellDelegate, UITextFieldDelegate, FRSGalleryViewDelegate>

@property (strong, nonatomic) FRSGalleryView *galleryView;
@property (strong, nonatomic) FRSCommentsView *commentsView;
@property (strong, nonatomic) FRSContentActionsBar *actionBar;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *commentLabel;

@property (strong, nonatomic) UILabel *articlesLabel;
@property (strong, nonatomic) UITableView *articlesTV;

@property (strong, nonatomic) NSArray *orderedArticles;
=======
#import "FRSGalleryDetailView.h"

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, FRSContentActionBarDelegate, UIViewControllerPreviewingDelegate, FRSAlertViewDelegate, UITextFieldDelegate>
>>>>>>> dev

@property (nonatomic) BOOL touchEnabled;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) FRSAlertView *galleryReportAlertView;
@property (strong, nonatomic) FRSAlertView *reportUserAlertView;
@property (strong, nonatomic) FRSAlertView *errorAlertView;

@property (strong, nonatomic) NSString *reportReasonString;
@property (strong, nonatomic) NSString *galleryID;

@property BOOL didDisplayReport;
@property BOOL didDisplayBlock;
@property BOOL didBlockUser;
@property BOOL isReportingComment;
@property BOOL isBlockingFromComment;

@property (strong, nonatomic) NSDictionary *currentCommentUserDictionary;

@end

@implementation FRSGalleryExpandedViewController {
    FRSGalleryDetailView *galleryDetailView;
}

static NSString *reusableCommentIdentifier = @"commentIdentifier";

- (instancetype)initWithGallery:(FRSGallery *)gallery {
    self = [super init];
    if (self) {
        self.gallery = gallery; //Remove after tested
        galleryDetailView.gallery = gallery;

        if (gallery.uid) {
            self.galleryID = gallery.uid;
        }
        self.hiddenTabBar = YES;
        self.actionBarVisible = YES;
        self.touchEnabled = NO;
        [galleryDetailView fetchCommentsWithID:gallery.uid];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureNavigationBar];
    [self configureNIBDetailView];

    [self.view updateConstraints];
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self register3DTouch];

    [FRSTracker screen:@"Gallery Detail"];

    dateEntered = [NSDate date];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.titleView = self.titleLabel;
    [self hideTabBarAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationItem.titleView = self.titleLabel;
    [self showTabBarAnimated:NO];

    [self trackSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureNIBDetailView {
    galleryDetailView = [[[NSBundle mainBundle] loadNibNamed:@"FRSGalleryDetailView" owner:self options:nil] objectAtIndex:0];
    [self.view addSubview:galleryDetailView];
    
    galleryDetailView.frame = self.view.frame;
    galleryDetailView.parentVC = self;
    
    [galleryDetailView loadGalleryDetailViewWithGallery:self.gallery parentVC:self];
    
    //NSLog(@"Gallery Object: \n%@", self.gallery.jsonObject);
}

- (void)configureNavigationBar {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"GALLERY";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont notaBoldWithSize:17];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = self.view.center;
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 0, self.titleLabel.frame.size.width, 44);

    self.navigationItem.titleView = self.titleLabel;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    UIBarButtonItem *dots = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dots"] style:UIBarButtonItemStylePlain target:self action:@selector(presentReportGallerySheet)];

    dots.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItems = @[ dots ];

    if ([[[self.gallery creator] uid] isEqualToString:[[FRSUserManager sharedInstance] authenticatedUser].uid]) {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (void)popViewController {
    [super popViewController];
    [self showTabBarAnimated:YES];
}

- (void)presentReportGallerySheet {

    NSString *username = @"user";

    if (self.gallery.creator.username) {
        username = self.gallery.creator.username;
    } else if (self.gallery.creator.firstName) {
        username = self.gallery.creator.firstName;
    } else if (self.gallery.byline) {
        username = self.gallery.byline;
    }

    UIAlertController *view = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *block = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Block %@", username]
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {

                                                    [self blockUser:self.gallery.creator];

                                                    [view dismissViewControllerAnimated:YES completion:nil];
                                                  }];

    UIAlertAction *unblock = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Unblock %@", username]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {

                                                      [self unblockUser:self.gallery.creator.uid];

                                                      [view dismissViewControllerAnimated:YES completion:nil];
                                                    }];

    UIAlertAction *reportGallery = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Report this gallery"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {

                                                            self.galleryReportAlertView = [[FRSAlertView alloc] initGalleryReportDelegate:self];
                                                            self.galleryReportAlertView.delegate = self;
                                                            [self.galleryReportAlertView show];

                                                            [view dismissViewControllerAnimated:YES completion:nil];
                                                          }];

    UIAlertAction *report = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Report %@", username]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {

                                                     self.reportUserAlertView = [[FRSAlertView alloc] initUserReportWithUsername:[NSString stringWithFormat:@"%@", username] delegate:self];
                                                     self.reportUserAlertView.delegate = self;
                                                     self.didDisplayReport = YES;
                                                     [self.reportUserAlertView show];

                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {

                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    [view addAction:reportGallery];

    if (![[[self.gallery creator] uid] isEqualToString:@""] && [self.gallery creator] != nil) {
        if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
            [view addAction:report];
        }
        if ([[[FRSUserManager sharedInstance] authenticatedUser] blocking] || self.didBlockUser) {
            if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
                [view addAction:unblock];
            }
        } else {
            if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
                [view addAction:block];
            }
        }
    }
    [view addAction:cancel];

    [self presentViewController:view animated:YES completion:nil];
}

- (void)presentFlagCommentSheet:(FRSComment *)comment {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    self.currentCommentUserDictionary = comment.userDictionary;

    NSLog(@"userDictionary: %@", comment.userDictionary);

    NSString *username;

    if (comment.userDictionary[@"username"] != [NSNull null] && (![comment.userDictionary[@"username"] isEqualToString:@"<null>"])) {
        username = [NSString stringWithFormat:@"@%@", comment.userDictionary[@"username"]];
    } else if (comment.userDictionary[@"full_name"] != [NSNull null] && (![comment.userDictionary[@"full_name"] isEqualToString:@"<null>"])) {
        username = comment.userDictionary[@"full_name"];
    } else {
        username = @"them";
    }

    UIAlertAction *block = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Block %@", username]
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {

                                                    [[FRSAPIClient sharedClient] blockUser:comment.userDictionary[@"id"]
                                                                            withCompletion:^(id responseObject, NSError *error) {

                                                                              if (responseObject) {
                                                                                  FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"BLOCKED" message:[NSString stringWithFormat:@"You won’t see posts from %@ anymore.", username] actionTitle:@"UNDO" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                                                                  self.didDisplayBlock = YES;
                                                                                  [alert show];
                                                                                  self.isBlockingFromComment = YES;

                                                                              } else {
                                                                                  [self presentGenericError];
                                                                              }
                                                                            }];

                                                    [view dismissViewControllerAnimated:YES completion:nil];
                                                  }];

    UIAlertAction *unblock = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Unblock %@", username]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {

                                                      [[FRSAPIClient sharedClient] unblockUser:comment.userDictionary[@"id"]
                                                                                withCompletion:^(id responseObject, NSError *error) {

                                                                                  if (responseObject) {

                                                                                  } else {
                                                                                      [self presentGenericError];
                                                                                  }
                                                                                }];

                                                      [view dismissViewControllerAnimated:YES completion:nil];
                                                    }];

    UIAlertAction *report = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Report %@", username]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {

                                                     self.isReportingComment = YES;
                                                     self.reportUserAlertView = [[FRSAlertView alloc] initUserReportWithUsername:[NSString stringWithFormat:@"%@", username] delegate:self];
                                                     self.reportUserAlertView.delegate = self;
                                                     self.didDisplayReport = YES;
                                                     [self.reportUserAlertView show];

                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {

                                                     [view dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    [view addAction:report];

    if (![comment.userDictionary[@"blocked"] boolValue]) {
        [view addAction:block];
    } else {
        [view addAction:unblock];
    }

    [view addAction:cancel];

    [self presentViewController:view animated:YES completion:nil];
}

<<<<<<< HEAD
- (void)configureUI {

    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self configureScrollView];
    [self configureGalleryView];
    [self configureArticles];
    [self configureActionBar];
    [self configureNavigationBar];
    [self adjustScrollViewContentSize];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)configureScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -TOP_NAV_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - 44)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)playerWillPlay:(FRSPlayer *)player {
}

- (void)configureGalleryView {
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, TOP_NAV_BAR_HEIGHT, self.view.frame.size.width, 500) gallery:self.gallery delegate:self];
    [self.scrollView addSubview:self.galleryView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard:)];

    [self.galleryView addGestureRecognizer:tap];
    [self.galleryView play];
    [self focus];

    //    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height)]];
}

- (void)configureArticles {

    if (self.orderedArticles.count == 0) {
        return;
    }

    if (self.orderedArticles.count > 0) {
        self.articlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height, self.view.frame.size.width, 48)];
        self.articlesLabel.text = @"ARTICLES";
        self.articlesLabel.textColor = [UIColor frescoMediumTextColor];
        self.articlesLabel.font = [UIFont notaBoldWithSize:15];
        [self.articlesLabel setOriginWithPoint:CGPointMake(16, self.galleryView.frame.origin.y + self.galleryView.frame.size.height + 6)];
        [self.scrollView addSubview:self.articlesLabel];
    }

    self.articlesTV = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height + self.articlesLabel.frame.size.height, self.view.frame.size.width, CELL_HEIGHT * self.orderedArticles.count)];
    self.articlesTV.delegate = self;
    self.articlesTV.dataSource = self;
    self.articlesTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.articlesTV.backgroundColor = [UIColor whiteColor];
    self.articlesTV.scrollEnabled = NO;
    self.articlesTV.hidden = self.orderedArticles.count == 0;
    [self.scrollView addSubview:self.articlesTV];

    if (self.orderedArticles.count > 0) {
        [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.articlesTV.frame.origin.y - 0.5)]];
    }
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    FRSComment *comment = [self.comments objectAtIndex:[self.commentTableView indexPathForCell:cell].row - showsMoreButton];

    if (comment.isDeletable && comment.isReportable) {
        if (index == 0) {
            [self deleteAtIndexPath:[self.commentTableView indexPathForCell:cell]];
        } else if (index == 1) {
            [self presentFlagCommentSheet:comment];
        }

    } else if (comment.isDeletable && !comment.isReportable) {
        if (index == 0) {
            [self deleteAtIndexPath:[self.commentTableView indexPathForCell:cell]];
        }

    } else if (!comment.isDeletable && comment.isReportable) {
        if (index == 0) {
            [self presentFlagCommentSheet:comment];
        }

    } else if (!comment.isDeletable && !comment.isReportable) {
        // will never get called
    }

    return YES;
}

- (void)deleteAtIndexPath:(NSIndexPath *)indexPath {
    FRSComment *comment = self.comments[indexPath.row - showsMoreButton];
    [[FRSAPIClient sharedClient] deleteComment:comment.uid
                                   fromGallery:self.gallery
                                    completion:^(id responseObject, NSError *error) {
                                      
                                      if (!error) {
                                          self.totalCommentCount--;
                                          [self reload];
                                      }
                                    }];
}

- (void)configureComments {
    float height = 0;
    NSInteger index = 0;

    for (FRSComment *comment in _comments) {

        CGRect labelRect = [comment.comment
            boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 78, INT_MAX) //78 is the padding on the left and right sides
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:15]
                      }
                         context:nil];

        float commentSize = labelRect.size.height;

        commentSize += 36; //36 is default padding

        if (commentSize < 56) {
            height += 56;
        } else {
            height += commentSize += 20;
        }
      
        index++;
    }

    CGFloat labelOriginY = self.galleryView.frame.origin.y + self.galleryView.frame.size.height;

    if (self.orderedArticles.count > 0) {
        labelOriginY += self.articlesTV.frame.size.height + self.articlesLabel.frame.size.height;
    }

    [self configureCommentLabel];

    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, labelOriginY + self.commentLabel.frame.size.height, self.view.frame.size.width, height)];
    self.commentTableView.clipsToBounds = NO;
    self.commentTableView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.backgroundColor = [UIColor whiteColor];
    self.commentTableView.scrollEnabled = NO;
    [self.scrollView addSubview:self.commentTableView];
    self.commentTableView.backgroundColor = [UIColor clearColor];
    self.commentTableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"FRSCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reusableCommentIdentifier];
    self.commentTableView.hidden = self.comments.count == 0;
    self.commentLabel.hidden = self.comments.count == 0;

    [self.commentTableView setSeparatorColor:[UIColor clearColor]];

    if (self.comments.count > 0) {
        [self.commentTableView addSubview:[UIView lineAtPoint:CGPointMake(0, 0)]];
    }

    [self adjustScrollViewContentSize];
    [self.actionBar actionButtonTitleNeedsUpdate];
}

- (void)configureCommentLabel {

    CGFloat labelOriginY = self.galleryView.frame.origin.y + self.galleryView.frame.size.height;

    if (self.orderedArticles.count > 0) {
        labelOriginY += self.articlesTV.frame.size.height + self.articlesLabel.frame.size.height;
    }

    if (self.commentLabel) {
        return;
    }
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelOriginY, self.view.frame.size.width, 48)];
    self.commentLabel.text = @"COMMENTS";
    self.commentLabel.textColor = [UIColor frescoMediumTextColor];
    self.commentLabel.font = [UIFont notaBoldWithSize:15];
    [self.commentLabel setOriginWithPoint:CGPointMake(16, labelOriginY + 6)];
    [self.scrollView addSubview:self.commentLabel];
}

- (void)configureActionBar {
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.view.frame.size.height - TOP_NAV_BAR_HEIGHT - 44) delegate:self];
    self.actionBar.delegate = self;

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor frescoShadowColor];
    [self.actionBar addSubview:line];

    NSNumber *numLikes = [self.gallery valueForKey:@"likes"];
    BOOL isLiked = [[self.gallery valueForKey:@"liked"] boolValue];

    NSNumber *numReposts = [self.gallery valueForKey:@"reposts"];
    BOOL isReposted = ![[self.gallery valueForKey:@"reposted"] boolValue];

    // NSString *repostedBy = [self.gallery valueForKey:@"repostedBy"];

    [self.actionBar handleRepostState:isReposted];
    [self.actionBar handleRepostAmount:[numReposts intValue]];
    [self.actionBar handleHeartState:isLiked];
    [self.actionBar handleHeartAmount:[numLikes intValue]];

    [self.view addSubview:self.actionBar];

    if ([self.gallery.creator.uid isEqualToString:[[FRSUserManager sharedInstance] authenticatedUser].uid]) {
        [self.actionBar setCurrentUser:YES];
    } else {
        [self.actionBar setCurrentUser:NO];
    }
}
=======
#pragma mark - Action Bar Button Actions
>>>>>>> dev

- (void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    FRSPost *post = [[self.gallery.posts allObjects] firstObject];
    NSString *sharedContent = [@"https://fresconews.com/gallery/" stringByAppendingString:self.gallery.uid];

    sharedContent = [NSString stringWithFormat:@"Check out this gallery from %@: %@", [[post.address componentsSeparatedByString:@","] firstObject], sharedContent];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ sharedContent ] applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];

    [FRSTracker track:sharedFromHighlights parameters:@{ @"gallery_id" : (self.gallery.uid != Nil) ? self.gallery.uid : @"" }];
}

- (void)handleLike:(FRSContentActionsBar *)actionBar {
    NSInteger likes = [[self.gallery valueForKey:@"likes"] integerValue];

    if ([[self.gallery valueForKey:@"liked"] boolValue]) {
        [[FRSAPIClient sharedClient] unlikeGallery:self.gallery
                                        completion:^(id responseObject, NSError *error) {
                                          NSLog(@"UNLIKED %@", (!error) ? @"TRUE" : @"FALSE");
                                          if (error) {
                                              [actionBar handleHeartState:TRUE];
                                              [actionBar handleHeartAmount:likes];
                                          }
                                        }];

    } else {
        [[FRSAPIClient sharedClient] likeGallery:self.gallery
                                      completion:^(id responseObject, NSError *error) {
                                        NSLog(@"LIKED %@", (!error) ? @"TRUE" : @"FALSE");
                                        if (error) {
                                            [actionBar handleHeartState:FALSE];
                                            [actionBar handleHeartAmount:likes];
                                        }
                                      }];
    }
}

- (void)handleRepost:(FRSContentActionsBar *)actionBar {
    BOOL state = [[self.gallery valueForKey:@"reposted"] boolValue];
    NSInteger repostCount = [[self.gallery valueForKey:@"reposts"] boolValue];

    [[FRSAPIClient sharedClient] repostGallery:self.gallery
                                    completion:^(id responseObject, NSError *error) {
                                      NSLog(@"REPOSTED %@", error);

                                      if (error) {
                                          [actionBar handleRepostState:!state];
                                          [actionBar handleRepostAmount:repostCount];
                                      }
                                    }];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == galleryDetailView.scrollView) {
        [super scrollViewDidScroll:scrollView];
        [galleryDetailView.actionBar actionButtonTitleNeedsUpdate];
    }

    if (scrollView == galleryDetailView.scrollView) {
        float size = galleryDetailView.scrollView.contentSize.height;
        float offset = galleryDetailView.scrollView.contentOffset.y;

        float percentage = offset / size;

        if (percentageScrolled < percentage) {
            percentageScrolled = percentage;
        }
    }
}

#pragma mark - 3D Touch

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self register3DTouch];
}

- (void)register3DTouch {
    if ((self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) && (self.touchEnabled == NO)) {
        self.touchEnabled = YES;
        [self registerForPreviewingWithDelegate:self sourceView:galleryDetailView.articlesTableView];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {

    CGPoint cellPostion = [galleryDetailView.articlesTableView convertPoint:location fromView:galleryDetailView.articlesTableView];
    NSIndexPath *path = [galleryDetailView.articlesTableView indexPathForRowAtPoint:cellPostion];
    [previewingContext setSourceRect:[galleryDetailView.articlesTableView rectForRowAtIndexPath:path]];

    PeekPopArticleViewController *vc = [[PeekPopArticleViewController alloc] init];
    UIView *contentView = vc.view;

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    [contentView addSubview:webView];
    FRSArticle *article = [self.gallery.articles allObjects][path.row];
    NSString *urlString = article.articleStringURL;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    vc.title = urlString;

    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {

    NSURL *url = [NSURL URLWithString:viewControllerToCommit.title];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [FRSTracker track:articleOpens parameters:@{ @"article_url" : viewControllerToCommit.title }];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - FRSAlertViewDelegate

- (void)reportGalleryAlertAction {
    [[FRSAPIClient sharedClient] reportGallery:self.gallery
        params:@{ @"reason" : self.reportReasonString,
                  @"message" : self.galleryReportAlertView.textView.text }
        completion:^(id responseObject, NSError *error) {

          if (error) {
              [self presentGenericError];
              return;
          }

          if (responseObject) {
              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"REPORT SENT" message:@"Thanks for helping make Fresco a better community!" actionTitle:@"YOU’RE WELCOME" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
              [alert show];
          }
        }];
}

- (void)reportUserAlertAction {

    NSString *username = @"";

    if ([self.gallery.creator.username class] != [NSNull null] && (![self.gallery.creator.username isEqualToString:@"<null>"])) {
        username = [NSString stringWithFormat:@"@%@", self.gallery.creator.username];
    } else if (self.currentCommentUserDictionary[@"full_name"] != [NSNull null] && (![self.gallery.creator.firstName isEqualToString:@"<null>"])) {
        username = self.gallery.creator.firstName;
    } else {
        username = @"them";
    }

    if (self.isReportingComment) {
        [self reportUser:self.currentCommentUserDictionary[@"id"]];
    } else {
        [self reportUser:self.gallery.creator.uid];
    }
}

- (void)didPressRadioButtonAtIndex:(NSInteger)index {

    if (self.reportUserAlertView || self.galleryReportAlertView) {
        switch (index) {
        case 0:
            self.reportReasonString = @"abuse";
            break;
        case 1:
            self.reportReasonString = @"spam";
            break;
        case 2:
            self.reportReasonString = @"stolen";
            break;
        case 3:
            self.reportReasonString = @"nsfw";
            break;
        default:
            break;
        }
    }
}

- (void)didPressButtonAtIndex:(NSInteger)index {

    if (self.didDisplayReport) {
        self.didDisplayReport = NO;
        self.reportUserAlertView = nil;
        if (index == 1) {

            NSString *username = @"";

            if (self.isReportingComment) {
                if (self.currentCommentUserDictionary[@"username"] != [NSNull null] && (![self.currentCommentUserDictionary[@"username"] isEqualToString:@"<null>"])) {
                    username = [NSString stringWithFormat:@"@%@", self.currentCommentUserDictionary[@"username"]];
                } else if (self.currentCommentUserDictionary[@"full_name"] != [NSNull null] && (![self.currentCommentUserDictionary[@"full_name"] isEqualToString:@"<null>"])) {
                    username = self.currentCommentUserDictionary[@"full_name"];
                } else {
                    username = @"them";
                }
            } else {
                if ([self.gallery.creator.username class] != [NSNull null] && (![self.gallery.creator.username isEqualToString:@"<null>"])) {
                    username = [NSString stringWithFormat:@"@%@", self.gallery.creator.username];
                } else if ([self.gallery.creator.firstName class] != [NSNull null] && (![self.gallery.creator.firstName isEqualToString:@"<null>"])) {
                    username = self.gallery.creator.firstName;
                } else {
                    username = @"them";
                }
            }

            FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"BLOCKED" message:[NSString stringWithFormat:@"You won’t see posts from %@ anymore.", username] actionTitle:@"UNDO" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
            self.isReportingComment = NO;
            [alert show];
        }
    } else if (self.didDisplayBlock) {
        self.didDisplayBlock = NO;

        if (index == 0) {

            if (self.isBlockingFromComment) {
                [self unblockUser:self.currentCommentUserDictionary[@"id"]];
            } else {
                [self unblockUser:self.gallery.creator.uid];
            }
        }
    } else if (self.errorAlertView) {
        if (index == 0) {
            [galleryDetailView.commentTextField resignFirstResponder];
            [galleryDetailView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        } else if (index == 1) {
            [galleryDetailView sendComment];
        }
    }
}

#pragma mark - Moderation

- (void)blockUser:(FRSUser *)user {

    [[FRSAPIClient sharedClient] blockUser:user.uid
                            withCompletion:^(id responseObject, NSError *error) {

                              if (responseObject) {
                                  FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"BLOCKED" message:[NSString stringWithFormat:@"You won’t see posts from %@ anymore.", user.username] actionTitle:@"UNDO" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                  self.didDisplayBlock = YES;
                                  [alert show];
                                  self.didBlockUser = YES;
                                  self.isBlockingFromComment = NO;

                              } else {
                                  [self presentGenericError];
                              }
                            }];
}

- (void)unblockUser:(NSString *)userID {
    [[FRSAPIClient sharedClient] unblockUser:userID
                              withCompletion:^(id responseObject, NSError *error) {

                                if (responseObject) {
                                    self.didBlockUser = NO;
                                }

                                if (error) {
                                    [self presentGenericError];
                                }
                              }];
}

- (void)reportUser:(NSString *)userID {

    [[FRSAPIClient sharedClient] reportUser:userID
        params:@{ @"reason" : self.reportReasonString,
                  @"message" : self.reportUserAlertView.textView.text }
        completion:^(id responseObject, NSError *error) {

          if (error) {
              [self presentGenericError];
              return;
          }

          if (responseObject) {

              NSString *username = @"";

              if (self.isReportingComment) {

                  if (self.currentCommentUserDictionary[@"username"] != [NSNull null] && (![self.currentCommentUserDictionary[@"username"] isEqualToString:@"<null>"])) {
                      username = [NSString stringWithFormat:@"@%@", self.currentCommentUserDictionary[@"username"]];
                  } else if (self.currentCommentUserDictionary[@"full_name"] != [NSNull null] && (![self.currentCommentUserDictionary[@"full_name"] isEqualToString:@"<null>"])) {
                      username = self.currentCommentUserDictionary[@"full_name"];
                  } else {
                      username = @"them";
                  }
              } else {

                  if ([self.gallery.creator.username class] != [NSNull null] && (![self.gallery.creator.username isEqualToString:@"<null>"])) {
                      username = [NSString stringWithFormat:@"@%@", self.gallery.creator.username];
                  } else if ([self.gallery.creator.firstName class] != [NSNull null] && (![self.gallery.creator.firstName isEqualToString:@"<null>"])) {
                      username = self.gallery.creator.firstName;
                  } else {
                      username = @"them";
                  }
              }

              FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"REPORT SENT" message:[NSString stringWithFormat:@"Thanks for helping make Fresco a better community! Would you like to block %@ as well?", username] actionTitle:@"CLOSE" cancelTitle:@"BLOCK USER" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
              [alert show];
          }
        }];
}
/*
-(void)loadGallery:(FRSGallery *)gallery {//Might be useless
    self.gallery = gallery;//Remove when tested
    galleryDetailView.gallery = gallery;
    
    if (gallery.uid) {
        self.galleryID = gallery.uid;
    }
    self.hiddenTabBar = YES;
    self.actionBarVisible = YES;
    self.touchEnabled = NO;
    //[self.galleryView loadGallery:gallery];//Remove when tested
    [galleryDetailView.galleryView loadGallery:gallery];
    [galleryDetailView fetchCommentsWithID:gallery.uid];
}
*/
- (void)trackSession {
    NSTimeInterval timeInSession = -1 * [dateEntered timeIntervalSinceNow];
    NSString *galleryID = self.gallery.uid;
    NSString *authorID = self.gallery.creator.uid;

    if (!galleryID || [galleryID isEqual:[NSNull null]] || ![[galleryID class] isSubclassOfClass:[NSString class]]) {
        galleryID = @"";
    }

    if (!authorID || [authorID isEqual:[NSNull null]] || ![[authorID class] isSubclassOfClass:[NSString class]]) {
        authorID = @"";
    }

    if (!_openedFrom || [_openedFrom isEqual:[NSNull null]] || ![[_openedFrom class] isSubclassOfClass:[NSString class]]) {
        _openedFrom = @"";
    }

    NSDictionary *session = @{
        @"activity_duration" : @(timeInSession),
        @"gallery_id" : galleryID,
        @"scrolled_percent" : @(percentageScrolled * 100),
        @"author" : authorID,
        @"opened_from" : _openedFrom
    };

    [FRSTracker track:gallerySession parameters:session];
}

@end
