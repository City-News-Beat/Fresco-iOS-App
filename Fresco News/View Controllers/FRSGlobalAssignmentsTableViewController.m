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

@interface FRSGlobalAssignmentsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FRSGlobalAssignmentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureNavigationBar];
    [self configureTableView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showTabBarAnimated:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI Configuration

-(void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    self.title = @"GLOBAL ASSIGNMENTS";
}

-(void)configureTableView {
    [super configureTableView];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSGlobalAssignmentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"global-assignment-cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assignments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    return [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height+12;
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

-(void)openCameraWithAssignment:(NSDictionary *)assignment {
    // Open camera and attach assignment
    FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo selectedAssignment:assignment];
    UINavigationController *navControl = [[UINavigationController alloc] init];
    navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
    [navControl pushViewController:cam animated:NO];
    [navControl setNavigationBarHidden:YES];
    
    [self presentViewController:navControl animated:YES completion:^{

    }];

//    FRSCameraViewController *cameraVC = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo selectedAssignment:assignment];
//    [self.navigationController pushViewController:cameraVC animated:true];
//    [self hideTabBarAnimated:true];
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(GlobalAssignmentsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    cell.backgroundColor = [UIColor redColor];
//    
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
