//
//  FRSCommentTableViewCell.m
//  Fresco
//
//  Created by Daniel Sun on 1/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSCommentTableViewCell.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

@interface FRSCommentTableViewCell()

@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) UILabel *commentLabel;

@end

@implementation FRSCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier comment:(id)comment{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        [self configureImageView];
        [self configureLabel];
    }
    return self;
}

-(void)configureImageView{
    self.profileIV = [[UIImageView alloc] init];
    self.profileIV.clipsToBounds  = YES;
    self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.profileIV];
}

-(void)configureLabel{
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 80, 0)];
    self.commentLabel.text = @"salvia kitsech before they sold out high life. unami tattoed sriracha mesggings picked marfa blue bottle high lfie next level four loko pbr.";
    self.commentLabel.textColor = [UIColor frescoDarkTextColor];
    self.commentLabel.font = [UIFont systemFontOfSize:15 weight:-1];
    self.commentLabel.numberOfLines = 4;
    [self.commentLabel sizeToFit];
    [self addSubview:self.commentLabel];
}

-(void)configureCell{
    
    self.profileIV.frame = CGRectMake(16, 12, 32, 32);
    self.profileIV.image = [UIImage imageNamed:@"kobe"];
    self.profileIV.layer.cornerRadius = 16;
    
    [self.commentLabel centerVerticallyInView:self];
    [self.commentLabel setOriginWithPoint:CGPointMake(64, self.commentLabel.frame.origin.y)];
}

-(void)clearCell{
    self.profileIV.image = nil;
    self.commentLabel.text = nil;
}

@end
