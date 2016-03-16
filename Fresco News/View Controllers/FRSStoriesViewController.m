//
//  FRSStoriesViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "Fresco.h"

#import "FRSStoriesViewController.h"
#import "FRSSearchViewController.h"

#import "FRSStoryCell.h"

#import "FRSStory.h"

#import <MagicalRecord/MagicalRecord.h>

#import "DGElasticPullToRefresh.h"

@interface FRSStoriesViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *stories;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) UITextField *searchTextField;

@property (nonatomic) BOOL firstTime;

@end

@implementation FRSStoriesViewController

-(instancetype)init{
    self = [super init];
    if (self){
        self.firstTime = YES;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self configureUI];
    [self fetchStories];
}


#pragma mark - Configure UI

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureTableView];
    [self configurePullToRefresh];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (!self.firstTime) [self fetchStories];
    
    self.firstTime = NO;
}

#pragma mark -  UI

-(void)configureNavigationBar{
    
    //    [super configureNavigationBar];
    [super removeNavigationBarLine];
    self.navigationItem.title = @"STORIES";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchStories)];
    
    
    //    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width, navBar.frame.size.height - 38, self.view.frame.size.width - 60, 30)];
    //    self.searchTextField.tintColor = [UIColor whiteColor];
    //    self.searchTextField.alpha = 0;
    //    self.searchTextField.delegate = self;
    //    self.searchTextField.textColor = [UIColor whiteColor];
    //    self.searchTextField.returnKeyType = UIReturnKeySearch;
    //    [navBar addSubview:self.searchTextField];
}



-(void)configurePullToRefresh{
    [super removeNavigationBarLine];
    
    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:44 loadingViewSize:20 velocity:.34 actionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView dg_stopLoading];
        });
    } loadingView:loadingView];
    
    [self.tableView dg_setPullToRefreshFillColor:[UIColor frescoOrangeColor]];
    [self.tableView dg_setPullToRefreshBackgroundColor:self.tableView.backgroundColor];
    
}

- (void)dealloc{
    [self.tableView dg_removePullToRefresh];
}

-(void)configureTableView{
    [super configureTableView];
    
    // loading cell
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSLoadingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loadingCellIdentifier];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


#pragma mark - Search Methods
-(void)searchStories{
    //    [self animateSearch];
    
    FRSSearchViewController *searchVC = [[FRSSearchViewController alloc] init];
    [self presentViewController:searchVC animated:YES completion:nil];
}


#pragma mark - Fetch Methods

-(void)fetchStories{
    [self fetchLocalData];
    self.stories = [[NSMutableArray alloc] init];
    __block int const numToFetch = 12;

    [[FRSAPIClient new] fetchStoriesWithLimit:numToFetch lastStoryID:0 completion:^(NSArray *stories, NSError *error) {

        if (!stories.count){
            if (error) NSLog(@"Error fetching stories %@", error.localizedDescription);
            else NSLog(@"No error fetching stories but the request returned zero results");
            return;
        }
        
        for (NSDictionary *storyDict in stories){
             FRSStory *story = [FRSStory MR_findFirstByAttribute:@"uid" withValue:storyDict[@"_id"]];
                
            if (!story) {
                story = [FRSStory MR_createEntity];
                [story configureWithDictionary:storyDict];
                [self.stories addObject:story];
            }
            else {
                [self.stories addObject:story];
            }
            
            [self.tableView reloadData];
            [self cacheLocalData];
        }
       
    }];
}

-(void)fetchMoreStories {

    if (!self.stories) {
        self.stories = [[NSMutableArray alloc] init];
    }
    __block int const numToFetch = 12;
    
    [[FRSAPIClient new] fetchStoriesWithLimit:numToFetch lastStoryID:self.stories.count completion:^(NSArray *stories, NSError *error) {
        
        if (!stories.count){
            if (error) NSLog(@"Error fetching stories %@", error.localizedDescription);
            else NSLog(@"No error fetching stories but the request returned zero results");
            return;
        }
        
        for (NSDictionary *storyDict in stories){
            FRSStory *story = [FRSStory MR_findFirstByAttribute:@"uid" withValue:storyDict[@"_id"]];
            
            if (!story) {
                story = [FRSStory MR_createEntity];
                [story configureWithDictionary:storyDict];
                [self.stories addObject:story];
            }
            else {
                [self.stories addObject:story];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            [self cacheLocalData];
        }
        
    }];

}

-(void)fetchLocalData {
    
}

-(void)cacheLocalData {
    
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.stories.count == 0) ? 0 : self.stories.count+1;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == self.stories.count-1) {
        return 40;
    }
    
    if (!self.stories.count) return 0;
    
    if (indexPath.row >= self.stories.count) {
        return 40;
    }
    
    FRSStory *story = self.stories[indexPath.row];
    return [story heightForStory];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // if we're loading more data
    if (indexPath.row == self.stories.count -1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    FRSStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
    if (!cell){
        cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == self.stories.count - 5) {
        [self fetchMoreStories];
    }
    
    return cell;
}


#pragma mark UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSStoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![[cell class] isSubclassOfClass:[FRSStoryCell class]]) {
        return;
    }
    
    [cell clearCell];
    
    if (indexPath.row < self.stories.count) {
        cell.story = self.stories[indexPath.row];
        [cell configureCell];
    }
}

@end