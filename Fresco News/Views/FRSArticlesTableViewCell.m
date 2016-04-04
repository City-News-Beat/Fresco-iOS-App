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
    
    if ([self.titleLabel.text isEqualToString:@""]){
        self.titleLabel.text = self.article.articleStringURL;
        [self.titleLabel sizeToFit];
    }
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

    //Checks if the cell is selected to avoid the URL on didLoad
    if (selected) {
        NSURL *url = [NSURL URLWithString:self.article.articleStringURL];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

-(void)configureCell{
    self.sourceIV.frame = CGRectMake(16, 15, 32, 32);
    
    self.sourceIV.backgroundColor = [UIColor frescoLightTextColor];
    self.sourceIV.layer.cornerRadius = 16;
    
    UIImageView *placeHolderIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch"]];
    placeHolderIcon.frame = CGRectMake(10, 10, 12, 12);
    
    [self.sourceIV hnk_setImageFromURL:[NSURL URLWithString:self.article.imageStringURL] placeholder:nil success:^(UIImage *image) {
        [self.sourceIV hnk_setImageFromURL:[NSURL URLWithString:self.article.imageStringURL] placeholder:nil];
        self.sourceIV.backgroundColor = [UIColor clearColor];
    } failure:^(NSError *error) {
        [self.sourceIV addSubview:placeHolderIcon];
    }];
    
    self.titleLabel.frame = CGRectMake(64, 15, self.frame.size.width - 64 - 16, self.titleLabel.frame.size.height);
    self.sourceLabel.frame = CGRectMake(64, 36, self.titleLabel.frame.size.width, self.sourceLabel.frame.size.height);
    
    [self addSubview:[UIView lineAtPoint:CGPointMake(0, self.frame.size.height - 0.5)]];
}

@end
