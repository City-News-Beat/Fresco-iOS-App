//
//  FRSUserNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserNotificationTableViewCell.h"
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"

@interface FRSUserNotificationTableViewCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;

@end

@implementation FRSUserNotificationTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        
    }
    
    return self;
}


-(void)configureDefaultCellWithNotificationTitle:(NSString *)title notificationBody:(NSString *)body {
    
    //Set default frame
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    
    
    CGFloat leftPadding  = 72;
    CGFloat rightPadding = 16;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 10, [UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding, 22)]; //
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor frescoDarkTextColor];
    self.titleLabel.font = [UIFont notaBoldWithSize:17];
    [self addSubview:self.titleLabel];
    
    
    self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 33, [UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding, 20)];
    self.bodyLabel.text = body;
    self.bodyLabel.textColor = [UIColor frescoLightTextColor];
    self.bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    [self addSubview:self.bodyLabel];
    
    
    
    self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 33, [UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding, 20)];
    self.bodyLabel.alpha = .54;
    self.bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.bodyLabel.numberOfLines = 0;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:body];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [body length])];
    
    self.bodyLabel.attributedText = attributedString ;
    self.bodyLabel.textAlignment = NSTextAlignmentCenter;
    [self.bodyLabel sizeToFit];
    self.bodyLabel.frame = CGRectMake(72, 33, [UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding, 20), self.bodyLabel.frame.size.height;
    [self addSubview:self.bodyLabel];
    
    
    [self adjustFrame];
    
}

-(void)adjustFrame {
    self.height = self.titleLabel.frame.size.height + self.bodyLabel.frame.size.height + 22;
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.height);
    self.backgroundColor = [UIColor redColor];
}


@end
