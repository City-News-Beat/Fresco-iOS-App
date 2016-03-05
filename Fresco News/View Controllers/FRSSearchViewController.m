//
//  FRSSearchViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSearchViewController.h"
#import "FRSTableViewCell.h"

@interface FRSSearchViewController() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *searchTextField;

@end

@implementation FRSSearchViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.searchTextField resignFirstResponder];
}

-(void)configureNavigationBar{
    
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:navBar];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(12, navBar.frame.size.height -34, 24, 24);
    [dismissButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
    dismissButton.tintColor = [UIColor whiteColor];
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:dismissButton];
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(64, navBar.frame.size.height - 38, self.view.frame.size.width - 80, 30)];
    self.searchTextField.tintColor = [UIColor whiteColor];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [navBar addSubview:self.searchTextField];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchTextField becomeFirstResponder];
    });
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    clearButton.frame = CGRectMake(self.view.frame.size.width - 36, navBar.frame.size.height -34, 24, 24);
    [clearButton setImage:[UIImage imageNamed:@"delete-small-white"] forState:UIControlStateNormal];
    clearButton.tintColor = [UIColor whiteColor];
    [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:clearButton];
}

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)clear{
    NSLog(@"clear textfield");
    self.searchTextField.text = @"";
}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableView Datasource

-(void)configureTableView{
    self.title = @"";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.view addSubview:self.tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 47;
                    break;
                case 1:
                    return 56;
                    break;
                case 2:
                    return 56;
                    break;
                case 3:
                    return 56;
                    break;
                case 4:
                    return 44;
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    return 47;
                    break;
                case 1:
                    return 56;
                    break;
                case 2:
                    return 56;
                    break;
                case 3:
                    return 56;
                    break;
                case 4:
                    return 44;
                    break;
                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    return 24;
                    break;
                case 1:
                    return 44;
                    break;
                case 2:
                    return 44;
                    break;
                case 3:
                    return 44;
                    break;
                case 4:
                    return 44;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return 0;
}

-(FRSTableViewCell *)tableView:(FRSTableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier;
    FRSTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FRSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell configureSettingsHeaderCellWithTitle:@"USERS"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    [cell configureSearchUserCellWithProfilePhoto:[UIImage imageNamed:@"accepted"] fullName:@"First Last" userName:@"@firstLast" isFollowing:YES];
                    break;
                case 2:
                    [cell configureSearchUserCellWithProfilePhoto:[UIImage imageNamed:@"accepted"] fullName:@"Last First" userName:@"@lastFirst" isFollowing:NO];
                    break;
                case 3:
                    [cell configureSearchUserCellWithProfilePhoto:[UIImage imageNamed:@"accepted"] fullName:@"Froggy Frog" userName:@"@frog" isFollowing:NO];
                    break;
                case 4:
                    [cell configureSearchSeeAllCellWithTitle:@"SEE ALL 11 USERS"];
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell configureSettingsHeaderCellWithTitle:@"STORIES"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    [cell configureSearchStoryCellWithStoryPhoto:[UIImage imageNamed:@"accepted"] storyName:@"Story name goes here"];
                    break;
                case 2:
                    [cell configureSearchStoryCellWithStoryPhoto:[UIImage imageNamed:@"accepted"] storyName:@"Long story title that should maybe truncate"];
                    break;
                case 3:
                    [cell configureSearchStoryCellWithStoryPhoto:[UIImage imageNamed:@"accepted"] storyName:@"Story name goes here"];
                    break;
                case 4:
                    [cell configureSearchSeeAllCellWithTitle:@"SEE ALL 25 STORIES"];
                    break;
                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell configureSettingsHeaderCellWithTitle:@""];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    break;
                case 4:
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.searchTextField resignFirstResponder];
    
}




@end