//
//  FRSUserNotificationViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationViewController.h"

#import "FRSDefaultNotificationTableViewCell.h"
#import "FRSTextNotificationTableViewCell.h"
#import "FRSAssignmentNotificationTableViewCell.h"

@interface FRSUserNotificationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSUserNotificationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSDefaultNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"notificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSTextNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"textNotificationCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSAssignmentNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"assignmentNotificationCell"];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}


#pragma mark - UI

-(void)configureUI {
    [self configureNavigationBar];
    [self configureTableView];
}

-(void)configureNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont notaBoldWithSize:17]}];
    self.title = @"ACTIVITY";
    
    UIBarButtonItem *userIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile-icon-light"] style:UIBarButtonItemStylePlain target:self action:@selector(segueToProfile)];
    userIcon.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = userIcon;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)configureTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    
    [self.view addSubview:self.tableView];
}


#pragma mark - Actions 

-(void)segueToProfile {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    switch (indexPath.row) {
        case 0: {
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text = @"Omar Elfanek";
            cell.bodyLabel.text  = @"Followed you.";
            cell.count = 5;
            cell.image.image = [UIImage imageNamed:@"apple-user-byrn"];
            
            [cell configureCell];
            return cell;

        } break;
            
        case 1: {
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text = @"Today in News";
            cell.bodyLabel.text  = @"My money's in that office, right? If she start giving me some bullshit about it ain't there, and we got to go.";
            cell.followButton.alpha = 0;
            cell.image.image = [UIImage imageNamed:@"apple-story-2"];
            
            [cell configureCell];
            
            return cell;
            
        } break;
            
        case 2: {
            
            NSString *cellIdentifier = @"notificationCell";
            FRSDefaultNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text = @"You have $20 expiring soon";
            cell.bodyLabel.text  = @"Add a card by Tuesday to get paid";
            cell.followButton.alpha = 0;
            
            [cell configureCell];
            
            return cell;

            
        } break;
            
        case 3: {
            
            NSString *cellIdentifier = @"textNotificationCell";
            FRSTextNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.bodyLabel.text  = @"BREAKING: Do you see any Teletubbies in here? Do you see a slender plastic tag clipped to my shirt with my name printed on it? Do you see a little Asian child with a blank expression on his face sitting outside on a mechanical helicopter that shakes when you put quarters in it? No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.";
            
            [cell configureCell];
            return cell;
            
        } break;
            
        case 4: {
            
            NSString *cellIdentifier = @"assignmentNotificationCell";
            FRSAssignmentNotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell.titleLabel.text  = @"Assignment: Raining Figs Over Tennessee";
            cell.bodyLabel.text = @"Now that there is the Tec-9, a crappy spray gun from South Miami. This gun is advertised as the most popular gun";
            cell.backgroundColor = [UIColor frescoBackgroundColorDark];
            
            [cell configureCell];
            return cell;
            
        } break;
            
        default:
            break;
    }
    
    
    UITableViewCell *cell;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}














@end
