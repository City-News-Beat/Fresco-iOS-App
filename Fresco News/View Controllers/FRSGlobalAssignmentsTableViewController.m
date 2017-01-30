//
//  FRSGlobalAssignmentsTableViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 6/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGlobalAssignmentsTableViewController.h"
#import "GlobalAssignmentsTableViewCell.h"
#import "FRSCameraViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSAssignmentManager.h"

@interface FRSGlobalAssignmentsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FRSGlobalAssignmentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self configureNavigationBar];
    [self configureTableView];

    if (!self.assignments) {
        [[FRSAssignmentManager sharedInstance] getAssignmentsWithinRadius:0
                                                               ofLocation:@[ @0, @0 ]
                                                           withCompletion:^(id responseObject, NSError *error) {
                                                             if (!error && responseObject[@"global"]) {
                                                                 self.assignments = (NSArray *)responseObject[@"global"];
                                                                 [self.tableView reloadData];
                                                             }
                                                           }];
    } else {
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showTabBarAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self expandNavBar:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Configuration

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    self.title = @"GLOBAL ASSIGNMENTS";

    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17] }];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [self removeNavigationBarLine];
}

- (void)configureTableView {
    [super configureTableView];

    // -10 because navbar is about 44 and status bar is about 22 and extra fake space between cell is 12, so 44-22-12=10
    self.tableView.frame = CGRectMake(0, -self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 10);

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = YES;
    self.tableView.scrollsToTop = false;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.tableView];

    [self.tableView registerNib:[UINib nibWithNibName:@"FRSGlobalAssignmentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"global-assignment-cell"];

    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assignments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"global-assignment-cell";

    GlobalAssignmentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"global-assignment-cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configureGlobalAssignmentCellWithAssignment:[self.assignments objectAtIndex:indexPath.row]];

    if (cell == nil) {
        GlobalAssignmentsTableViewCell *cell = [[GlobalAssignmentsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier assignment:[self.assignments objectAtIndex:indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configureGlobalAssignmentCellWithAssignment:[self.assignments objectAtIndex:indexPath.row]];
    }

    __weak typeof(self) weakSelf = self;

    cell.openCameraBlock = ^{
      NSDictionary *assignment = [self.assignments objectAtIndex:indexPath.row];
      [weakSelf openCameraWithAssignment:assignment];
    };

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
}

- (void)openCameraWithAssignment:(NSDictionary *)assignment {
    // Open camera and attach assignment
    FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo selectedAssignment:nil selectedGlobalAssignment:assignment];
    UINavigationController *navControl = [[UINavigationController alloc] init];
    navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    [navControl pushViewController:cam animated:NO];
    [navControl setNavigationBarHidden:YES];

    [self presentViewController:navControl
                       animated:YES
                     completion:^{

                     }];
}

@end
