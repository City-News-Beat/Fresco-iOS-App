//
//  FRSGalleryDetailView.m
//  Fresco
//
//  Created by Arthur De Araujo on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryDetailView.h"
#import "FRSGalleryView.h"
#import "FRSProfileViewController.h"
#import "FRSComment.h"
#import "FRSCommentCell.h"
#import "FRSArticlesTableViewCell.h"
#import "FRSSearchViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSGalleryStatusView.h"
#import "FRSGalleryStatusTableViewCell.h"
#import "Haneke.h"
#import "FRSUserManager.h"

#define CELL_HEIGHT 62
#define TOP_NAV_BAR_HEIGHT 64
#define GALLERY_BOTTOM_PADDING 16

@interface FRSGalleryDetailView () <FRSGalleryViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, FRSContentActionBarDelegate, FRSCommentCellDelegate, MGSwipeTableCellDelegate, UITextViewDelegate>

@property BOOL didPrepareForReply;

@end

@implementation FRSGalleryDetailView {
    FRSAlertView *errorAlertView;
    int totalCommentCount;
    BOOL showsMoreButton;
    UIButton *showCommentsButton;

    // Verification Tab
    IBOutlet UIImageView *verificationEyeImageView;
    IBOutlet UIView *verificationContainerView;
    IBOutlet UILabel *verificationLabel;
    IBOutlet NSLayoutConstraint *verificationViewHeightConstraint;
    IBOutlet NSLayoutConstraint *verificationViewLeftContraint;

    // Comment Bottom Bar
    IBOutlet UIView *addCommentView;
    IBOutlet NSLayoutConstraint *addCommentBotConstraint;

    // Comments TableVeiw
    IBOutlet UIView *commentsTVTopLine;
    IBOutlet UITableView *commentsTableView;
    IBOutlet UILabel *commentsLabel;
    IBOutlet NSLayoutConstraint *commentsLabelTopConstraint;
    IBOutlet NSLayoutConstraint *commentsHeightConstraint;

    // Articles
    IBOutlet UIView *articlesTVTopLine;
    IBOutlet UILabel *articlesLabel;
    IBOutlet NSLayoutConstraint *articlesHeightConstraint;

    IBOutlet NSLayoutConstraint *galleryHeightConstraint;

    // Gallery Status
    FRSGalleryStatusView *galleryStatusPopup;
    NSMutableArray *galleryPurchases;
}

static NSString *reusableCommentIdentifier = @"commentIdentifier";

- (void)loadGalleryDetailViewWithGallery:(FRSGallery *)gallery parentVC:(FRSGalleryExpandedViewController *)parentVC {
    self.gallery = gallery;
    self.parentVC = parentVC;
    self.scrollView.delegate = parentVC;
    self.totalCommentCount = [[gallery valueForKey:@"comments"] intValue];

    [self configureUI];
    [self fetchCommentsWithID:gallery.uid];
}

- (void)configureUI {
    [self configureGalleryView];
    [self configureArticles];
    [self configureComments];
    [self configureActionBar];
    [self configureVerificationTabView];
    if ([self.gallery.comments integerValue] >= 1) {
        [self configureCommentsSpinner];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:Nil];
}

- (void)configureCommentsSpinner { //Not sure if this does anything
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] initWithFrame:CGRectMake(82, 13, 20, 20)];
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
    [commentsLabel addSubview:self.loadingView];
}

- (void)configureGalleryView {
    [self.galleryView configureWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500) gallery:self.gallery delegate:self];
    galleryHeightConstraint.constant = self.galleryView.frame.size.height;

    [self.galleryView play];
    [self focusOnPost];
    [self layoutSubviews];
}

- (void)configureArticles {
    articlesHeightConstraint.constant = CELL_HEIGHT * [self.gallery.articles allObjects].count;

    self.articlesTableView.delegate = self;
    self.articlesTableView.dataSource = self;

    self.articlesTableView.hidden = [self.gallery.articles allObjects].count == 0;
    articlesTVTopLine.hidden = [self.gallery.articles allObjects].count == 0;
    articlesLabel.hidden = [self.gallery.articles allObjects].count == 0;
}

- (void)configureComments {

    // Move the comment tableview up if there are no articles
    CGFloat zeplinTVLabelTopPadding = 24;
    if ([self.gallery.articles allObjects].count > 0) {
        commentsLabelTopConstraint.constant = zeplinTVLabelTopPadding;
    } else {
        commentsLabelTopConstraint.constant = -zeplinTVLabelTopPadding;
    }

    [commentsTableView registerNib:[UINib nibWithNibName:@"FRSCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reusableCommentIdentifier];

    commentsTableView.delegate = self;
    commentsTableView.dataSource = self;

    commentsTableView.hidden = self.comments.count == 0;
    commentsTVTopLine.hidden = self.comments.count == 0;
    commentsLabel.hidden = self.comments.count == 0;

    [self adjustCommentsTableHeight];
    [self.actionBar actionButtonTitleNeedsUpdate];
    [commentsTableView reloadData];
}

- (void)configureActionBar {
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.frame.size.height - TOP_NAV_BAR_HEIGHT - 44) delegate:self];
    self.actionBar.delegate = self;

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
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

    [self addSubview:self.actionBar];

    if ([self.gallery.creator.uid isEqualToString:[[FRSUserManager sharedInstance] authenticatedUser].uid]) {
        [self.actionBar setCurrentUser:YES];
    } else {
        [self.actionBar setCurrentUser:NO];
    }
}

- (void)configureVerificationTabView {
    // If the user created the gallery
    verificationViewHeightConstraint.constant = 0;
    verificationContainerView.hidden = true;
    [self updateConstraints];

    if ([self.gallery.creator.uid isEqualToString:[[FRSUserManager sharedInstance] authenticatedUser].uid]) {
        verificationViewLeftContraint.constant = 16; // Zeplin reg distance
        verificationEyeImageView.hidden = true;

        [self getGalleryPurchases];

        if (self.gallery.verificationRating == 0) { // Not Rated
            verificationLabel.text = @"PENDING VERIFICATION";
            verificationContainerView.backgroundColor = [UIColor frescoOrangeColor];
        } else if (self.gallery.verificationRating == 1) { // Skipped
            verificationLabel.text = @"NOT VERIFIED";
            verificationContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.26];
        } else if (self.gallery.verificationRating == 2 || self.gallery.verificationRating == 3) { // Verified or Highlighted
            verificationLabel.text = @"VERIFIED";
            verificationContainerView.backgroundColor = [UIColor colorWithRed:(76 / 255.0) green:(215 / 255.0) blue:(100 / 255.0) alpha:1.0];
        } else if (self.gallery.verificationRating == 4) { // DELETED
            verificationLabel.text = @"DELETED";
            verificationContainerView.backgroundColor = [UIColor colorWithRed:(208 / 255.0) green:(2 / 255.0) blue:(27 / 255.0) alpha:1.0];
        }
    } else {
        verificationViewHeightConstraint.constant = 0;
        verificationContainerView.hidden = true;
    }
}

- (void)animateVerificationTabIn {
    verificationContainerView.hidden = false;
    [UIView animateWithDuration:0.1
                     animations:^{
                       verificationViewHeightConstraint.constant = 44;
                       [self layoutIfNeeded];
                     }];
}

- (void)getGalleryPurchases {
    [[FRSAPIClient sharedClient] fetchPurchasesForGalleryID:self.gallery.uid
                                                 completion:^(id responseObject, NSError *error) {
                                                   galleryPurchases = [[NSMutableArray alloc] initWithArray:responseObject];
                                                   [self animateVerificationTabIn];
                                                   [self configureVerificationTabBarTitle];
                                                 }];
}

- (void)configureVerificationTabBarTitle {
    if (galleryPurchases.count > 0) {
        verificationContainerView.backgroundColor = [UIColor colorWithRed:(76 / 255.0) green:(215 / 255.0) blue:(100 / 255.0) alpha:1.0];
        if (galleryPurchases.count == 1) {
            NSDictionary *purchase = [[galleryPurchases objectAtIndex:0][@"purchases"] objectAtIndex:0];

//            NSLog(@"%@", purchase[@"outlet"]);

            NSString *title = [purchase valueForKeyPath:@"outlet.title"];

            verificationLabel.text = [NSString stringWithFormat:@"SOLD TO %@", [title uppercaseString]];
            if ([title isEqualToString:@"Fresco News"]) {
                verificationViewLeftContraint.constant = 56; // Zeplin distance from left
                verificationEyeImageView.hidden = false;
            }
        } else {
            //Check all of the outlet names to see if they are different, if all the purchases are made by 1 outlet, show that it was bought by the 1 outlet
            BOOL boughtByOneOutlet = true;

            NSMutableArray *outletNames = [[NSMutableArray alloc] init];

            //Loop through the purchases dict
            for (int i = 0; i < galleryPurchases.count; i++) {
                NSDictionary *galleryDict = [galleryPurchases objectAtIndex:i];
                NSArray *galleryPurchasesArray = (NSArray *)(galleryDict[@"purchases"]);
                // Loop through the purchases dict inside the purchases
                for (int n = 0; n < galleryPurchasesArray.count; n++) {
                    NSString *outletName = (NSString *)[[galleryPurchasesArray objectAtIndex:n] valueForKeyPath:@"outlet.title"];
                    // Loop through the existing outlet names to compare
                    for (int x = 0; x < outletNames.count; x++) {
                        // Check if the outlet name is different from the rest
                        if (![outletName isEqualToString:outletNames[x]]) {
                            boughtByOneOutlet = false;
                        }
                    }
                    [outletNames addObject:outletName];
                }
            }

            if (boughtByOneOutlet) {
                if ([outletNames[0] isEqualToString:@"Fresco News"]){
                    verificationViewLeftContraint.constant = 56; // Zeplin distance from left
                    verificationEyeImageView.hidden = false;
                }
                verificationLabel.text = [NSString stringWithFormat:@"SOLD TO %@", [outletNames[0] uppercaseString]];
            } else {
                verificationLabel.text = [NSString stringWithFormat:@"SOLD TO %lu OUTLETS", (unsigned long)galleryPurchases.count];
            }
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)focusOnPost {
    NSArray *posts = self.galleryView.orderedPosts;
    //[[self.gallery.posts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE]]];
    int indexOfPost = -1;
    for (int i = 0; i < posts.count; i++) {
        if ([[(FRSPost *)posts[i] uid] isEqualToString:self.defaultPostID]) {
            indexOfPost = i;
            //NSLog(@"POST FOUND: %@ %d", [(FRSPost *)posts[i] uid], indexOfPost);
            break;
        }
    }
    /*
    if (indexOfPost > 0) {
        UIScrollView *focusViewScroller = self.galleryView.scrollView;
        [focusViewScroller setContentOffset:CGPointMake(self.view.frame.size.width * indexOfPost, 0) animated:YES];
    }*/
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)tap {
    self.actionBar.hidden = false;
    addCommentBotConstraint.constant = 0;

    [self.galleryView playerTap:tap];
    if (self.commentTextField.isEditing) {
        [self.commentTextField resignFirstResponder];
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                         }
                         completion:nil];
    }

    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];

    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    addCommentBotConstraint.constant = keyboardSize.height;

    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)adjustCommentsTableHeight {
    float height = 0;
    NSInteger index = 0;

    //Add in all the comment's heights
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
    height += 45;

    commentsTableView.frame = CGRectMake(0, commentsTableView.frame.origin.y, self.frame.size.width, height);
    if (!showsMoreButton) {
        CGFloat showMoreHeight = 45;
        height -= showMoreHeight;
    }

    commentsHeightConstraint.constant = height;

    [commentsTableView reloadData];
}

#pragma mark - Comment Methods

- (void)sendComment {
    if (!self.commentTextField.text || self.commentTextField.text.length == 0) {
        return;
    }

    [[FRSAPIClient sharedClient] addComment:self.commentTextField.text
                                  toGallery:self.gallery.uid
                                 completion:^(id responseObject, NSError *error) {
                                   // NSLog(@"%@ %@", responseObject, error);
                                   if (error) {
                                       NSString *message = [NSString stringWithFormat:@"\"%@\"", self.commentTextField.text];
                                       errorAlertView = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Comment failed.\nPlease try again later." actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
                                       [errorAlertView show];
                                   } else {
                                       self.totalCommentCount++;
                                       commentsTableView.hidden = NO;

                                       self.commentTextField.text = @"";

                                       [self reloadComments];
                                       [self dismissKeyboard:Nil];
                                   }
                                 }];
}

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

                                          if (([commentsTableView visibleCells].count - 1) == [self.gallery.comments integerValue] - 10) {
                                              showsMoreButton = FALSE;
                                          }

                                          [self adjustCommentsTableHeight];
                                        }];
}

- (void)fetchCommentsWithID:(NSString *)galleryID {
    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:galleryID
                                                completion:^(id responseObject, NSError *error) {
                                                  [self.loadingView removeFromSuperview];
                                                  self.loadingView.alpha = 0;

                                                  if (error || !responseObject) {
                                                      //[self commentError:error];
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

- (void)reloadComments {
    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:self.gallery.uid
                                                completion:^(id responseObject, NSError *error) {
                                                  if (error || !responseObject) {
                                                      //[self commentError:error];
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

                                                  [self adjustCommentsTableHeight];
                                                }];
}

- (void)showAllComments {
    [self loadMoreComments];
}

#pragma mark - IBActions

- (IBAction)showGalleryStatus:(id)sender {
    galleryStatusPopup = (FRSGalleryStatusView *)[[[NSBundle mainBundle] loadNibNamed:@"FRSGalleryStatusView" owner:self options:nil] objectAtIndex:0];
    [galleryStatusPopup configureWithArray:galleryPurchases rating:(int)self.gallery.verificationRating];
    [[UIApplication sharedApplication].keyWindow addSubview:galleryStatusPopup];
    galleryStatusPopup.parentVC = self.parentVC;
    galleryStatusPopup.parentView = self;
    galleryStatusPopup.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame;
}

#pragma mark - FRSContentActionBarDelegate and Action Bar Methods

- (NSString *)titleForActionButton {
    CGRect visibleRect;
    visibleRect.origin = self.scrollView.contentOffset;
    visibleRect.size = self.scrollView.bounds.size;

    NSInteger offset = visibleRect.origin.y + visibleRect.size.height + TOP_NAV_BAR_HEIGHT - GALLERY_BOTTOM_PADDING - self.actionBar.frame.size.height;

    if (commentsLabel.frame.origin.y > offset) {
        if (self.gallery && self.totalCommentCount > 0) {
            return [NSString stringWithFormat:@"%lu COMMENTS", (unsigned long)self.totalCommentCount];
        }
    }
    return @"ADD A COMMENT";
}

- (UIColor *)colorForActionButton {
    return [UIColor frescoBlueColor];
}

- (void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    FRSPost *post = [[self.gallery.posts allObjects] firstObject];
    NSString *sharedContent = [@"https://fresconews.com/gallery/" stringByAppendingString:self.gallery.uid];

    sharedContent = [NSString stringWithFormat:@"Check out this gallery from %@: %@", [[post.address componentsSeparatedByString:@","] firstObject], sharedContent];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ sharedContent ] applicationActivities:nil];
    [self.parentVC.navigationController presentViewController:activityController animated:YES completion:nil];

    [FRSTracker track:sharedFromHighlights parameters:@{ @"gallery_id" : (self.gallery.uid != Nil) ? self.gallery.uid : @"" }];
}

- (void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar {
    // comment text field comes up
    if (![[FRSAPIClient sharedClient] checkAuthAndPresentOnboard]) {
        [self.commentTextField addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventEditingDidEndOnExit];
        self.commentTextField.delegate = self;
        self.commentTextField.text = @"";
        [self.commentTextField becomeFirstResponder];
    }
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

#pragma mark - FRSCommentCellDelegate

- (void)didPressProfilePictureWithUserId:(NSString *)userId {
    FRSProfileViewController *controller = [[FRSProfileViewController alloc] initWithUserID:userId];
    [self.navigationController pushViewController:controller animated:TRUE];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.commentTextField) {
        [self sendComment];
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.articlesTableView) {
        return [self.gallery.articles allObjects].count;
    }

    if (tableView == commentsTableView) {
        if (self.comments.count == 0) {
            return 0;
        } else if (showsMoreButton) {
            return self.comments.count + 1;
        } else {
            return self.comments.count;
        }
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == self.articlesTableView) {
        return CELL_HEIGHT;
    }

    if (tableView == commentsTableView) {
        if (indexPath.row == 0 && showsMoreButton) {
            CGFloat showsMoreButtonHeight = 45;
            return showsMoreButtonHeight;
        }

        if (indexPath.row < self.comments.count + showsMoreButton) {
            FRSCommentCell *cell = (FRSCommentCell *)[self tableView:commentsTableView cellForRowAtIndexPath:indexPath];

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

            return height;
        }
    }

    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.articlesTableView) {
        FRSArticlesTableViewCell *cell = [[FRSArticlesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article-cell" article:[self.gallery.articles allObjects][indexPath.row]];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else if (tableView == commentsTableView) {

        if (indexPath.row == 0 && showsMoreButton) {
            // Create the show more comments button
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"readAll"];
            showCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
            int total = (int)self.totalCommentCount - (int)_comments.count;
            if (total < 0 || total == (int)nil) {
                total = 0;
            }

            if (total == 1) {
                [showCommentsButton setTitle:[NSString stringWithFormat:@"Show %d comment", total] forState:UIControlStateNormal];
            } else {
                [showCommentsButton setTitle:[NSString stringWithFormat:@"Show all %d comments", total] forState:UIControlStateNormal];
            }
            [showCommentsButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
            [showCommentsButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
            showCommentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            showCommentsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);

            [showCommentsButton addTarget:self action:@selector(showAllComments) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:showCommentsButton];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView.backgroundColor = [UIColor clearColor];

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
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                return cell;
            }
        }
    }

    return Nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.articlesTableView) {
        [((FRSArticlesTableViewCell *)cell)configureCell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView == self.articlesTableView) {
        if ([self.gallery.articles allObjects].count > indexPath.row) {
            FRSArticle *article = [self.gallery.articles allObjects][indexPath.row];
            if (article.articleStringURL) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:article.articleStringURL]];
                [FRSTracker track:articleOpens
                       parameters:@{ @"article_url" : article.articleStringURL,
                                     @"article_id" : article.uid }];
            }
        }
    }

    if (tableView == commentsTableView) {
        if (self.didPrepareForReply) {
            self.didPrepareForReply = NO;
            [self.parentVC dismissKeyboardFromView];
        } else {
            self.didPrepareForReply = YES;
            [self contentActionBarDidSelectActionButton:self.actionBar];
            FRSComment *currentComment = [self.comments objectAtIndex:indexPath.row];
            self.commentTextField.text = [NSString stringWithFormat:@"@%@ ", [[currentComment userDictionary] objectForKey:@"username"]];
        }
    }
}

#pragma mark - MGSwipeTableCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    FRSComment *comment = [self.comments objectAtIndex:[commentsTableView indexPathForCell:cell].row - showsMoreButton];

    if (comment.isDeletable && comment.isReportable) {
        if (index == 0) {
            [self deleteAtIndexPath:[commentsTableView indexPathForCell:cell]];
        } else if (index == 1) {
            [self.parentVC presentFlagCommentSheet:comment];
        }

    } else if (comment.isDeletable && !comment.isReportable) {
        if (index == 0) {
            [self deleteAtIndexPath:[commentsTableView indexPathForCell:cell]];
        }

    } else if (!comment.isDeletable && comment.isReportable) {
        if (index == 0) {
            [self.parentVC presentFlagCommentSheet:comment];
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
                                          [self reloadComments];
                                      }
                                    }];
}

#pragma mark - FRSGalleryView Delegate

- (BOOL)shouldHaveActionBar {
    return NO;
}

- (BOOL)shouldHaveTextLimit {
    return NO;
}

- (void)playerWillPlay:(FRSPlayer *)player {
}

@end
