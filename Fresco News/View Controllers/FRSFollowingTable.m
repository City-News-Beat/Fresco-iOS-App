//
//  FRSFollowingTable.m
//  Fresco
//
//  Created by Philip Bernstein on 4/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowingTable.h"
#import "UIColor+Fresco.h"
#import "FRSAPIClient.h"
#import "FRSAppDelegate.h"
#import "FRSScrollingViewController.h"
#import "FRSGalleryExpandedViewController.h"

@implementation FRSFollowingTable
@synthesize navigationController = _navigationController;

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(BOOL)shouldHaveTextLimit {
    return TRUE;
}

-(BOOL)shouldHaveActionBar {
    return TRUE;
}

-(void)loadGalleries:(NSArray *)galleries {
    self.galleries = galleries;
    [self reloadData];
}
-(void)commonInit {
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
    FRSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        NSMutableArray *realGalleries = [[NSMutableArray alloc] init];
        
        for (NSDictionary *gallery in galleries) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"FRSGallery"
                                                      inManagedObjectContext:appDelegate.managedObjectContext];
            FRSGallery *realGallery = [[FRSGallery alloc] initWithEntity:entity
                                              insertIntoManagedObjectContext:nil];
            //FRSGallery *realGallery = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:appDelegate.managedObjectContext];
            [realGallery configureWithDictionary:gallery context:appDelegate.managedObjectContext];
            [realGalleries addObject:realGallery];
        }
        
        [self loadGalleries:realGalleries];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FRSGalleryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gallery-cell"];
    
    if (!cell) {
        cell = [[FRSGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gallery-cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.delegate = self;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.galleries.count;
}

-(void)readMore:(NSIndexPath *)indexPath {
    FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:[self.galleries objectAtIndex:indexPath.row]];
    vc.shouldHaveBackButton = YES;
    
    FRSScrollingViewController *scroll = (FRSScrollingViewController *)self.scrollDelegate;
    
    scroll.navigationItem.title = @"";
    
    [scroll.navigationController pushViewController:vc animated:YES];
    scroll.navigationController.interactivePopGestureRecognizer.enabled = YES;
    scroll.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [(FRSScrollingViewController *)self.scrollDelegate hideTabBarAnimated:YES];

}

-(void)playerWillPlay:(AVPlayer *)player {
    for (FRSGalleryCell *cell in [self visibleCells]) {
        for (FRSPlayer *cellPlayer in cell.players) {
            if (cellPlayer != player) {
                [player pause];
            }
        }
    }
}


-(void)viewDidLayoutSubviews {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // sloppy not to have a check here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }
    
    if (cell.gallery == self.galleries[indexPath.row]) {
        return;
    }
    
    cell.gallery = self.galleries[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell clearCell];
        [cell configureCell];
    });
    
    __weak typeof(self) weakSelf = self;
    
    cell.shareBlock = ^void(NSArray *sharedContent) {
        [weakSelf showShareSheetWithContent:sharedContent];
    };
    
    cell.readMoreBlock = ^void(NSArray *sharedContent) {
        NSLog(@"TEST");
        [self readMore:indexPath];
    };
}

-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityController animated:YES completion:nil];
}

-(void)reloadData {
    [self fetchGalleries];
}

-(void)fetchGalleries {
    
}

-(void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification {
    
    NSArray *filteredArray = [self.galleries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];
    
    if (!filteredArray.count) return;
    // push gallery detail view
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.galleries.count) {
        return 0;
    }
    
    FRSGallery *gallery = [self.galleries objectAtIndex:indexPath.row];
    return [gallery heightForGallery];
}

-(void)followStory {
    NSLog(@"Follow Story");
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollDelegate) {
        [self.scrollDelegate scrollViewDidScroll:scrollView];
    }
}


@end
