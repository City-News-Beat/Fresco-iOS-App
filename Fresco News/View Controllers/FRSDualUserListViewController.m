//
//  FRSDualUserListViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 12/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDualUserListViewController.h"

@interface FRSDualUserListViewController ()

@property (strong, nonatomic) NSString *galleryID;
@property (strong, nonatomic) NSArray *likedUsers;
@property (strong, nonatomic) NSArray *repostedUsers;

@property (strong, nonatomic) UIScrollView *horizontalScrollView;

@property (strong, nonatomic) UITableView *likesTableView;
@property (strong, nonatomic) UITableView *repostsTableView;

@end

@implementation FRSDualUserListViewController

-(instancetype)initWithGallery:(NSString *)galleryID {
    self = [super init];
    
    if (self) {

        self.galleryID = galleryID;
    
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureNavigationBar];
    [self configureScrollers];
    
    [self fetchLikers];
    [self fetchReposters];
}

-(void)configureNavigationBar {
    // default config
    [super configureBackButtonAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)configureScrollers {
    
    int tabBarHeight = 49;
    int navBarHeight = 64;
    
    self.horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight))];
    self.horizontalScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height - (tabBarHeight + navBarHeight));
    self.horizontalScrollView.pagingEnabled = YES;
    self.horizontalScrollView.bounces = NO;
    [self.view addSubview:self.horizontalScrollView];
    
    self.horizontalScrollView.backgroundColor = [UIColor redColor];
    
    self.likesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight + navBarHeight))];
    [self.horizontalScrollView addSubview:self.likesTableView];
    
    self.repostsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height - (tabBarHeight + navBarHeight))];
    [self.horizontalScrollView addSubview:self.repostsTableView];
    
    self.likesTableView.alpha = 0.5;
    self.repostsTableView.alpha = 0.5;
}

-(void)fetchReposters {
    [[FRSAPIClient sharedClient] fetchLikesForGallery:self.galleryID completion:^(id responseObject, NSError *error) {
        
        if (responseObject) {
            self.likedUsers = responseObject;
        }
        
        if (error && !responseObject) {
            // frog it
        }
    }];
}

-(void)fetchLikers {
    [[FRSAPIClient sharedClient] fetchRepostsForGallery:self.galleryID completion:^(id responseObject, NSError *error) {
        
        if (responseObject) {
            self.repostedUsers = responseObject;
        }
        
        if (error && !responseObject) {
            // frog it
        }
    }];
}



@end
