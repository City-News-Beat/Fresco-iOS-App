//
//  FRSUserStoryDetailTableView.m
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailTableView.h"
#import "FRSUserStoryDetailHeaderTableViewCell.h"
#import "FRSUserStoryDetailMediaTableViewCell.h"
#import "FRSUserStoryDetailArticlesTableViewCell.h"
#import "FRSUserStoryDetailCommentsTableViewCell.h"
#import "FRSUserStoryDetailHeaderCellViewModel.h"
#import "FRSUserStoryManager.h"
#import "FRSCommentCell.h"
#import "FRSTableViewSectionHeaderView.h"

typedef NS_ENUM(NSInteger, UserStoryDetailSections) {
    FRSHeaderSection,
    FRSMediaSection,
    FRSCommentsSection
};

@interface FRSUserStoryDetailTableView () <UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>

@property (strong, nonatomic) FRSUserStory *userStory;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic) BOOL shouldDisplayLoadMoreCommentsButton;
@property (strong, nonatomic) FRSTableViewSectionHeaderView *sectionHeader;

@end

@implementation FRSUserStoryDetailTableView

- (instancetype)initWithFrame:(CGRect)frame userStory:(FRSUserStory *)userStory {
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.allowsSelection = NO;
        [self registerNibs];
        self.userStory = userStory;
        
        [self fetchComments];
    }
    return self;
}

- (void)registerNibs {
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailHeaderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailHeaderCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailMediaTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailMediaCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailArticlesTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailArticlesCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailCommentsCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case FRSHeaderSection:
            return 1;
            break;
            
        case FRSMediaSection:
            return 1;
            break;
            
        case FRSCommentsSection :
            return self.comments.count;
            break;
            
        default:
            return 0;
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    switch (indexPath.section) {
            
        case FRSHeaderSection: {
            FRSUserStoryDetailHeaderTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailHeaderCellIdentifier];
            FRSUserStoryDetailHeaderCellViewModel *vm = [[FRSUserStoryDetailHeaderCellViewModel alloc] initWithUserStory:self.userStory];
            [cell configureWithStoryHeaderCellViewModel: vm];
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
            return cell;
        } break;
            
        case FRSMediaSection: {
            FRSUserStoryDetailMediaTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailMediaCellIdentifier];
            [cell configureWithStory:self.userStory];
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
            return cell;
        } break;
            
        case FRSCommentsSection: {
            
            
            if (indexPath.row == 0 && self.shouldDisplayLoadMoreCommentsButton) {
                UITableViewCell *paginationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pagination-cell"];
                
                UIButton *loadMoreCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
                
                loadMoreCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
                
                
                int total = (int)[self.userStory.commentCount floatValue] - [@(self.comments.count) floatValue];
                if (total < 0 || total == (int)nil) {
                    total = 0;
                }
                
                if (total == 1) {
                    [loadMoreCommentsButton setTitle:[NSString stringWithFormat:@"Show %d comment", total] forState:UIControlStateNormal];
                } else {
                    [loadMoreCommentsButton setTitle:[NSString stringWithFormat:@"Show %d more comments", total] forState:UIControlStateNormal];
                }
                
                [loadMoreCommentsButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
                [loadMoreCommentsButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
                loadMoreCommentsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                loadMoreCommentsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
                loadMoreCommentsButton.backgroundColor = [UIColor whiteColor];
                [loadMoreCommentsButton addTarget:self action:@selector(loadMoreComments) forControlEvents:UIControlEventTouchUpInside];
                [paginationCell addSubview:loadMoreCommentsButton];
                
                paginationCell.selectionStyle = UITableViewCellSelectionStyleNone;
                paginationCell.backgroundColor = [UIColor whiteColor];
                paginationCell.backgroundView.backgroundColor = [UIColor whiteColor];
                
                return paginationCell;
                
            } else {
                
                // We shouldn't have to set the delegate in three places.
                FRSCommentCell *commentCell = [self dequeueReusableCellWithIdentifier:storyDetailCommentsCellIdentifier];
                commentCell.delegate = self;
                commentCell.cellDelegate = self;
                
                FRSComment *comment = self.comments[indexPath.row];
                [commentCell configureCell:comment delegate:self];
                commentCell.backgroundColor = [UIColor whiteColor];
                commentCell.contentView.backgroundColor = [UIColor whiteColor];
                
                commentCell.backgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
                return commentCell;
            }
            
        } break;
            
        default:
            break;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return section == FRSCommentsSection ? [[FRSTableViewSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 56) title:@"COMMENTS"] : [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == FRSCommentsSection ? 56 : 0;
}

#pragma mark Comments

- (void)fetchComments {
    [[FRSUserStoryManager sharedInstance] fetchCommentsForStoryID:self.userStory.uid completion:^(id responseObject, NSError *error) {
        
        if (error) {
            // Handle error
            return;
        }
        
        // Retreive comments from responseObject and populate array with FRSComment objects
        self.comments = [[NSMutableArray alloc] init];
        NSArray *response = (NSArray *)responseObject;
        for (NSInteger i = response.count - 1; i >= 0; i--) {
            FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:response[i]];
            [self.comments addObject:commentObject];
        }
        
        // Only display comments if comments are returned
        if (self.comments.count > 0) {
            [self showComments];
        } else {
            [self hideComments];
        }
        
        // Display "Load More" button if there are more than 10 comments
        if ((int)self.userStory.commentCount > 10) {
            self.shouldDisplayLoadMoreCommentsButton = YES;
        } else {
            self.shouldDisplayLoadMoreCommentsButton = NO;
        }
    }];
}

- (void)loadMoreComments {
    FRSComment *comment = self.comments[0];
    NSString *lastID = comment.uid;
    
//    [self configureCommentsSpinner];
    
    [[FRSUserStoryManager sharedInstance] fetchMoreComments:self.userStory
                                                     last:lastID
                                               completion:^(id responseObject, NSError *error) {
                                                   if (!responseObject || error) {
                                                       return;
                                                   }
                                                   
                                                   int count = 0;
                                                   
                                                   for (NSDictionary *comment in responseObject) {
                                                       FRSComment *commentObject = [[FRSComment alloc] initWithDictionary:comment];
                                                       [self.comments insertObject:commentObject atIndex:0];
                                                       count++;
                                                   }
                                                   
                                                   if (count < 10 || ([self visibleCells].count - 1) == (int)self.userStory.commentCount - 10) {
                                                       self.shouldDisplayLoadMoreCommentsButton = FALSE;
                                                   } else {
                                                       self.shouldDisplayLoadMoreCommentsButton = TRUE;
                                                   }
                                                   
//                                                   [self stopCommentsSpinner];
                                                   [self reloadData];
                                               }];
}

- (void)showComments {
    [self reloadData];
}

- (void)hideComments {
    
}

#pragma mark - MGSwipeTableCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    FRSComment *comment = [self.comments objectAtIndex:[self indexPathForCell:cell].row - self.shouldDisplayLoadMoreCommentsButton];
    
    if (comment.isDeletable && comment.isReportable) {
        if (index == 0) {
            [self deleteAtIndexPath:[self indexPathForCell:cell]];
        } else if (index == 1) {
            [self.delegate reportComment:comment];            
        }
        
    } else if (comment.isDeletable && !comment.isReportable) {
        if (index == 0) {
            [self deleteAtIndexPath:[self indexPathForCell:cell]];
        }
        
    } else if (!comment.isDeletable && comment.isReportable) {
        if (index == 0) {
            [self.delegate reportComment:comment];
        }
    }
    
    return YES;
}

- (void)deleteAtIndexPath:(NSIndexPath *)indexPath {
    FRSComment *comment = self.comments[indexPath.row - self.shouldDisplayLoadMoreCommentsButton];
    [[FRSUserStoryManager sharedInstance] deleteComment:comment.uid
                                              fromStory:self.userStory
                                             completion:^(id responseObject, NSError *error) {
                                                 
                                                 if (!error) {
                                                     [self reloadData];
                                                 }
                                             }];
}




@end
