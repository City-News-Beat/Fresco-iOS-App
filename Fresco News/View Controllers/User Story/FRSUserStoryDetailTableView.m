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

@interface FRSUserStoryDetailTableView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FRSUserStory *userStory;
@property (nonatomic, retain) NSMutableArray *comments;

@end

@implementation FRSUserStoryDetailTableView

- (instancetype)initWithFrame:(CGRect)frame userStory:(FRSUserStory *)userStory {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    
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
            return cell;
        } break;
            
        case FRSMediaSection: {
            FRSUserStoryDetailMediaTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailMediaCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
        } break;
            
        case FRSCommentsSection: {
            
            // We shouldn't have to set the delegate in three places.
            FRSCommentCell *commentCell = [self dequeueReusableCellWithIdentifier:storyDetailCommentsCellIdentifier];
            commentCell.delegate = self;
            commentCell.cellDelegate = self;
            
            FRSComment *comment = self.comments[indexPath.row];
            [commentCell configureCell:comment delegate:self];
            commentCell.backgroundColor = [UIColor whiteColor];
            commentCell.contentView.backgroundColor = [UIColor whiteColor];
            
            return commentCell;
            
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    switch (section) {
        case FRSCommentsSection: {
            FRSTableViewSectionHeaderView *header = (FRSTableViewSectionHeaderView*)view;
            [view addSubview:header];
        } break;
            
        default:
            break;
    }
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


@end
