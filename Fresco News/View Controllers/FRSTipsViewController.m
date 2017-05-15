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
#import "NSString+Fresco.h"

#define TIPS_CELL_ID @"tips-cell"

@interface FRSTipsHeaderView ()


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
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    [manager GET:@"https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyAPjRuCjGHO6Ra13Lt8niJ4IUtbSnukNHs&part=snippet&maxResults=25&playlistId=PLbYhNm7s63x_xM7r9eCYHgGLPI5Ora-rc"
      parameters:@{}
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
         
             if (responseObject[@"items"]) {
                 self.videosArray = responseObject[@"items"];
                 [self.tableView reloadData];
                 [self configureFooterView];

             } else {
                 [self presentGenericError];
             }
             
             self.spinner.alpha = 0;
         } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             [self presentGenericError];
             
             self.spinner.alpha = 0;
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

- (void)configureFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 72)];
    footerView.userInteractionEnabled = YES;
    self.tableView.tableFooterView = footerView;
    
    UILabel *lineOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, footerView.frame.size.width, 20)];
    lineOne.attributedText = [NSString formattedAttributedStringFromString:@"Questions? We're here to help." boldText:@""];
    [footerView addSubview:lineOne];
    
    UILabel *lineTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, footerView.frame.size.width, 20)];
    lineTwo.attributedText = [NSString formattedAttributedStringFromString:@" Chat with us. " boldText:@"Chat with us."];
    [footerView addSubview:lineTwo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentSmooch)];
    [footerView addGestureRecognizer:tap];
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
    NSDictionary *dictionary = [self.videosArray objectAtIndex:indexPath.row];
    
    NSString *videoID = dictionary[@"snippet"][@"resourceId"][@"videoId"];
    NSString *playlistID = dictionary[@"snippet"][@"playlistId"];
    
    NSString *videoURL =  [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vnd.youtube://"]] ? [NSString stringWithFormat:@"vnd.youtube://watch?v=%@&list=%@", videoID, playlistID] : [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@&list=%@", videoID, playlistID];
    [tipsCell configureWithTitle:dictionary[@"snippet"][@"title"] subtitle:dictionary[@"snippet"][@"description"] thumbnailURL:dictionary[@"snippet"][@"thumbnails"][@"medium"][@"url"] videoURL:videoURL];
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
