//
//  FRSArticlesTableViewCell.m
//  Fresco
//
//  Created by Daniel Sun on 1/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSArticlesTableViewCell.h"
#import "FRSArticle.h"

#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import "UIColor+Fresco.h"

#import "Haneke.h"

@interface FRSArticlesTableViewCell()

@property (strong, nonatomic) FRSArticle *article;

@property (strong, nonatomic) UIImageView *sourceIV;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *sourceLabel;

@end

@implementation FRSArticlesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier article:(FRSArticle *)article{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        self.article = article;
        [self configureImageView];
        [self configureLabels];
    }
    return self;
}

-(void)configureImageView{
    self.sourceIV = [[UIImageView alloc] init];
    self.sourceIV.contentMode = UIViewContentModeScaleAspectFill;
    self.sourceIV.clipsToBounds = YES;
    [self addSubview:self.sourceIV];
}

-(void)configureLabels{
    self.titleLabel = [self labelWithText:self.article.title font:[UIFont notaBoldWithSize:17] color:[UIColor frescoDarkTextColor]];
    [self addSubview:self.titleLabel];
    
//    self.sourceLabel = [self labelWithText:self.article.source font:[UIFont notaRegularWithSize:13] color:[UIColor frescoMediumTextColor]];
    self.sourceLabel = [self labelWithText:@"CNN News" font:[UIFont notaRegularWithSize:13] color:[UIColor frescoMediumTextColor]];
    [self addSubview:self.sourceLabel];
}

-(UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color{
    UILabel *label = [UILabel new];
    label.textColor = color;
    label.text = text;
    label.font = font;
    [label sizeToFit];
    return label;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCell{
    self.sourceIV.frame = CGRectMake(16, 15, 32, 32);
    [self.sourceIV hnk_setImageFromURL:[NSURL URLWithString:self.article.imageStringURL] placeholder:nil];
    
    self.titleLabel.frame = CGRectMake(64, 15, self.frame.size.width - 64 - 16, self.titleLabel.frame.size.height);
    self.sourceLabel.frame = CGRectMake(64, 36, self.titleLabel.frame.size.width, self.sourceLabel.frame.size.height);
    
    [self addSubview:[UIView lineAtPoint:CGPointMake(0, self.frame.size.height - 0.5)]];
}

@end
