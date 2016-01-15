//
//  FRSHomeViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/7/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSHomeViewController.h"

#import "FRSGalleryExpandedViewController.h"

#import "FRSGalleryCell.h"
#import "FRSDataManager.h"

#import <MagicalRecord/MagicalRecord.h>

@interface FRSHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *highlights;
@property (strong, nonatomic) NSArray *followingGalleries;

@property (strong, nonatomic) NSArray *dataSource;

@property (strong, nonatomic) UIButton *highlightTabButton;
@property (strong, nonatomic) UIButton *followingTabButton;

@end

@implementation FRSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self addNotificationObservers];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureNavigationBar];
}

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    [self configureTableView];
    [self configureDataSource];
}

-(void)addNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];
}

#pragma mark - UI

-(void)configureNavigationBar{
    [super configureNavigationBar];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(44, 0, self.view.frame.size.width - 88, 44)];
    
    self.highlightTabButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width/2, 44)];
    [self.highlightTabButton setTitle:@"HIGHLIGHTS" forState:UIControlStateNormal];
    [self.highlightTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.highlightTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.highlightTabButton addTarget:self action:@selector(handleHighlightsTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.highlightTabButton];
    
    self.followingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, 44)];
    [self.followingTabButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.followingTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followingTabButton.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.followingTabButton addTarget:self action:@selector(handleFollowingTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.followingTabButton];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 48 - 44, -0.5, 48, 44)];
    searchButton.contentMode = UIViewContentModeCenter;
    searchButton.imageView.contentMode = UIViewContentModeCenter;
    [searchButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:searchButton];
    
    self.navigationController.navigationBar.topItem.titleView = view;
}

-(void)configureTableView{
    [super configureTableView];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64- 49);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

-(void)configureDataSource{
    
    [[FRSDataManager sharedManager] getGalleries:@{@"offset" : @0, @"hide" : @2, @"stories" : @"true"} shouldRefresh:YES withResponseBlock:^(NSArray* responseObject, NSError *error) {
        if (!responseObject.count){
            return;
        }
        
        NSMutableArray *mArr = [NSMutableArray new];
        
        NSArray *galleries = responseObject;
        for (NSDictionary *dict in galleries){
            FRSGallery *gallery = [FRSGallery MR_createEntity];
            [gallery configureWithDictionary:dict];
            [mArr addObject:gallery];
        }
        
        self.highlights = [mArr copy];
        self.dataSource = [self.highlights copy];
        [self.tableView reloadData];
    }];
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForItemAtDataSourceIndex:indexPath.row];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
    if (!cell){
        cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(NSInteger)heightForItemAtDataSourceIndex:(NSInteger)index{
    FRSGallery *gallery = self.dataSource[index];
    return [self heightForCellForGallery:gallery];
}

-(NSInteger)heightForCellForGallery:(FRSGallery *)gallery{
    
    NSInteger totalHeight = 0;
    
    for (FRSPost *post in gallery.posts){
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight == 0 || rawWidth == 0){
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        }
        else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width/rawWidth);
            totalHeight += scaledHeight;
        }
    }
    
    NSInteger averageHeight = totalHeight/gallery.posts.count;
    
    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4/3);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 32, 0)];

    label.font = [UIFont systemFontOfSize:15 weight:-1];
    label.text = gallery.caption;
    label.numberOfLines = 6;

    [label sizeToFit];
    
    averageHeight += label.frame.size.height + 12 + 44 + 20;
    
    return averageHeight;
}




#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    [cell clearCell];
    
    cell.gallery = self.dataSource[indexPath.row];
    [cell configureCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification{
    
    NSArray *filteredArray = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];
    
    if (!filteredArray.count) return;
    
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[filteredArray firstObject]];
    vc.shouldHaveBackButton = YES;
    [super showNavBarForScrollView:self.tableView animated:NO];
    
    self.navigationItem.title = @"";
    
    [self.navigationController pushViewController:vc animated:YES];
    [self hideTabBarAnimated:YES];
    
}

/*
 
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
