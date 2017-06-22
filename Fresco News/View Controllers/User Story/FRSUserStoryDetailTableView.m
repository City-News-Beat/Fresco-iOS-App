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

typedef NS_ENUM(NSInteger, UserStoryDetailSections) {
    Header,
    Media,
    Articles,
    Comments
};

@interface FRSUserStoryDetailTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FRSUserStoryDetailTableView

- (instancetype)initWithFrame:(CGRect)frame userStory:(FRSUserStory *)userStory {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        self.allowsSelection = NO;
        [self registerNibs];
    }
    return self;
}

- (void)registerNibs {
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailHeaderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailHeaderCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailMediaTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailMediaCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailArticlesTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailArticlesCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"FRSUserStoryDetailCommentsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:storyDetailCommentsCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case Header: {
            FRSUserStoryDetailHeaderTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailHeaderCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
        } break;
            
        case Media: {
            FRSUserStoryDetailMediaTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailMediaCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
        } break;
            
        case Articles: {
            FRSUserStoryDetailArticlesTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailArticlesCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
        } break;
            
        case Comments: {
            FRSUserStoryDetailCommentsTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailCommentsCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
        } break;
            
        default:
            break;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case Header: {
            return 275;
        } break;
            
        case Media: {
            return 300;
        } break;
            
        case Articles: {
            return 300;
        } break;
            
        case Comments: {
            return 300;
        } break;
        
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
