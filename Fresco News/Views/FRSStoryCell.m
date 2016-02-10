//
//  FRSStoryTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryCell.h"

#import "FRSStory.h"

#import "UIView+Helpers.h" //UIView+Helpers.h vs BaseView.h
#import "UIColor+Fresco.h"

@implementation FRSStoryCell

-(void)awakeFromNib {

}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void)configureCell {
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.storyView = [[FRSStoryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 13) story:self.story delegate:self];
    
    [self addSubview:self.storyView];
}

-(void)clearCell{
    [self.storyView removeFromSuperview];
}


#pragma mark - DataSource For Action Bar
-(BOOL)shouldHaveActionBar{
    return YES;
}

-(BOOL)shouldHaveTextLimit{
    return YES;
}

@end
