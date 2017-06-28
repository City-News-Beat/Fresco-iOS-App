//
//  FRSUserStoryDetailCommentsTableView.m
//  Fresco
//
//  Created by Omar Elfanek on 6/26/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailCommentsTableView.h"
#import "FRSCommentCell.h"
#import "FRSUserStoryManager.h"

static NSString *reusableCommentIdentifier = @"commentIdentifier";

@interface FRSUserStoryDetailCommentsTableView () <UITableViewDelegate, UITableViewDataSource, FRSCommentCellDelegate, UITextViewDelegate>

@property (strong, nonatomic) FRSUserStory *userStory;
@property (nonatomic, retain) NSMutableArray *comments;

@end

@implementation FRSUserStoryDetailCommentsTableView

- (void) configureCommentsTableViewWithUserStory:(FRSUserStory *)userStory {
    self.delegate = self;
    self.dataSource = self;
    self.userStory = userStory;
    
    [self registerNib:[UINib nibWithNibName:@"FRSCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reusableCommentIdentifier];
    
    [self fetchComments];
}

- (void)fetchComments {
    [[FRSUserStoryManager sharedInstance] fetchCommentsForStoryID:self.userStory.uid completion:^(id responseObject, NSError *error) {
        NSLog(@"RESPONSE: %@, ERROR: %@", responseObject, error);
        
        self.comments = [[NSMutableArray alloc] init];
        NSArray *response = (NSArray *)responseObject;
        for (NSInteger i = response.count - 1; i >= 0; i--) {
            FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
            [self.comments addObject:commentObject];
        }
        
        [self reloadData];
    }];
}

#pragma mark - Tableview Delegate and Datasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRSCommentCell *commentCell = [[FRSCommentCell alloc] init];
    commentCell.backgroundColor = [UIColor redColor];
    [commentCell configureCell:[self.comments objectAtIndex:indexPath.row] delegate:self];
    return commentCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.comments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Comment Cell Delegate
- (void)didPressProfilePictureWithUserId:(NSString *)uid {
    
}



@end
