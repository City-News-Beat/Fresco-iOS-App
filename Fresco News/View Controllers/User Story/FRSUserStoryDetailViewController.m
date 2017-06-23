//
//  FRSUserStoryDetailViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailViewController.h"
#import "FRSUserStoryDetailTableView.h"
#import "FRSActionBar.h"

#define FOOT_PADDING 100

@interface FRSUserStoryDetailViewController () <FRSActionBarDelegate>

@property (strong, nonatomic) FRSUserStory *userStory;

@end

@implementation FRSUserStoryDetailViewController

- (instancetype)initWithUserStory:(FRSUserStory *)userStory {
    self = [super init];
    if (self) {
        self.userStory = userStory;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureNavigationBar];
    [self configureTableView];
    [self configureActionBar];
    
    [self hideTabBarAnimated:YES];
}

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    
    // Ideally we would just use self.navigationController, but it's nil for some reason. Needs to be debugged, might have to do with presenting an nib.
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBar = (UITabBarController *)appDelegate.tabBarController;
    UINavigationController *nav = [tabBar.viewControllers firstObject];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName :[UIFont notaBoldWithSize:17]}];
    
    // DEBUG
    self.title = @"VANCOUVER, BC";
    // self.title = self.userStory.location.uppercaseString;
}

- (void)configureTableView {
    FRSUserStoryDetailTableView *tableView = [[FRSUserStoryDetailTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - FOOT_PADDING) userStory:self.userStory];
    [self.view addSubview:tableView];
}

- (void)configureActionBar {
    FRSActionBar *actionBar = [[FRSActionBar alloc] initWithOrigin:CGPointMake(0, self.view.frame.size.height - 44) delegate:self];
    [self.view addSubview:actionBar];
}

@end
