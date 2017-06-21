//
//  FRSTipsViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsViewController.h"
#import "FRSTipsHeaderView.h"
#import "FRSTipsSupportFooterView.h"
#import "FRSTipsTableViewCell.h"
#import "FRSTip.h"

#import <Smooch/Smooch.h>

#define TIPS_CELL_ID @"tips-cell"

@interface FRSTipsViewController () <UITableViewDelegate, UITableViewDataSource, FRSTipsSupportFooterViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *videosArray;
@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *spinner;

@end


@implementation FRSTipsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self fetchVideos];
}



#pragma mark - YouTube Fetching

/**
 Fetches videos from the Fresco tutorial playlist on YouTube.
 */
- (void)fetchVideos {
    [[FRSTipsManager sharedInstance] fetchTipsWithCompletion:^(id videos, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (videos) {
                self.videosArray = videos[@"items"];
                [self.tableView reloadData];
                [self configureFooterView];
            } else {
                [self presentGenericError];
            }
            
            self.spinner.alpha = 0;
        });
    }];
}




#pragma mark - UI Configuration

- (void)configureUI {
    [self configureNavigationBar];
    [self configureTableView];
    [self configureSpinner];
}

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"TIPS";
    [self.navigationController.navigationBar setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17] }];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *chatBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat-bubbles"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSmooch)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[ chatBarButtonItem ];
}

- (void)configureTableView {
    NSInteger topPadding = 48;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topPadding, self.view.frame.size.width, self.view.frame.size.height - topPadding)];
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTipsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TIPS_CELL_ID];

    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = [[FRSTipsHeaderView alloc] init];
}


/**
 Footerview config is pulled out of tableview configuration because we need to wait until the tableview has been populated
 before adding the footerview. Otherwise the footerview looks out of place and overlaps with the loading spinner.
 */
- (void)configureFooterView {
    self.tableView.tableFooterView = [[FRSTipsSupportFooterView alloc] initWithDelegate:self];
}



#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videosArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 122;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FRSTipsTableViewCell *tipsCell = [self.tableView dequeueReusableCellWithIdentifier:TIPS_CELL_ID];
    
    FRSTip *tip = [[FRSTip alloc] initWithDictionary:[self.videosArray objectAtIndex:indexPath.row]];
    
    [tipsCell configureWithTitle:tip.title
                        subtitle:tip.subtitle
                    thumbnailURL:tip.thumbnailURL
                        videoURL:tip.videoURL];
    
    return tipsCell;
}



#pragma mark - Loading Spinner

- (void)configureSpinner {
    self.spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.spinner.frame = CGRectMake(self.tableView.frame.size.width / 2 - 10, self.tableView.frame.size.height / 2 - 10, 20, 20);
    self.spinner.tintColor = [UIColor frescoOrangeColor];
    [self.spinner setPullProgress:90];
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
}



#pragma mark - Support

/**
 Presents the in-app support chat via Smooch.
 */
- (void)presentSmooch {
    [Smooch show];
}



@end
