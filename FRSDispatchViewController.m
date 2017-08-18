//
//  FRSDispatchViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 7/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSDispatchViewController.h"
#import "FRSAuthManager.h"
#import "FRSLoginViewController.h"
#import "FRSUnratedAssignmentTableViewCell.h"
#import "FRSDateFormatter.h"
#import "NSString+Fresco.h"
//#import "FRSUsernameViewController.h"
#import "FRSAssignmentTypeViewController.h"
#import "FRSAssignmentDescriptionViewController.h"

@interface FRSDispatchViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *assignments;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FRSDispatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//     [self logoutWithPop:NO];
    
    if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
        [self configureUI];
    } else {
        [self login];
    }
}

- (void)login {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Log in"
                                          message:@"Use your name@fresconews.com"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [self configureSpinner];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   
                                   UITextField *login = alertController.textFields.firstObject;
                                   UITextField *password = alertController.textFields.lastObject;
                                   
                                   [self removeSpinner];
                                   
                                   [[FRSAuthManager sharedInstance] signIn:login.text
                                                                  password:password.text
                                                                completion:^(id responseObject, NSError *error) {
                                                                    if (responseObject) {
                                                                        [self configureUI];
                                                                    }
                                                                    
                                                                    if (error) {
                                                                        UIAlertController *alertController = [UIAlertController
                                                                                                              alertControllerWithTitle:@"Error"
                                                                                                              message:@"Unable to login."
                                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                                                        
                                                                        UIAlertAction *okAction = [UIAlertAction
                                                                                                   actionWithTitle:@"Try again"
                                                                                                   style:UIAlertActionStyleDefault
                                                                                                   handler:^(UIAlertAction *action) {
                                                                                                       
                                                                                                       [self login];
                                                                                                       
                                                                                                   }];
                                                                        
                                                                        [alertController addAction:okAction];
                                                                        [self presentViewController:alertController animated:YES completion:nil];
                                                                    }
                                                                }];
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}

- (void)configureUI {
    [self fetchAssignemnts];
    [self configureNavigationBar];
    [self configureSpinner];
    
}

- (void)configureSpinner {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.tag = 999;
    activityIndicator.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 12, [UIScreen mainScreen].bounds.size.height/2 - 12, 24, 24);
    [activityIndicator startAnimating];
}

- (void)removeSpinner {
    UIView *removeView;
    while((removeView = [self.view viewWithTag:999]) != nil) {
        [removeView removeFromSuperview];
    }
}


- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"DISPATCH";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self.navigationItem setTitleView:label];
}


- (void)fetchAssignemnts {
    
    NSDictionary *params = @{ @"assignments" : @(TRUE),
                              @"limit" : @12 };
    
    NSLog(@"LOADING...");
    
    
    // Create empty array to hold unrated assignments
    
    
    [[FRSAPIClient sharedClient] get:@"search"
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                              
                              self.assignments = [[NSMutableArray alloc] init];
                              
                              [self.refreshControl endRefreshing];
                              
                              NSLog(@"ERROR: %@", error);
                              
                              // Create a counter so we can track when the loop is complete
                              NSUInteger counter = 0;
                              
                              // Fetch individual assignments
                              for (NSMutableDictionary *assignment in responseObject[@"assignments"][@"results"]) {
                                  
                                  // Create counting to detect when loop has completed
                                  NSArray *results = responseObject[@"assignments"][@"results"];
                                  NSUInteger totalCount = results.count;
                                  counter++;
                                  
                                  // Check for if returned assignments are unrated
//                                  if ([[assignment valueForKey:@"rating"] isEqual:@1]) { // SHOULD BE 0 -- check for [nsnull null];
                                      // Add unrated assignments to array
                                      [self.assignments addObject:assignment];
//                                  }
                                      
                                  
                                  if (counter == totalCount) {
                                      // Configure and load tableView with assignments from self.assignments
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (!self.tableView) {
                                              [self configureTableView];
                                          } else {
                                              [self.tableView reloadData];
                                          }
                                      });
                                  }
                              }
                          }];
}

- (void)configureTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FRSUnratedAssignmentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"unrated-cell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadMainTableView)
                  forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = self.refreshControl;
    
}

- (void)reloadMainTableView {
    [self fetchAssignemnts];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assignments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 128;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FRSUnratedAssignmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unrated-cell"];
    
    cell.outletLabel.text = [[self.assignments objectAtIndex:indexPath.row][@"outlets"] objectAtIndex:0][@"title"];
    cell.assignmentTitleLabel.text = [self.assignments objectAtIndex:indexPath.row][@"title"];
    
    NSDate *date = [NSString dateFromString:[self.assignments objectAtIndex:indexPath.row][@"created_at"]];
    
    cell.timestampLabel.text = [NSString stringWithFormat:@"%@", [FRSDateFormatter relativeTimeFromDate:date]];
    cell.captionLabel.text = [self.assignments objectAtIndex:indexPath.row][@"caption"];
    
    if ([[self.assignments objectAtIndex:indexPath.row][@"rating"] isEqual:@1]) {
        cell.indicatorCircle.backgroundColor = [UIColor frescoGreenColor];
    } else if ([[self.assignments objectAtIndex:indexPath.row][@"rating"] isEqual:@0]) {
        cell.indicatorCircle.backgroundColor = [UIColor frescoLightTextColor];
    } else {
        cell.indicatorCircle.backgroundColor = [UIColor frescoRedColor];
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[self.assignments objectAtIndex:indexPath.row][@"rating"] isEqual:@1]) {
        FRSAssignmentDescriptionViewController *descvc = [[FRSAssignmentDescriptionViewController alloc] init];
        descvc.assignment = [self.assignments objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:descvc animated:YES];
    } else {
        FRSAssignmentTypeViewController *typevc = [[FRSAssignmentTypeViewController alloc] init];
        typevc.assignment = [self.assignments objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:typevc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
