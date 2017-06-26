//
//  FRSUserStoryDetailCommentsTableView.m
//  Fresco
//
//  Created by Omar Elfanek on 6/26/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailCommentsTableView.h"
#import "FRSCommentCell.h"

@interface FRSUserStoryDetailCommentsTableView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FRSUserStory *userStory;

@end

@implementation FRSUserStoryDetailCommentsTableView

- (void) configureCommentsTableViewWithUserStory:(FRSUserStory *)userStory {
    self.delegate = self;
    self.dataSource = self;
    self.userStory = userStory;
}



- (nonnull UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FRSCommentCell *commentCell = [[FRSCommentCell alloc] init];
    commentCell.backgroundColor = [UIColor redColor];
    // [commentCell configureCell:[self.userStory.comments objectAtIndex:indexPath.row] delegate:self];
    [commentCell configureCell:nil delegate:nil];
    return commentCell;
}

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return self.userStory.comments.count;
    return 12;
}



@end
