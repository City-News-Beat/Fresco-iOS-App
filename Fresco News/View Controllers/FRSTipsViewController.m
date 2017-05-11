//
//  FRSTipsViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsViewController.h"
#import "FRSTipsHeaderView.h"
#import <Smooch/Smooch.h>
#import <AFNetworking/AFNetworking.h>
#import "FRSTipsTableViewCell.h"

static NSString *const tipsCellIdentifier = @"tips-cell";

@interface FRSTipsHeaderView () 

@end

@implementation FRSTipsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
}


#pragma mark - YouTube Fetching

- (void)fetchVideosFromYoutube {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    [manager GET:@""
      parameters:@{}
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
         
         } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {

         }];
}

#pragma mark - UI Configuration

- (void)configureUI {
    [self configureNavigationBar];
    [self configureTableView];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTipsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:tipsCellIdentifier];

    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = [[FRSTipsHeaderView alloc] init];
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 122;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRSTipsTableViewCell *tipsCell = [self.tableView dequeueReusableCellWithIdentifier:tipsCellIdentifier];
    return tipsCell;
}

#pragma mark - Support

/**
 Presents the in-app support chat via Smooch.
 */
- (void)presentSmooch {
    [Smooch show];
}



@end
