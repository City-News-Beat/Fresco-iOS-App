//
//  FRSStoriesViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoriesViewController.h"
#import "FRSSearchViewController.h"

#import "FRSStoryCell.h"
#import "FRSDataManager.h"

#import <MagicalRecord/MagicalRecord.h>

@interface FRSStoriesViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *stories;

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

-(void)configureTableView{
    [super configureTableView];
    
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
//    [[FRSDataManager sharedManager] getGalleries:@{@"offset" : @0, @"hide" : @2, @"stories" : @"true"} shouldRefresh:YES withResponseBlock:^(NSArray* responseObject, NSError *error) {
//        if (!responseObject.count){
//            return;
//        }
//        
//        NSMutableArray *mArr = [NSMutableArray new];
//        
//        NSArray *galleries = responseObject;
//        for (NSDictionary *dict in galleries){
//            FRSGallery *gallery = [FRSGallery MR_createEntity];
//            [gallery configureWithDictionary:dict];
//            [mArr addObject:gallery];
//        }
//        
//        self.stories = [mArr copy];
//        [self.tableView reloadData];
//    }];
//    
    
    [[FRSDataManager sharedManager] getStoriesWithOffset:0 shouldRefresh:NO withReponseBlock:^(id responseObject, NSError *error) {
        NSArray *stories = responseObject;
        
        NSMutableArray *mArr = [NSMutableArray new];
        
        
        for (NSDictionary *storyDict in stories){
            FRSStory *story = [FRSStory MR_createEntity];
            [story configureWithDictionary:storyDict];
            [mArr addObject:story];
        }
        
        self.stories = [mArr copy];
        [self.tableView reloadData];
    }];
    
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.stories.count;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.stories.count) return 0;
    
    FRSStory *story = self.stories[indexPath.row];
    return [story heightForStory];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
    if (!cell){
        cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


#pragma mark UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSStoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [cell clearCell];
    
    cell.story = self.stories[indexPath.row];
    
    [cell configureCell];
    
}























@end
