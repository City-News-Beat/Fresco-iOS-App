//
//  FRSGalleryExpandedViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryExpandedViewController.h"
#import "UITextView+Resize.h"
#import "FRSArticlesTableViewCell.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"

#import "FRSGallery.h"
#import "FRSArticle.h"

#import "FRSGalleryView.h"
#import "FRSCommentsView.h"
#import "FRSContentActionsBar.h"
#import "FRSProfileViewController.h"
#import "PeekPopArticleViewController.h"
#import "FRSComment.h"
#import "Haneke.h"
#import "Fresco.h"
#import "FRSSearchViewController.h"
#import "FRSOnboardingViewController.h"
#import "FRSAlertView.h"

#import "MGSwipeTableCell.h"
#import "FRSCommentCell.h"

#define TOP_NAV_BAR_HEIGHT 64
#define GALLERY_BOTTOM_PADDING 16
#define CELL_HEIGHT 62

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, FRSGalleryViewDelegate, UITableViewDataSource, UITableViewDelegate, FRSCommentsViewDelegate, FRSContentActionBarDelegate, UIViewControllerPreviewingDelegate, FRSAlertViewDelegate, MGSwipeTableCellDelegate, FRSCommentCellDelegate, UITextFieldDelegate>

@property (strong, nonatomic) FRSGalleryView *galleryView;
@property (strong, nonatomic) FRSCommentsView *commentsView;
@property (strong, nonatomic) FRSContentActionsBar *actionBar;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *commentLabel;

@property (strong, nonatomic) UILabel *articlesLabel;
@property (strong, nonatomic) UITableView *articlesTV;

@property (strong, nonatomic) NSArray *orderedArticles;

@property (nonatomic) BOOL touchEnabled;

@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) UITableView *commentTableView;

@property (strong, nonatomic) FRSAlertView *galleryReportAlertView;
@property (strong, nonatomic) FRSAlertView *reportUserAlertView;

@property (strong, nonatomic) NSString *reportReasonString;

@property (strong, nonatomic) FRSAlertView *errorAlertView;
@property (strong, nonatomic) NSString *galleryID;
@property int totalCommentCount;

@property BOOL didDisplayReport;
@property BOOL didDisplayBlock;
@property BOOL didPrepareForReply;
@property BOOL didBlockUser;
@property BOOL isReportingComment;
@property BOOL isBlockingFromComment;
@property NSString *defaultPostID;

@property (strong, nonatomic) NSDictionary *currentCommentUserDictionary;
@property BOOL didChangeUp;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@end

@implementation FRSGalleryExpandedViewController

static NSString *reusableCommentIdentifier = @"commentIdentifier";

- (void)focusOnPost:(NSString *)postID {
    self.defaultPostID = postID;
}

- (instancetype)initWithGallery:(FRSGallery *)gallery {
    self = [super init];
    if (self) {
        self.gallery = gallery;

        if (gallery.uid) {
            self.galleryID = gallery.uid;
        }

        self.orderedArticles = [self.gallery.articles allObjects];
        self.hiddenTabBar = YES;
        self.actionBarVisible = YES;
        self.touchEnabled = NO;
        [self fetchCommentsWithID:gallery.uid];
    }
    return self;
}

- (instancetype)initWithGallery:(FRSGallery *)gallery comment:(NSString *)commentID {
    self = [super init];
    if (self) {
        self.gallery = gallery;
        //        self.orderedArticles = [self.gallery.articles allObjects];
        self.hiddenTabBar = YES;
        self.actionBarVisible = YES;
        self.touchEnabled = NO;
        //[self fetchCommentsWithID:gallery.uid];
        [self setupDeepLinkedComment:commentID];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureUI];
    self.totalCommentCount = [[self.gallery valueForKey:@"comments"] intValue];

    if ([self.gallery.comments integerValue] >= 1) {
        [self configureCommentLabel];
        [self configureSpinner];
    }
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

- (void)setupDeepLinkedComment:(NSString *)commentID {
    NSString *format = @"gallery/%@/comments?last=%@&dir=disc";
    NSString *endpoint = [NSString stringWithFormat:format, self.gallery.uid, commentID];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            if (error || !responseObject) {
                                [self commentError:error];
                                return;
                            }

                            _comments = [[NSMutableArray alloc] init];
                            NSArray *response = (NSArray *)responseObject;
                            for (NSInteger i = response.count - 1; i >= 0; i--) {
                                FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
                                [_comments addObject:commentObject];
                            }

                            if ([_comments count] <= 10) {
                                showsMoreButton = FALSE;
                            } else {
                                showsMoreButton = TRUE;
                            }

                            [self configureComments];
                          }];
}

- (void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] initWithFrame:CGRectMake(82, 13, 20, 20)];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [self.commentLabel addSubview:self.loadingView];
}

- (void)fetchCommentsWithID:(NSString *)galleryID {

    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:galleryID
                                                completion:^(id responseObject, NSError *error) {

                                                  [self.loadingView removeFromSuperview];
                                                  self.loadingView.alpha = 0;

                                                  if (error || !responseObject) {
                                                      [self commentError:error];
                                                      return;
                                                  }

                                                  _comments = [[NSMutableArray alloc] init];
                                                  NSArray *response = (NSArray *)responseObject;
                                                  for (NSInteger i = response.count - 1; i >= 0; i--) {
                                                      FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
                                                      [_comments addObject:commentObject];
                                                  }

                                                  if ([self.gallery.comments integerValue] <= 10) {
                                                      showsMoreButton = FALSE;
                                                  } else {
                                                      showsMoreButton = TRUE;
                                                  }

                                                  [self configureComments];

                                                }];
}

- (void)focus {
    NSArray *posts = self.galleryView.orderedPosts; //[[self.gallery.posts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE]]];
    int indexOfPost = -1;
    for (int i = 0; i < posts.count; i++) {
        if ([[(FRSPost *)posts[i] uid] isEqualToString:self.defaultPostID]) {
            indexOfPost = i;
            NSLog(@"POST FOUND: %@ %d", [(FRSPost *)posts[i] uid], indexOfPost);
            break;
        }
    }

    if (indexOfPost > 0) {
        UIScrollView *focusViewScroller = self.galleryView.scrollView;
        [focusViewScroller setContentOffset:CGPointMake(self.view.frame.size.width * indexOfPost, 0) animated:YES];
    }
}

- (void)reload {
    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:self.gallery.uid
                                                completion:^(id responseObject, NSError *error) {
                                                  if (error || !responseObject) {
                                                      [self commentError:error];
                                                      return;
                                                  }

                                                  _comments = [[NSMutableArray alloc] init];

                                                  NSArray *response = (NSArray *)responseObject;
                                                  for (NSInteger i = response.count - 1; i >= 0; i--) {
                                                      FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
                                                      [_comments addObject:commentObject];
                                                  }

                                                  if (response.count < 10) {
                                                      showsMoreButton = FALSE;
                                                  } else {
                                                      showsMoreButton = TRUE;
                                                  }

                                                  [self adjustHeight];

                                                }];
}

- (void)commentError:(NSError *)error {
}

- (void)popViewController {
    [super popViewController];
    [self showTabBarAnimated:YES];
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

    if ([[[self.gallery creator] uid] isEqualToString:[[FRSAPIClient sharedClient] authenticatedUser].uid]) {
        self.navigationItem.rightBarButtonItems = nil;
    }
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
        if ([[FRSAPIClient sharedClient] isAuthenticated]) {
            [view addAction:report];
        }
        if ([[[FRSAPIClient sharedClient] authenticatedUser] blocking] || self.didBlockUser) {
            if ([[FRSAPIClient sharedClient] isAuthenticated]) {
                [view addAction:unblock];
            }
        } else {
            if ([[FRSAPIClient sharedClient] isAuthenticated]) {
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

    NSLog(@"%f", self.galleryView.frame.size.height);

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
                                      NSLog(@"%@", error);
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

        NSLog(@"STRING SIZE  : %f", labelRect.size.height);
        NSLog(@"COMMENT SIZE : %f", commentSize);
        NSLog(@"HEIGHT       : %f", height);

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

    [self.actionBar handleHeartState:isLiked];
    [self.actionBar handleHeartAmount:[numLikes intValue]];
    [self.actionBar handleRepostState:isReposted];
    [self.actionBar handleRepostAmount:[numReposts intValue]];

    [self.view addSubview:self.actionBar];

    if ([self.gallery.creator.uid isEqualToString:[[FRSAPIClient sharedClient] authenticatedUser].uid]) {
        [self.actionBar setCurrentUser:YES];
    } else {
        [self.actionBar setCurrentUser:NO];
    }
}

- (void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    FRSPost *post = [[self.gallery.posts allObjects] firstObject];
    NSString *sharedContent = [@"https://fresconews.com/gallery/" stringByAppendingString:self.gallery.uid];

    sharedContent = [NSString stringWithFormat:@"Check out this gallery from %@: %@", [[post.address componentsSeparatedByString:@","] firstObject], sharedContent];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ sharedContent ] applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];

    [FRSTracker track:sharedFromHighlights parameters:@{ @"gallery_id" : (self.gallery.uid != Nil) ? self.gallery.uid : @"" }];
}

- (void)adjustScrollViewContentSize {

    CGFloat height = self.galleryView.layer.frame.size.height + self.actionBar.layer.frame.size.height + GALLERY_BOTTOM_PADDING + 50;
    if (self.comments.count > 0) {
        height += self.commentTableView.frame.size.height + self.commentLabel.frame.size.height + 20;
    }
    if (self.orderedArticles.count > 0) {
        height += self.articlesTV.frame.size.height + self.articlesLabel.frame.size.height + 20;
    }

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FRSGalleryView Delegate

- (BOOL)shouldHaveActionBar {
    return NO;
}

- (BOOL)shouldHaveTextLimit {
    return NO;
}

- (NSInteger)heightForImageView {
    return 300;
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
    if (scrollView == self.scrollView) {
        [super scrollViewDidScroll:scrollView];
        [self.actionBar actionButtonTitleNeedsUpdate];
    }

    if (scrollView == self.scrollView) {
        float size = self.scrollView.contentSize.height;
        float offset = self.scrollView.contentOffset.y;

        float percentage = offset / size;

        if (percentageScrolled < percentage) {
            percentageScrolled = percentage;
        }
    }
}

#pragma mark - Articles Table View DataSource Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _articlesTV) {
        return self.orderedArticles.count;
    }

    if (tableView == _commentTableView) {

        if (self.comments.count == 0) {
            return 0;
        }

        if (showsMoreButton) {
            return self.comments.count + 1;

        } else {
            return self.comments.count;
        }
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == _articlesTV) {
        return CELL_HEIGHT;
    }

    if (tableView == _commentTableView) {

        if (indexPath.row == 0 && showsMoreButton) {
            return 45;
        }

        if (indexPath.row < self.comments.count + showsMoreButton) {
            FRSCommentCell *cell = (FRSCommentCell *)[self tableView:_commentTableView cellForRowAtIndexPath:indexPath];

            CGFloat height = 0;

            CGRect labelRect = [cell.commentTextView.text
                boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 78, INT_MAX) //78 is the padding on the left and right sides
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15]
                          }
                             context:nil];

            float commentSize = labelRect.size.height;

            commentSize += 36; //36 is default padding

            if (commentSize < 56) {
                height += 56;
            } else {
                height = commentSize + 20;
            }

            NSLog(@"STRING SIZE  : %f", labelRect.size.height);
            NSLog(@"COMMENT SIZE : %f", commentSize);
            NSLog(@"HEIGHT       : %f", height);

            return height;
        }
    }

    return 56;
}

- (void)showAllComments {
    [self loadMoreComments];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _articlesTV) {
        FRSArticlesTableViewCell *cell = [[FRSArticlesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article-cell" article:self.orderedArticles[indexPath.row]];
        return cell;
    } else if (tableView == _commentTableView) {

        if (indexPath.row == 0 && showsMoreButton) {

            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"readAll"];
            topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
            int total = (int)self.totalCommentCount - (int)_comments.count;
            if (total < 0 || total == (int)nil) {
                total = 0;
            }

            if (total == 1) {
                [topButton setTitle:[NSString stringWithFormat:@"Show %d comment", total] forState:UIControlStateNormal];
            } else {
                [topButton setTitle:[NSString stringWithFormat:@"Show all %d comments", total] forState:UIControlStateNormal];
            }
            [topButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
            [topButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
            topButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            topButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);

            [topButton addTarget:self action:@selector(showAllComments) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:topButton];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor frescoBackgroundColorLight];

            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
                [cell setPreservesSuperviewLayoutMargins:NO];
            }
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }

            return cell;
        } else {
            FRSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCommentIdentifier];
            cell.delegate = self;
            if (indexPath.row < self.comments.count + showsMoreButton) {
                FRSComment *comment = _comments[indexPath.row - showsMoreButton];
                cell.cellDelegate = self;
                [cell configureCell:comment delegate:self];
                //                [cell.commentTextView sizeToFit];
                return cell;
            }
        }
    }

    return Nil;
}

//-(void)swipeTableCell:(FRSCommentCell *)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {
//    // The textView goes back to its original size (set in the nib) if we don't size to fit on the swipe action.
//    [cell.commentTextView sizeToFit];
//}
//
//-(void)swipeTableCellWillEndSwiping:(FRSCommentCell *)cell {
//    [cell.commentTextView sizeToFit];
//}

- (void)loadMoreComments {
    FRSComment *comment = self.comments[0];
    NSString *lastID = comment.uid;

    [[FRSAPIClient sharedClient] fetchMoreComments:self.gallery
                                              last:lastID
                                        completion:^(id responseObject, NSError *error) {
                                          if (!responseObject || error) {

                                              return;
                                          }

                                          int count = 0;

                                          for (NSDictionary *comment in responseObject) {
                                              FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:comment];
                                              [_comments insertObject:commentObject atIndex:0];
                                              count++;
                                          }

                                          if (count < 10) {
                                              showsMoreButton = FALSE;
                                          } else {
                                              showsMoreButton = TRUE;
                                          }

                                          if (([self.commentTableView visibleCells].count - 1) == [self.gallery.comments integerValue] - 10) {
                                              showsMoreButton = FALSE;
                                          }

                                          [self adjustHeight];
                                        }];
}

- (void)adjustHeight {
    float height = 0;
    NSInteger index = 0;

    for (FRSComment *comment in _comments) {

        CGRect labelRect = [comment.comment
            boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 78, INT_MAX) //78 is left and right padding
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:15]
                      }
                         context:nil];

        float commentSize = labelRect.size.height;

        if (commentSize < 56) {
            height += 56;
        } else {
            height += commentSize;
        }
        index++;
    }

    height += 56;

    self.commentTableView.frame = CGRectMake(0, self.commentTableView.frame.origin.y, self.view.frame.size.width, height);
    [self adjustScrollViewContentSize];
    [self.commentTableView reloadData];
    self.commentTableView.hidden = self.comments.count == 0;
    self.commentLabel.hidden = self.comments.count == 0;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {

    if ([URL.absoluteString containsString:@"name"]) {
        NSString *user = [URL.absoluteString stringByReplacingOccurrencesOfString:@"name://" withString:@""];
        NSLog(@"USER: %@", user);
        FRSProfileViewController *viewController = [[FRSProfileViewController alloc] initWithUserID:user];
        self.navigationItem.title = @"";
        //        [self animateDismissCommentField];

        [self.navigationController pushViewController:viewController animated:YES];
    } else if ([URL.absoluteString containsString:@"tag"]) {
        NSString *search = [URL.absoluteString stringByReplacingOccurrencesOfString:@"tag://" withString:@""];
        FRSSearchViewController *controller = [[FRSSearchViewController alloc] init];
        [controller search:search];
        self.navigationItem.title = @"";
        [self.tabBarController.tabBar setHidden:NO];
        //        [self animateDismissCommentField];
        [self.navigationController pushViewController:controller animated:YES];
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _articlesTV) {
        [((FRSArticlesTableViewCell *)cell)configureCell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView == self.articlesTV) {
        if (self.orderedArticles.count > indexPath.row) {
            FRSArticle *article = self.orderedArticles[indexPath.row];
            if (article.articleStringURL) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:article.articleStringURL]];
                [FRSTracker track:articleOpens parameters:@{ @"article_url" : article.articleStringURL,
                                                             @"article_id" : article.uid }];
            }
        }
    }

    if (tableView == _commentTableView) {

        if (self.didPrepareForReply) {
            self.didPrepareForReply = NO;
            [self dismissKeyboardFromView];
        } else {
            self.didPrepareForReply = YES;
            [self contentActionBarDidSelectActionButton:self.actionBar];
            FRSComment *currentComment = [self.comments objectAtIndex:indexPath.row];
            commentField.text = [NSString stringWithFormat:@"@%@ ", [[currentComment userDictionary] objectForKey:@"username"]];
        }
    }
}

#pragma mark - Comments View Delegate

- (void)commentsView:(FRSCommentsView *)commentsView didToggleViewMode:(BOOL)showAllComments {
    [self.commentsView setSizeWithSize:CGSizeMake(self.commentsView.frame.size.width, [self.commentsView height])];
    [self adjustScrollViewContentSize];
}

#pragma mark - Action Bar Delegate and Methods

- (NSString *)titleForActionButton {
    CGRect visibleRect;
    visibleRect.origin = self.scrollView.contentOffset;
    visibleRect.size = self.scrollView.bounds.size;

    NSInteger offset = visibleRect.origin.y + visibleRect.size.height + TOP_NAV_BAR_HEIGHT - GALLERY_BOTTOM_PADDING - self.actionBar.frame.size.height;

    if (self.commentLabel.frame.origin.y > offset) {
        if (self.gallery && self.totalCommentCount > 0) {
            return [NSString stringWithFormat:@"%lu COMMENTS", (unsigned long)self.totalCommentCount];
        }
    }
    return @"ADD A COMMENT";
}

- (UIColor *)colorForActionButton {
    return [UIColor frescoBlueColor];
}

- (void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar {
    // comment text field comes up
    if (![[FRSAPIClient sharedClient] checkAuthAndPresentOnboard]) {
        if (!commentField) {
            commentField = [[UITextField alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, self.view.frame.size.width, 44)];
            commentField.backgroundColor = [UIColor frescoBackgroundColorLight];
            commentField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            commentField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Say something nice" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor] }];
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 44)];
            leftView.backgroundColor = [UIColor clearColor];
            commentField.leftViewMode = UITextFieldViewModeAlways;
            commentField.leftView = leftView;
            commentField.returnKeyType = UIReturnKeySend;

            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, commentField.frame.size.width, .5)];
            line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.12];
            [commentField addSubview:line];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUp:) name:UIKeyboardWillShowNotification object:Nil];

            [self.view addSubview:commentField];

            [commentField addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventEditingDidEndOnExit];
            commentField.delegate = self;
        }
        commentField.text = @"";
        [commentField becomeFirstResponder];
    }
}

- (void)sendComment {
    if (!commentField.text || commentField.text.length == 0) {
        return;
    }

    [[FRSAPIClient sharedClient] addComment:commentField.text
                                  toGallery:self.galleryID
                                 completion:^(id responseObject, NSError *error) {
                                   NSLog(@"%@ %@", responseObject, error);
                                   if (error) {
                                       NSString *message = [NSString stringWithFormat:@"\"%@\"", commentField.text];
                                       self.errorAlertView = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Comment failed.\nPlease try again later." actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                       [self.errorAlertView show];
                                   } else {

                                       self.totalCommentCount++;
                                       [commentField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentField.frame.size.width, commentField.frame.size.height)];
                                       //                [self.view setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];

                                       self.totalCommentCount++;
                                       self.commentTableView.hidden = NO;
                                       [self reload];
                                       //                CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                                       //                [self.scrollView setContentOffset:bottomOffset animated:YES];

                                       commentField.text = @"";
                                       [self dismissKeyboard:Nil];
                                   }
                                 }];
}

- (void)changeUp:(NSNotification *)change {

    if (self.didChangeUp) {
        return;
    }

    [UIView animateWithDuration:.2
                     animations:^{
                       NSDictionary *info = [change userInfo];

                       CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
                       CGFloat originY = self.view.frame.size.height - commentField.frame.size.height;
                       [commentField setFrame:CGRectMake(0, originY, commentField.frame.size.width, commentField.frame.size.height)];
                       [self.view setFrame:CGRectMake(0, self.view.frame.origin.y - keyboardSize.height, self.view.frame.size.width, self.view.frame.size.height)];
                     }];

    self.didChangeUp = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 3D Touch

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self register3DTouch];
}

- (void)register3DTouch {
    if ((self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) && (self.touchEnabled == NO)) {
        self.touchEnabled = YES;
        [self registerForPreviewingWithDelegate:self sourceView:self.articlesTV];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {

    CGPoint cellPostion = [self.articlesTV convertPoint:location fromView:self.articlesTV];
    NSIndexPath *path = [self.articlesTV indexPathForRowAtPoint:cellPostion];
    [previewingContext setSourceRect:[self.articlesTV rectForRowAtIndexPath:path]];

    PeekPopArticleViewController *vc = [[PeekPopArticleViewController alloc] init];
    UIView *contentView = vc.view;

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    [contentView addSubview:webView];
    FRSArticle *article = self.orderedArticles[path.row];
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

- (void)dismissKeyboard:(UITapGestureRecognizer *)tap {
    self.didChangeUp = NO;

    [self.galleryView playerTap:tap];
    if (commentField.isEditing) {
        [commentField resignFirstResponder];

        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           [commentField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentField.frame.size.width, commentField.frame.size.height)];
                           [self.view setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
                         }
                         completion:nil];
    } else {
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
            [commentField resignFirstResponder];
            [commentField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentField.frame.size.width, commentField.frame.size.height)];
            [self.view setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
        } else if (index == 1) {
            [self sendComment];
        }
    }
}

#pragma mark - FRSCommentCellDelegate

- (void)didPressProfilePictureWithUserId:(NSString *)userId {

    FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUserID:userId];
    [self.navigationController pushViewController:controller animated:TRUE];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == commentField) {
        [self sendComment];
        return NO;
    }
    return YES;
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

- (void)loadGallery:(FRSGallery *)gallery {
    self.gallery = gallery;

    if (gallery.uid) {
        self.galleryID = gallery.uid;
    }

    self.orderedArticles = [self.gallery.articles allObjects];
    self.hiddenTabBar = YES;
    self.actionBarVisible = YES;
    self.touchEnabled = NO;
    [self.galleryView loadGallery:gallery];
    [self fetchCommentsWithID:gallery.uid];
}

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
