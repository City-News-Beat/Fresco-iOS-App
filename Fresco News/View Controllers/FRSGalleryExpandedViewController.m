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

#define TOP_PAD 46
#define CELL_HEIGHT 62

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, FRSGalleryViewDelegate, UITableViewDataSource, UITableViewDelegate, FRSCommentsViewDelegate, FRSContentActionBarDelegate, UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) FRSGallery *gallery;

@property (strong, nonatomic) FRSGalleryView *galleryView;
@property (strong, nonatomic) FRSCommentsView *commentsView;
@property (strong, nonatomic) FRSContentActionsBar *actionBar;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITableView *articlesTV;

@property (strong, nonatomic) NSArray *orderedArticles;

@property (nonatomic) BOOL addCommentState;

@property (nonatomic) BOOL touchEnabled;

@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) UITableView *commentTableView;
@end

@implementation FRSGalleryExpandedViewController

static NSString *reusableCommentIdentifier = @"commentIdentifier";

-(instancetype)initWithGalleryID:(NSString *)galleryID{
    self = [super init];
    if (self){
//        self.gallery = gallery;
//        self.orderedArticles = [self.gallery.articles allObjects];
//        self.hiddenTabBar = YES;
//        self.actionBarVisible = YES;
//        self.touchEnabled = NO;
        [self fetchCommentsWithID:galleryID];
        [self configureBackButtonAnimated:NO];
    }
    return self;
}


-(instancetype)initWithGallery:(FRSGallery *)gallery{
    self = [super init];
    if (self){
        self.gallery = gallery;
        self.orderedArticles = [self.gallery.articles allObjects];
        self.hiddenTabBar = YES;
        self.actionBarVisible = YES;
        self.touchEnabled = NO;
        [self fetchCommentsWithID:gallery.uid];
    }
    return self;
}


-(void)fetchCommentsWithID:(NSString  *)galleryID {
    [[FRSAPIClient sharedClient] fetchCommentsForGalleryID:galleryID completion:^(id responseObject, NSError *error) {
        if (error || !responseObject) {
            [self commentError:error];
            return;
        }
        
        _comments = [[NSMutableArray alloc] init];
        
        for (NSDictionary *comment in responseObject) {
            FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:comment];
            [_comments addObject:commentObject];
        }
        
        
        [self configureComments];

    }];
}

-(void)commentError:(NSError *)error {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self register3DTouch];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.navigationItem.titleView = self.titleLabel;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationItem.titleView = self.titleLabel;
}

-(void)popViewController{
    [super popViewController];
    [self showTabBarAnimated:YES];
}

-(void)configureNavigationBar{
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
}


-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height - 44)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

-(void)playerWillPlay:(FRSPlayer *)player {
    
}

-(void)configureGalleryView{
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 500) gallery:self.gallery delegate:self];
    [self.scrollView addSubview:self.galleryView];
    
//    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height)]];
}

-(void)configureArticles{
    
    if (self.orderedArticles.count == 0) {
        return;
    }
    
    self.articlesTV = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height + TOP_PAD, self.view.frame.size.width, CELL_HEIGHT * self.orderedArticles.count)];
    self.articlesTV.delegate = self;
    self.articlesTV.dataSource = self;
    self.articlesTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.articlesTV.backgroundColor = [UIColor whiteColor];
    self.articlesTV.scrollEnabled = NO;
    [self.scrollView addSubview:self.articlesTV];
    
    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.articlesTV.frame.origin.y - 0.5)]];
    
    
    if (self.orderedArticles.count > 0) {
        UILabel *articlesLabel = [[UILabel alloc] init];
        articlesLabel.text = @"ARTICLES";
        articlesLabel.textColor = [UIColor frescoMediumTextColor];
        articlesLabel.font = [UIFont notaBoldWithSize:15];
        [articlesLabel sizeToFit];
        [articlesLabel setOriginWithPoint:CGPointMake(16, self.articlesTV.frame.origin.y - 5 - articlesLabel.frame.size.height)];
        [self.scrollView addSubview:articlesLabel];
    }
}

-(void)configureComments{
    
    float height = 0;
    NSInteger index = 0;
    
    for (FRSComment *comment in _comments) {
        FRSCommentCell *cell = (FRSCommentCell *)[self tableView:_commentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        float commentSize = cell.commentTextField.frame.size.height;
        
        if (commentSize < 56) {
            height += 56;
        }
        else {
            height += commentSize;
        }
        
        index++;
    }
    
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height + self.articlesTV.frame.size.height + TOP_PAD + TOP_PAD, self.view.frame.size.width, height)];
    self.commentTableView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.backgroundColor = [UIColor whiteColor];
    self.commentTableView.scrollEnabled = NO;
    [self.scrollView addSubview:self.commentTableView];
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.commentTableView.frame.origin.y - 0.5)]];
    self.commentTableView.backgroundColor = [UIColor clearColor];
    self.commentTableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"FRSCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reusableCommentIdentifier];
    
    if (self.comments.count > 0) {
        UILabel *articlesLabel = [[UILabel alloc] init];
        articlesLabel.text = @"COMMENTS";
        articlesLabel.textColor = [UIColor frescoMediumTextColor];
        articlesLabel.font = [UIFont notaBoldWithSize:15];
        [articlesLabel sizeToFit];
        [articlesLabel setOriginWithPoint:CGPointMake(16, self.commentTableView.frame.origin.y - 5 - articlesLabel.frame.size.height)];
        [self.scrollView addSubview:articlesLabel];
    }
    
    [self adjustScrollViewContentSize];
}

-(void)configureActionBar{
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.view.frame.size.height - 64 - 44) delegate:self];
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

}

-(void)adjustScrollViewContentSize{
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.galleryView.frame.size.height + self.articlesTV.frame.size.height + self.commentTableView.frame.size.height + TOP_PAD * 2 + 50 + TOP_PAD);
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
    
    if (scrollView.contentOffset.y >= [self toggleActionBarOffsetPoint] && !self.addCommentState){
        self.addCommentState = YES;
        [self.actionBar actionButtonTitleNeedsUpdate];
    }
    else if (scrollView.contentOffset.y < [self toggleActionBarOffsetPoint] && self.addCommentState){
        self.addCommentState = NO;
        [self.actionBar actionButtonTitleNeedsUpdate];
    }
    
}

-(NSInteger)toggleActionBarOffsetPoint{
    return self.galleryView.frame.size.height + TOP_PAD + (self.gallery.articles.count * CELL_HEIGHT);
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
        
        return self.comments.count;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _articlesTV) {
        return CELL_HEIGHT;
    }
    
    if (tableView == _commentTableView) {
        if (indexPath.row < self.comments.count) {
            FRSCommentCell *cell = (FRSCommentCell *)[self tableView:_commentTableView cellForRowAtIndexPath:indexPath];
            NSInteger height = cell.commentTextField.frame.size.height;
            
            if (height < 56) {
                return 56;
            }
            
            return height;
        }
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _articlesTV) {
        FRSArticlesTableViewCell *cell = [[FRSArticlesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article-cell" article:self.orderedArticles[indexPath.row]];
        return cell;
    }
    else if (tableView == _commentTableView) {
        FRSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCommentIdentifier];
        if (indexPath.row < self.comments.count) {
            FRSComment *comment = _comments[indexPath.row];

            if (comment.imageURL) {
                [cell.profilePicture hnk_setImageFromURL:[NSURL URLWithString:comment.imageURL]];
            }
            else {
                // default
            }
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
    
    return Nil;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([URL.absoluteString containsString:@"name"]) {
        NSString *user = [URL.absoluteString stringByReplacingOccurrencesOfString:@"name://" withString:@""];
        NSLog(@"USER: %@", user);
        FRSProfileViewController *viewController = [[FRSProfileViewController alloc] initWithUserName:user];
        self.navigationItem.title = @"";
        [self.tabBarController.tabBar setHidden:YES];
        [self.navigationController pushViewController:viewController animated:YES];
        
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
    if (self.addCommentState){
        return @"ADD A COMMENT";
    }
    else {
        return [NSString stringWithFormat:@"6 COMMENTS"];
    }
}

-(UIColor *)colorForActionButton{
    return [UIColor frescoBlueColor];
}

-(void)contentActionBarDidSelectActionButton:(FRSContentActionsBar *)actionBar{
    if (self.addCommentState){
        
    }
    else {
        [self.scrollView setContentOffset:CGPointMake(0, [self toggleActionBarOffsetPoint]) animated:YES];
        [self scrollViewDidScroll:self.scrollView];
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
