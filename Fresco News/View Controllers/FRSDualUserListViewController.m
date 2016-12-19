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
    
    [self fetchLikers];
    [self fetchReposters];
}

-(void)configureNavigationBar {
    
    // default config
    [super configureBackButtonAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)fetchLikers {
    [[FRSAPIClient sharedClient] fetchRepostsForGallery:self.galleryID completion:^(id responseObject, NSError *error) {
        
        if (responseObject) {
            self.repostedUsers = responseObject;
        }
        
        if (error) {
            // frog it
        }
        
    }];
}

-(void)fetchReposters {
    [[FRSAPIClient sharedClient] fetchLikesForGallery:self.galleryID completion:^(id responseObject, NSError *error) {
        
        if (responseObject) {
            self.likedUsers = responseObject;
        }
        
        if (error) {
            // frog it
        }
    }];
}



@end
