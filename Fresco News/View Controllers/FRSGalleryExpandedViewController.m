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


#define TOP_PAD 46
#define CELL_HEIGHT 62

@interface FRSGalleryExpandedViewController () <UIScrollViewDelegate, FRSGalleryViewDelegate, UITableViewDataSource, UITableViewDelegate, FRSCommentsViewDelegate>

@property (strong, nonatomic) FRSGallery *gallery;

@property (strong, nonatomic) FRSGalleryView *galleryView;
@property (strong, nonatomic) FRSCommentsView *commentsView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITableView *articlesTV;

@property (strong, nonatomic) NSArray *orderedArticles;


@end

@implementation FRSGalleryExpandedViewController

-(instancetype)initWithGallery:(FRSGallery *)gallery{
    self = [super init];
    if (self){
        self.gallery = gallery;
        self.orderedArticles = [self.gallery.articles allObjects];
        self.hiddenTabBar = YES;
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
}

-(void)popViewController{
    [super popViewController];
    [self showTabBarAnimated:YES];
}

-(void)configureNavigationBar{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"GALLERY";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont notaBoldWithSize:17];
    [titleLabel sizeToFit];
    titleLabel.center = self.view.center;
    titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 0, titleLabel.frame.size.width, 44);
    
    self.navigationItem.titleView = titleLabel;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)configureUI{
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configureScrollView];
    [self configureGalleryView];
    [self configureArticles];
    [self configureComments];

    [self adjustScrollViewContentSize];
}


-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
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

-(void)adjustScrollViewContentSize{
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.galleryView.frame.size.height + self.articlesTV.frame.size.height + self.commentsView.frame.size.height + TOP_PAD * 2);
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
