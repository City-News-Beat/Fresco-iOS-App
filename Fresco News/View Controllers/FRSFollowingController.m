//
//  FRSFollowingController.m
//  Fresco
//
//  Created by Philip Bernstein on 6/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowingController.h"
#import "FRSGalleryCell.h"
#import "FRSStoryCell.h"
#import "FRSAPIClient.h"
#import "Fresco.h"
#import "FRSAwkwardView.h"
#import "UIColor+Fresco.h"

@implementation FRSFollowingController
@synthesize tableView = _tableView, feed = _feed;


-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)setFeed:(NSArray *)feed {
    _feed = feed;
    
    NSLog(@"SET FEED: %@", feed);
}

-(NSArray *)feed {
    return _feed;
}
-(void)goToExpandedGalleryForContentBarTap:(NSIndexPath *)notification {
    if (self.delegate) {
        [self.delegate galleryClicked:self.feed[notification.row]];
    }
}
-(void)commonInit {
    NSLog(@"COMMON INIT");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToExpandedGalleryForContentBarTap:) name:@"GalleryContentBarActionTapped" object:nil];

    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        NSLog(@"LOADED: %@ %@", galleries, error);
        
        if (galleries.count == 0) {
            FRSAwkwardView *awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2 - 175/2, self.tableView.frame.size.height/2 -125/2 +64, 175, 125)];
            [self.tableView addSubview:awkwardView];
            self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        
        [loadingView removeFromSuperview];
        
        self.feed = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:FALSE];
        [self.tableView reloadData];
    }];
}

-(void)reloadData {
    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        NSLog(@"LOADED: %@ %@", galleries, error);
        
        if (galleries.count == 0) {
            FRSAwkwardView *awkwardView = [[FRSAwkwardView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2 - 175/2, self.tableView.frame.size.height/2 -125/2 +64, 175, 125)];
            [self.tableView addSubview:awkwardView];
            self.tableView.backgroundColor = [UIColor frescoBackgroundColorDark];
        }
        
        [loadingView removeFromSuperview];
        
        self.feed = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:FALSE];
        [self.tableView reloadData];
    }];
}

-(void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.frame = CGRectMake((_tableView.frame.size.width-loadingView.frame.size.width)/2, _tableView.frame.size.height/2, loadingView.frame.size.width, loadingView.frame.size.height);
    
    [loadingView startAnimating];
    [_tableView addSubview:loadingView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(UITableView *)tableView {
    return _tableView;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if ([[[self.feed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
        
        if (!cell){
            cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        }
    }
    else if ([[[self.feed objectAtIndex:indexPath.row] class] isSubclassOfClass:[FRSStory class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"story-cell"];
        
        if (!cell){
            cell = [[FRSStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"story-cell"];
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        FRSGalleryCell *galCell = (FRSGalleryCell *)cell;
        [galCell clearCell];
            
        galCell.gallery = self.feed[indexPath.row];
        
        __weak typeof(self) weakSelf = self;
        
        galCell.readMoreBlock = ^(NSArray *bullshit){
            [weakSelf goToExpandedGalleryForContentBarTap:indexPath];
        };
        
        [galCell configureCell];
    }
    else {
        FRSStoryCell *storyCell = (FRSStoryCell *)cell;
        [storyCell clearCell];
        
        storyCell.story = self.feed[indexPath.row];
        [storyCell configureCell];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 100;
    
    if ([[self.feed[indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
            FRSGallery *gallery = self.feed[indexPath.row];
            height = [gallery heightForGallery];
    }
    else {
        FRSStory *story = self.feed[indexPath.row];
        height = [story heightForStory];
    }
    
    if (height <= 0) {
        height = 100;
    }
    
    NSLog(@"HEIGHT: %f", height);
    
    return height;
}

@end
