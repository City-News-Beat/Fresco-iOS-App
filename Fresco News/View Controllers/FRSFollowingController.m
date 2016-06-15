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

@implementation FRSFollowingController
@synthesize tableView = _tableView;


-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        self.feed = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:FALSE];
        [self.tableView reloadData];
    }];
}

-(void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
        [galCell configureCell];
    }
    else {
        FRSStoryCell *storyCell = (FRSStoryCell *)cell;
        [storyCell clearCell];
        
        storyCell.story = self.feed[indexPath.row];
        [storyCell configureCell];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[self.feed[indexPath.row] class] isSubclassOfClass:[FRSGallery class]]) {
            FRSGallery *gallery = self.feed[indexPath.row];
            return [gallery heightForGallery];
    }
    else {
        FRSStory *story = self.feed[indexPath.row];
        return [story heightForStory];
    }
    
    return 0;
}



@end
