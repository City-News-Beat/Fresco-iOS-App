//
//  FRSCommentsView.m
//  Fresco
//
//  Created by Daniel Sun on 1/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSCommentsView.h"
#import "FRSGallery.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

#import "FRSCommentTableViewCell.h"

@interface FRSCommentsView() <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *topButton;
@property (strong, nonatomic) UITableView *tableView;
//@property (strong, nonatomic) FRSContentActionsBar *actionBar;



@end

@implementation FRSCommentsView

-(instancetype)initWithComments:(NSArray *)comments{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    if (self){
        self.comments = comments;
        [self configureTopButton];
        [self configureTableView];
        [self adjustFrames];
    }
    return self;
}

-(void)configureTopButton{
    self.topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
    [self.topButton setTitle:@"SEE ALL 6 COMMENTS" forState:UIControlStateNormal];
    [self.topButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
    [self.topButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.topButton addTarget:self action:@selector(showAllComments) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.topButton];
    
    [self.topButton addSubview:[UIView lineAtPoint:CGPointMake(0, 0)]];
    [self.topButton addSubview:[UIView lineAtPoint:CGPointMake(0, self.topButton.frame.size.height - 0.5)]];
    
}

-(void)configureTableView{
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor frescoBackgroundColorLight];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
}



#pragma mark - UITableView DataSource Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.shouldShowAllComments)
//        return self.comments.count;
        return 12;
    else
//        return MIN(5, self.comments.count);
        return 5;
}

-(FRSCommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FRSCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comment-cell"];
    if (!cell){
        cell = [[FRSCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"comment-cell" comment:nil];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [(FRSCommentTableViewCell *)cell configureCell];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 80, 0)];
    label.text =  @"salvia kitsech before they sold out high life. unami tattoed sriracha mesggings picked marfa blue bottle high lfie next level four loko pbr.";
    label.numberOfLines = 4;
    [label sizeToFit];
    
    return MAX(label.frame.size.height + 22, 56);
}

-(void)adjustFrames{
    self.tableView.frame = CGRectMake(0, self.topButton.frame.size.height, self.frame.size.width, [self tableViewHeight]);
}

-(NSInteger)tableViewHeight{
    if (self.shouldShowAllComments){
        return [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] * 12;
    }
    else {
        return [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] * 5;
    }
}

-(void)showAllComments{
    self.shouldShowAllComments = YES;
    [self.tableView reloadData];
    [self adjustFrames];
    [self.delegate commentsView:self didToggleViewMode:self.shouldShowAllComments];
}

-(NSInteger)height{
    return self.topButton.frame.size.height + [self tableViewHeight];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
