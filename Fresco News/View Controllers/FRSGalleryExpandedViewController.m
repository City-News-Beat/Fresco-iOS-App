//
//  FRSGalleryExpandedViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryExpandedViewController.h"

#import "FRSArticlesTableViewCell.h"

#import "FRSGallery.h"
#import "FRSArticle.h"

#import "FRSGalleryView.h"
#import "FRSCommentsView.h"
#import "FRSContentActionsBar.h"

#import "PeekPopArticleViewController.h"


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


@end

@implementation FRSGalleryExpandedViewController

-(instancetype)initWithGallery:(FRSGallery *)gallery{
    self = [super init];
    if (self){
        self.gallery = gallery;
        self.orderedArticles = [self.gallery.articles allObjects];
        self.hiddenTabBar = YES;
        self.actionBarVisible = YES;
        self.touchEnabled = NO;
    }
    return self;
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
    [self configureComments];
    [self configureActionBar];
    [self configureNavigationBar];

    [self adjustScrollViewContentSize];
}


-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64 - 44)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

-(void)configureGalleryView{
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500) gallery:self.gallery delegate:self];
    [self.scrollView addSubview:self.galleryView];
    
//    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height)]];
}

-(void)configureArticles{
    self.articlesTV = [[UITableView alloc] initWithFrame:CGRectMake(0, self.galleryView.frame.origin.y + self.galleryView.frame.size.height + TOP_PAD, self.view.frame.size.width, CELL_HEIGHT * self.orderedArticles.count)];
    self.articlesTV.delegate = self;
    self.articlesTV.dataSource = self;
    self.articlesTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.articlesTV.backgroundColor = [UIColor whiteColor];
    self.articlesTV.scrollEnabled = NO;
    [self.scrollView addSubview:self.articlesTV];
    
    [self.scrollView addSubview:[UIView lineAtPoint:CGPointMake(0, self.articlesTV.frame.origin.y - 0.5)]];
    
    UILabel *articlesLabel = [[UILabel alloc] init];
    articlesLabel.text = @"ARTICLES";
    articlesLabel.textColor = [UIColor frescoMediumTextColor];
    articlesLabel.font = [UIFont notaBoldWithSize:15];
    [articlesLabel sizeToFit];
    [articlesLabel setOriginWithPoint:CGPointMake(16, self.articlesTV.frame.origin.y - 5 - articlesLabel.frame.size.height)];
    [self.scrollView addSubview:articlesLabel];
}

-(void)configureComments{
    
    self.commentsView = [[FRSCommentsView alloc] initWithComments:[NSArray new]];
    self.commentsView.frame = CGRectMake(0, self.articlesTV.frame.origin.y + self.articlesTV.frame.size.height + TOP_PAD, self.view.frame.size.width, [self.commentsView height]);
    self.commentsView.delegate = self;
    [self.scrollView addSubview:self.commentsView];
    
    UILabel *commentsLabel = [[UILabel alloc] init];
    commentsLabel.text = @"COMMENTS";
    commentsLabel.textColor = [UIColor frescoMediumTextColor];
    commentsLabel.font = [UIFont notaBoldWithSize:15];
    [commentsLabel sizeToFit];
    [commentsLabel setOriginWithPoint:CGPointMake(16, self.commentsView.frame.origin.y - 5 - commentsLabel.frame.size.height)];
    [self.scrollView addSubview:commentsLabel];
}

-(void)configureActionBar{
    self.actionBar = [[FRSContentActionsBar alloc] initWithOrigin:CGPointMake(0, self.view.frame.size.height - 64 - 44) delegate:self];
    [self.view addSubview:self.actionBar];
    
    [self.actionBar addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
}

-(void)adjustScrollViewContentSize{
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.galleryView.frame.size.height + self.articlesTV.frame.size.height + self.commentsView.frame.size.height + TOP_PAD * 2 + 50);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FRSGalleryView Delegate

-(BOOL)shouldHaveActionBar{
    return NO;
}

-(BOOL)shouldHaveTextLimit {
    return NO;
}

-(NSInteger)heightForImageView{
    return 300;
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
    return self.orderedArticles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

-(FRSArticlesTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSArticlesTableViewCell *cell = [[FRSArticlesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article-cell" article:self.orderedArticles[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [((FRSArticlesTableViewCell *)cell) configureCell];
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
