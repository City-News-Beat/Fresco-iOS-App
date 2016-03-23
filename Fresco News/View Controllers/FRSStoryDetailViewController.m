//
//  FRSStoryDetailViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 3/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryDetailViewController.h"
#import "FRSGalleryCell.h"

@interface FRSStoryDetailViewController ()

@end

@implementation FRSStoryDetailViewController
static NSString *galleryCell = @"GalleryCellReuse";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableView];
}

-(void)setupTableView {
    [self.galleriesTable registerClass:[FRSGalleryCell class] forCellReuseIdentifier:galleryCell];
    self.galleriesTable.backgroundColor = [UIColor frescoBackgroundColorLight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stories.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FRSGalleryCell *cell = (FRSGalleryCell *)[tableView dequeueReusableCellWithIdentifier:galleryCell];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FRSGalleryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // add dans stuff here
    if (![[cell class] isSubclassOfClass:[FRSGalleryCell class]]) {
        return;
    }
    
    if (indexPath.row >= self.stories.count) {
        return;
    }
    
    if (cell.gallery == self.stories[indexPath.row]) {
        return;
    }
    
    [cell clearCell];
    
    cell.gallery = self.stories[indexPath.row];
    [cell configureCell];
    
    __weak typeof(self) weakSelf = self;
    
    cell.shareBlock = ^void(NSArray *sharedContent) {
        [weakSelf showShareSheetWithContent:sharedContent];
    };

}

-(void)showShareSheetWithContent:(NSArray *)content {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:content applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

-(void)reloadData {
    [self.galleriesTable reloadData];
}

-(void)goToExpandedGalleryForContentBarTap:(NSNotification *)notification {
    
    NSArray *filteredArray = [self.stories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@", notification.userInfo[@"gallery_id"]]];
    
    if (!filteredArray.count) return;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.stories.count) {
        return 0;
    }
    
    FRSGallery *gallery = [self.stories objectAtIndex:indexPath.row];
    return [gallery heightForGallery];
}

@end
