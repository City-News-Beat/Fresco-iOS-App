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

typedef NS_ENUM(NSInteger, UserStoryDetailSections) {
    Header,
    Media,
    //Articles,
    Comments
};

@interface FRSUserStoryDetailTableView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FRSUserStory *userStory;

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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case Header: {
            FRSUserStoryDetailHeaderTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailHeaderCellIdentifier];
            FRSUserStoryDetailHeaderCellViewModel *vm = [[FRSUserStoryDetailHeaderCellViewModel alloc] initWithUserStory:self.userStory];
            [cell configureWithStoryHeaderCellViewModel: vm];
            return cell;
        } break;
            
        case Media: {
            FRSUserStoryDetailMediaTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailMediaCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
        } break;
            
        /* case Articles: {
            FRSUserStoryDetailArticlesTableViewCell *cell = [self dequeueReusableCellWithIdentifier:storyDetailArticlesCellIdentifier];
            [cell configureWithStory:self.userStory];
            return cell;
         } break; */ // Note: Articles are currently unsupported, but may come back in the future.
            
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

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
