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

#define TOP_NAV_BAR_HEIGHT 64
#define GALLERY_BOTTOM_PADDING 16
#define CELL_HEIGHT 62

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, FRSGalleryViewDelegate, UITableViewDataSource, UITableViewDelegate, FRSCommentsViewDelegate, FRSContentActionBarDelegate, UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) FRSGallery *gallery;

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

@end

@implementation FRSGalleryExpandedViewController

static NSString *reusableCommentIdentifier = @"commentIdentifier";


-(instancetype)initWithGallery:(FRSGallery *)gallery {
    self = [super init];
    if (self){
        self.gallery = gallery;
        //        self.orderedArticles = [self.gallery.articles allObjects];
        self.hiddenTabBar = YES;
        self.actionBarVisible = YES;
        self.touchEnabled = NO;
        [self fetchCommentsWithID:gallery.uid];
    }
    return self;
}

-(instancetype)initWithGallery:(FRSGallery *)gallery comment:(NSString *)commentID {
    self = [super init];
    if (self){
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
    [FRSTracker track:@"Galleries opened from highlights" parameters:@{@"gallery_id":(self.gallery.uid != Nil) ? self.gallery.uid : @""}];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self register3DTouch];
    [self hideTabBarAnimated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationItem.titleView = self.titleLabel;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    self.navigationItem.titleView = self.titleLabel;
}

-(void)setupDeepLinkedComment:(NSString *)commentID {
    NSString *format = @"gallery/%@/comments?last=%@&dir=disc";
    NSString *endpoint = [NSString stringWithFormat:format, self.gallery.uid, commentID];
    
    [[FRSAPIClient sharedClient] get:endpoint withParameters:Nil completion:^(id responseObject, NSError *error) {
        if (error || !responseObject) {
            [self commentError:error];
            return;
        }
        
        _comments = [[NSMutableArray alloc] init];
        NSArray *response = (NSArray *)responseObject;
        for (NSInteger i = response.count-1; i >= 0; i--) {
            FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
            [_comments addObject:commentObject];
        }
        
        if ([_comments count] < 10) {
            showsMoreButton = FALSE;
        }
        else {
            showsMoreButton = TRUE;
        }
        
        [self configureComments];
    }];
}

-(void)fetchCommentsWithID:(NSString  *)galleryID {
    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:galleryID completion:^(id responseObject, NSError *error) {
        if (error || !responseObject) {
            [self commentError:error];
            return;
        }
        
        _comments = [[NSMutableArray alloc] init];
        NSArray *response = (NSArray *)responseObject;
        for (NSInteger i = response.count-1; i >= 0; i--) {
            FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
            [_comments addObject:commentObject];
        }
        
        if ([_comments count] < 10) {
            showsMoreButton = FALSE;
        }
        else {
            showsMoreButton = TRUE;
        }
        
        [self configureComments];
    }];
}

-(void)reload {
    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:self.gallery.uid completion:^(id responseObject, NSError *error) {
        if (error || !responseObject) {
            [self commentError:error];
            return;
        }
        
        _comments = [[NSMutableArray alloc] init];
        
        NSArray *response = (NSArray *)responseObject;
        for (NSInteger i = response.count-1; i >= 0; i--) {
            FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
            [_comments addObject:commentObject];
        }
        
        if (response.count < 10) {
            showsMoreButton = FALSE;
        }
        else {
            showsMoreButton = TRUE;
        }
        
        float height = 0;
        NSInteger index = 0;
        
        for (FRSComment *comment in _comments) {
            
            CGRect labelRect = [comment.comment
                                boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, INT_MAX)
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
        
        height += 55;
        
        self.commentTableView.frame = CGRectMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height + self.articlesTV.frame.size.height, self.view.frame.size.width, height);
        [self adjustScrollViewContentSize];
        [self.commentTableView reloadData];
    }];
}

-(void)commentError:(NSError *)error {
    
}



-(void)popViewController {
    [super popViewController];
    [self showTabBarAnimated:YES];
}

-(void)configureNavigationBar {
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"GALLERY";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont notaBoldWithSize:17];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = self.view.center;
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 0, self.titleLabel.frame.size.width, 44);
    
    self.navigationItem.titleView = self.titleLabel;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)configureUI{
    
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
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}


-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -TOP_NAV_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - 44)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

-(void)playerWillPlay:(FRSPlayer *)player {
}

-(void)configureGalleryView{
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, TOP_NAV_BAR_HEIGHT, self.view.frame.size.width, 500) gallery:self.gallery delegate:self];
    [self.scrollView addSubview:self.galleryView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    
    [self.galleryView addGestureRecognizer:tap];
//    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height)]];
}

-(void)configureArticles{
    
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
    [self.scrollView addSubview:self.articlesTV];
    
    if (self.orderedArticles.count > 0) {
        [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.articlesTV.frame.origin.y - 0.5)]];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteAtIndexPath:indexPath];
}

// activity_duration
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == _commentTableView) {
        
        if (showsMoreButton && indexPath.row < self.comments.count+1 && indexPath.row != 0) {
            FRSComment *comment = [self.comments objectAtIndex:indexPath.row-1];
            if (comment.isDeletable) {
                return YES;
            }
        }
        else if (!showsMoreButton && indexPath.row < self.comments.count) {
            FRSComment *comment = [self.comments objectAtIndex:indexPath.row];
            if (comment.isDeletable) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
    FRSComment *comment = self.comments[indexPath.row - 1];
    [[FRSAPIClient sharedClient] deleteComment:comment.uid fromGallery:self.gallery completion:^(id responseObject, NSError *error) {
        NSLog(@"%@", error);
        [self reload];
    }];
}

-(void)configureComments {
    float height = 0;
    NSInteger index = 0;
    
    for (FRSComment *comment in _comments) {
        
        CGRect labelRect = [comment.comment
                            boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, INT_MAX)
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
    
    height += 55;
    
    CGFloat labelOriginY = self.galleryView.frame.origin.y + self.galleryView.frame.size.height;
    if (self.comments.count > 0) {
        if (self.orderedArticles.count > 0) {
            labelOriginY += self.articlesTV.frame.size.height + self.articlesLabel.frame.size.height;
        }
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelOriginY, self.view.frame.size.width, 48)];
        self.commentLabel.text = @"COMMENTS";
        self.commentLabel.textColor = [UIColor frescoMediumTextColor];
        self.commentLabel.font = [UIFont notaBoldWithSize:15];
        [self.commentLabel setOriginWithPoint:CGPointMake(16, labelOriginY + 6)];
        [self.scrollView addSubview:self.commentLabel];
    }
    
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, labelOriginY + self.commentLabel.frame.size.height, self.view.frame.size.width, height)];
    self.commentTableView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.backgroundColor = [UIColor whiteColor];
    self.commentTableView.scrollEnabled = NO;
    [self.scrollView addSubview:self.commentTableView];
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.commentTableView.backgroundColor = [UIColor clearColor];
    self.commentTableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"FRSCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reusableCommentIdentifier];
    
    if (self.comments.count > 0) {
        [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.commentTableView.frame.origin.y - 0.5)]];
    }
    
    [self adjustScrollViewContentSize];
    [self.actionBar actionButtonTitleNeedsUpdate];
}

-(void)configureActionBar{
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.view.frame.size.height - TOP_NAV_BAR_HEIGHT - 44) delegate:self];
    self.actionBar.delegate = self;
    
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
    
    [self.actionBar addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
}

-(void)contentActionBarDidShare:(FRSContentActionsBar *)actionbar {
    FRSPost *post = [[self.gallery.posts allObjects] firstObject];
    NSString *sharedContent = [@"https://fresconews.com/gallery/" stringByAppendingString:self.gallery.uid];
    
    sharedContent = [NSString stringWithFormat:@"Check out this gallery from %@: %@", [[post.address componentsSeparatedByString:@","] firstObject], sharedContent];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[sharedContent] applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
    
    [FRSTracker track:@"Galleries shared from highlights" parameters:@{@"gallery_id":(self.gallery.uid != Nil) ? self.gallery.uid : @""}];
}

-(void)adjustScrollViewContentSize{
    CGFloat height = self.galleryView.frame.size.height + self.actionBar.frame.size.height + GALLERY_BOTTOM_PADDING;
    if (self.comments.count > 0) {
        height += self.commentTableView.frame.size.height + self.commentLabel.frame.size.height;
    }
    if (self.orderedArticles.count > 0) {
        height += self.articlesTV.frame.size.height + self.articlesLabel.frame.size.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    [self.actionBar actionButtonTitleNeedsUpdate];
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
        
        return (showsMoreButton) ? self.comments.count + 1 : self.comments.count;
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
            NSInteger height = cell.commentTextField.frame.size.height;
            
            if (height < 56) {
                return 56;
            }
            
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
            [topButton setTitle:[NSString stringWithFormat:@"%lu MORE COMMENTS", [[self.gallery valueForKey:@"comments"] intValue] - _comments.count] forState:UIControlStateNormal];
            [topButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
            [topButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
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
            if (indexPath.row < self.comments.count+showsMoreButton) {
                FRSComment *comment = _comments[indexPath.row-showsMoreButton];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (comment.imageURL && ![comment.imageURL isEqual:[NSNull null]] && ![comment.imageURL isEqualToString:@""]) {
                        NSLog(@"%@", comment.imageURL);
                        
                        cell.backgroundColor = [UIColor clearColor];
                        [cell.profilePicture hnk_setImageFromURL:[NSURL URLWithString:comment.imageURL]];
                    }
                    else {
                        // default
                        cell.backgroundColor = [UIColor frescoLightTextColor];
                        cell.profilePicture.image = [UIImage imageNamed:@"user-24"];
                    }
                });
                
                cell.commentTextField.attributedText = comment.attributedString;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.commentTextField frs_resize];
                cell.commentTextField.delegate = self;
                
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
        }
    }
    
    return Nil;
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
        }
        
        float height = 0;
        NSInteger index = 0;
        
        for (FRSComment *comment in _comments) {
            
            CGRect labelRect = [comment.comment
                                boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, INT_MAX)
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
        
        height += 55;
        
        self.commentTableView.frame = CGRectMake(0, self.commentTableView.frame.origin.y, self.view.frame.size.width, height);
        [self adjustScrollViewContentSize];
        [self.commentTableView reloadData];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([URL.absoluteString containsString:@"name"]) {
        NSString *user = [URL.absoluteString stringByReplacingOccurrencesOfString:@"name://" withString:@""];
        NSLog(@"USER: %@", user);
        FRSProfileViewController *viewController = [[FRSProfileViewController alloc] initWithUserID:user];
        self.navigationItem.title = @"";
        [self.tabBarController.tabBar setHidden:YES];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([URL.absoluteString containsString:@"tag"]) {
        NSString *search = [URL.absoluteString stringByReplacingOccurrencesOfString:@"tag://" withString:@""];
        FRSSearchViewController *controller = [[FRSSearchViewController alloc] init];
        [controller search:search];
        self.navigationItem.title = @"";
       // [self.tabBarController.tabBar setHidden:YES];
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
}

#pragma mark - Comments View Delegate

-(void)commentsView:(FRSCommentsView *)commentsView didToggleViewMode:(BOOL)showAllComments{
    [self.commentsView setSizeWithSize:CGSizeMake(self.commentsView.frame.size.width, [self.commentsView height])];
    [self adjustScrollViewContentSize];
}


#pragma mark - Action Bar Delegate and Methods

-(NSString *)titleForActionButton{
    CGRect visibleRect;
    visibleRect.origin = self.scrollView.contentOffset;
    visibleRect.size = self.scrollView.bounds.size;
    
    NSLog(@"Y : %f", visibleRect.origin.y + visibleRect.size.height - self.actionBar.frame.size.height);
    
    NSInteger offset = visibleRect.origin.y + visibleRect.size.height + TOP_NAV_BAR_HEIGHT - GALLERY_BOTTOM_PADDING - self.actionBar.frame.size.height;
    
    if (self.commentLabel.frame.origin.y > offset) {
        NSUInteger count = self.gallery ? [[self.gallery valueForKey:@"comments"] intValue] : 0;
        return [NSString stringWithFormat:@"%lu COMMENTS", (unsigned long) count];
    }
    
    return @"ADD A COMMENT";
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar{
    // comment text field comes up
    if (![[FRSAPIClient sharedClient] checkAuthAndPresentOnboard]) {
        if (!commentField) {
            commentField = [[UITextField alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, self.view.frame.size.width, 44)];
            commentField.backgroundColor = [UIColor frescoBackgroundColorLight];
            commentField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            commentField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Say something nice" attributes:@{ NSForegroundColorAttributeName : [UIColor frescoLightTextColor]}];
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
        }
        
        [commentField becomeFirstResponder];
    }
}

-(void)sendComment {
    if (!commentField.text) {
        return;
    }
    
    [[FRSAPIClient sharedClient] addComment:commentField.text toGallery:self.gallery completion:^(id responseObject, NSError *error) {
            [commentField resignFirstResponder];
            [self reload];
            [UIView animateWithDuration:.15 animations:^{
            commentField.frame = CGRectMake(-1, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width+2, 44);
        } completion:^(BOOL finished) {
            commentField.text = @"";
        }];
    }];

}

-(void)changeUp:(NSNotification *)change {
    
    [UIView animateWithDuration:.2 animations:^{
        NSDictionary *info = [change userInfo];
        
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat originY = self.view.frame.size.height - keyboardSize.height - commentField.frame.size.height;
        [commentField setFrame:CGRectMake(0, originY , commentField.frame.size.width, commentField.frame.size.height)];
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 3D Touch

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self register3DTouch];
}

-(void)register3DTouch {
    if ((self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) && (self.touchEnabled == NO)) {
        self.touchEnabled = YES;
        [self registerForPreviewingWithDelegate:self sourceView:self.articlesTV];
    }
}

-(UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    
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

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    NSURL *url = [NSURL URLWithString:viewControllerToCommit.title];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


-(void)dismissKeyboard {
    if (commentField.isEditing) {
        [commentField resignFirstResponder];
        [commentField setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, commentField.frame.size.width, commentField.frame.size.height)];
    }
}


@end
