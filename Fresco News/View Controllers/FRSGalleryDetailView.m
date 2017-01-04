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
#import "FRSCommentsView.h"
#import "FRSComment.h"

#define CELL_HEIGHT 62

@interface FRSGalleryDetailView () <FRSGalleryViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>


@end

@implementation FRSGalleryDetailView {
    
    FRSAlertView *errorAlertView;
    int totalCommentCount;
    
    IBOutlet UITableView *articlesTableView;
    IBOutlet UILabel *articlesLabel;
    IBOutlet NSLayoutConstraint *articlesHeightConstraint;
    IBOutlet NSLayoutConstraint *galleryHeightConstraint;
    IBOutlet UITextField *commentTextField;
    IBOutlet UIScrollView *scrollView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"Test: Loaded View");
    articlesLabel.hidden = true;
}

-(void)configureGalleryView{
    NSLog(@"TEST TEST1");
    
    [self.galleryView configureWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500) gallery:self.gallery delegate:self];
    
    /*self.self.galleryView = [[FRSself.galleryView alloc] initWithFrame:CGRectMake(0, TOP_NAV_BAR_HEIGHT, self.view.frame.size.width, 500) gallery:self.gallery delegate:self];
    [self.scrollView addSubview:self.self.galleryView];
    */
    NSLog(@"TEST TEST");
    NSLog(@"%f", self.galleryView.frame.size.height);
    NSLog(@"%f", self.galleryView.frame.size.width);
    NSLog(@"%f", self.galleryView.frame.origin.x);
    NSLog(@"%f", self.galleryView.frame.origin.y);
    NSLog(@"Gallery JSON %@", self.gallery.jsonObject);
    
    galleryHeightConstraint.constant = self.galleryView.frame.size.height;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.galleryView addGestureRecognizer:tap];
    [self.galleryView play];
    [self focus];
    [self layoutSubviews];
    
    //    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.self.galleryView.frame.origin.y + self.self.galleryView.frame.size.height)]];
}

-(void)configureArticles{
    
    if ([self.gallery.articles allObjects].count == 0) {
        return;
    }
    
    if ([self.gallery.articles allObjects].count > 0) {
        articlesLabel.hidden = false;
    }
    
    articlesHeightConstraint.constant = CELL_HEIGHT * [self.gallery.articles allObjects].count;
    
    articlesTableView.delegate = self;
    articlesTableView.dataSource = self;
    articlesTableView.hidden = [self.gallery.articles allObjects].count == 0;
    
    if ([self.gallery.articles allObjects].count > 0) {
//        [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.articlesTV.frame.origin.y - 0.5)]];
    }
}

-(void)configureComments {
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
        }
        else {
            height += commentSize += 20;
        }
        
        NSLog(@"STRING SIZE  : %f", labelRect.size.height);
        NSLog(@"COMMENT SIZE : %f", commentSize);
        NSLog(@"HEIGHT       : %f", height);
        
        index++;
    }
    
    CGFloat labelOriginY = self.galleryView.frame.origin.y + self.galleryView.frame.size.height;
    
    if ([self.gallery.articles allObjects].count > 0) {
        labelOriginY += articlesTableView.frame.size.height + articlesLabel.frame.size.height;
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

-(void)loadMoreComments {
    FRSComment *comment = self.comments[0];
    NSString *lastID = comment.uid;
    
    [[FRSAPIClient sharedClient] fetchMoreComments:self.gallery last:lastID completion:^(id responseObject, NSError *error) {
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
        
        if (([self.commentTableView visibleCells].count -1) == [self.gallery.comments integerValue] -10) {
            showsMoreButton = FALSE;
        }
        
        [self adjustHeight];
    }];
}

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar{
    // comment text field comes up
    if (![[FRSAPIClient sharedClient] checkAuthAndPresentOnboard]) {
        if (!commentTextField) {
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUp:) name:UIKeyboardWillShowNotification object:Nil];
            
            [commentTextField addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventEditingDidEndOnExit];
            commentTextField.delegate = self;
        }
        commentTextField.text = @"";
        [commentTextField becomeFirstResponder];
    }
}

-(void)sendComment {
    if (!commentTextField.text || commentTextField.text.length == 0) {
        return;
    }
    
    [[FRSAPIClient sharedClient] addComment:commentTextField.text toGallery:self.gallery.uid completion:^(id responseObject, NSError *error) {
        NSLog(@"%@ %@", responseObject, error);
        if (error) {
            NSString *message = [NSString stringWithFormat:@"\"%@\"", commentTextField.text];
            errorAlertView = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Comment failed.\nPlease try again later." actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
            [errorAlertView show];
        }
        else {
            totalCommentCount++;
            [commentTextField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentTextField.frame.size.width, commentTextField.frame.size.height)];
            //                [self.view setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
            
            totalCommentCount++;
            self.commentTableView.hidden = NO;
            [self reload];
            //                CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
            //                [self.scrollView setContentOffset:bottomOffset animated:YES];
            
            commentTextField.text = @"";
            [self dismissKeyboard:Nil];
            
        }
    }];
}


-(void)focus {
    NSArray *posts = self.galleryView.orderedPosts; //[[self.gallery.posts allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:FALSE]]];
    int indexOfPost = -1;
    for (int i = 0; i < posts.count; i++) {
        if ([[(FRSPost *)posts[i] uid] isEqualToString:self.defaultPostID]) {
            indexOfPost = i;
            NSLog(@"POST FOUND: %@ %d", [(FRSPost *)posts[i] uid], indexOfPost);
            break;
        }
    }
    /*
    if (indexOfPost > 0) {
        UIScrollView *focusViewScroller = self.galleryView.scrollView;
        [focusViewScroller setContentOffset:CGPointMake(self.view.frame.size.width * indexOfPost, 0) animated:YES];
    }*/
}

-(void)dismissKeyboard:(UITapGestureRecognizer *)tap {
    self.didChangeUp = NO;
    
    [self.galleryView playerTap:tap];
    if (commentTextField.isEditing) {
        [commentTextField resignFirstResponder];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [commentTextField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentTextField.frame.size.width, commentTextField.frame.size.height)];
            [self setFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height)];
        } completion:nil];
    }
    else {
        
    }
}

-(void)changeUp:(NSNotification *)change {
    
    if (self.didChangeUp) {
        return;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        NSDictionary *info = [change userInfo];
        
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat originY = self.frame.size.height - commentTextField.frame.size.height;
        [commentTextField setFrame:CGRectMake(0, originY , commentTextField.frame.size.width, commentTextField.frame.size.height)];
        [self setFrame:CGRectMake(0, self.frame.origin.y - keyboardSize.height, self.frame.size.width, self.frame.size.height)];
    }];
    
    self.didChangeUp = YES;
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

#pragma mark - Articles Table View DataSource Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
            }
            else {
                height = commentSize +20;
            }
            
            NSLog(@"STRING SIZE  : %f", labelRect.size.height);
            NSLog(@"COMMENT SIZE : %f", commentSize);
            NSLog(@"HEIGHT       : %f", height);
            
            return height;
        }
    }
    
    return 56;
}

-(void)showAllComments {
    [self loadMoreComments];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _articlesTV) {
        FRSArticlesTableViewCell *cell = [[FRSArticlesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article-cell" article:self.orderedArticles[indexPath.row]];
        return cell;
    }
    else if (tableView == _commentTableView) {
        
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
        }
        else {
            FRSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCommentIdentifier];
            cell.delegate = self;
            if (indexPath.row < self.comments.count+showsMoreButton) {
                FRSComment *comment = _comments[indexPath.row-showsMoreButton];
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

-(void)loadMoreComments {
    FRSComment *comment = self.comments[0];
    NSString *lastID = comment.uid;
    
    [[FRSAPIClient sharedClient] fetchMoreComments:self.gallery last:lastID completion:^(id responseObject, NSError *error) {
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
        
        if (([self.commentTableView visibleCells].count -1) == [self.gallery.comments integerValue] -10) {
            showsMoreButton = FALSE;
        }
        
        [self adjustHeight];
    }];
}

-(void)adjustHeight {
    float height = 0;
    NSInteger index = 0;
    
    for (FRSComment *comment in _comments) {
        
        CGRect labelRect = [comment.comment
                            boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width -78, INT_MAX) //78 is left and right padding
                            options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{
                                         NSFontAttributeName : [UIFont systemFontOfSize:15]
                                         }
                            context:nil];
        
        float commentSize = labelRect.size.height;
        
        if (commentSize < 56) {
            height += 56;
        }
        else {
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
    }
    else if ([URL.absoluteString containsString:@"tag"]) {
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _articlesTV) {
        [((FRSArticlesTableViewCell *)cell) configureCell];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (tableView == self.articlesTV) {
        if (self.orderedArticles.count > indexPath.row) {
            FRSArticle *article = self.orderedArticles[indexPath.row];
            if (article.articleStringURL) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:article.articleStringURL]];
                [FRSTracker track:articleOpens parameters:@{@"article_url":article.articleStringURL, @"article_id":article.uid}];
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

-(void)commentsView:(FRSCommentsView *)commentsView didToggleViewMode:(BOOL)showAllComments{
    [self.commentsView setSizeWithSize:CGSizeMake(self.commentsView.frame.size.width, [self.commentsView height])];
    [self adjustScrollViewContentSize];
}

#pragma mark - FRSGalleryView Delegate

-(BOOL)shouldHaveActionBar {
    return NO;
}

-(BOOL)shouldHaveTextLimit {
    return NO;
}

-(NSInteger)heightForImageView {
    return 300;
}

-(void)handleLike:(FRSContentActionsBar *)actionBar {
    NSInteger likes = [[self.gallery valueForKey:@"likes"] integerValue];
    
    if ([[self.gallery valueForKey:@"liked"] boolValue]) {
        [[FRSAPIClient sharedClient] unlikeGallery:self.gallery completion:^(id responseObject, NSError *error) {
            NSLog(@"UNLIKED %@", (!error) ? @"TRUE" : @"FALSE");
            if (error) {
                [actionBar handleHeartState:TRUE];
                [actionBar handleHeartAmount:likes];
            }
        }];
        
    }
    else {
        [[FRSAPIClient sharedClient] likeGallery:self.gallery completion:^(id responseObject, NSError *error) {
            NSLog(@"LIKED %@", (!error) ? @"TRUE" : @"FALSE");
            if (error) {
                [actionBar handleHeartState:FALSE];
                [actionBar handleHeartAmount:likes];
            }
        }];
    }
}

-(void)handleRepost:(FRSContentActionsBar *)actionBar {
    BOOL state = [[self.gallery valueForKey:@"reposted"] boolValue];
    NSInteger repostCount = [[self.gallery valueForKey:@"reposts"] boolValue];
    
    [[FRSAPIClient sharedClient] repostGallery:self.gallery completion:^(id responseObject, NSError *error) {
        NSLog(@"REPOSTED %@", error);
        
        if (error) {
            [actionBar handleRepostState:!state];
            [actionBar handleRepostAmount:repostCount];
        }
    }];
}

#pragma mark - IBAction


@end
