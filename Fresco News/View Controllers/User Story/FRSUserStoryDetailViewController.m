//
//  FRSUserStoryDetailViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailViewController.h"


@interface FRSUserStoryDetailViewController ()

@property (strong, nonatomic) FRSUserStory *userStory;

@end

@implementation FRSUserStoryDetailViewController

- (instancetype)initWithUserStory:(FRSUserStory *)userStory {
    self = [super init];
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        
        self.userStory = userStory;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
}

- (void)configureUI {
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    
    // Ideally we would just use self.navigationController, but it's nil for some reason. Needs to be debugged, might have to do with presenting an nib.
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBar = (UITabBarController *)appDelegate.tabBarController;
    UINavigationController *nav = [tabBar.viewControllers firstObject];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName :[UIFont notaBoldWithSize:17]}];
    
//    self.title = self.userStory.location.uppercaseString;
    
    // DEBUG
    self.title = @"VANCOUVER, BC";
}

@end
