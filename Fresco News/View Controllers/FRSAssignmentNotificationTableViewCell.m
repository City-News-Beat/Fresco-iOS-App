//
//  FRSAssignmentNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAssignmentNotificationTableViewCell.h"
#import "FRSCameraViewController.h"
#import "FRSAPIClient.h"
#import "FRSAlertView.h"

@interface FRSAssignmentNotificationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView   *line;
@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property CGFloat assignmentLat;
@property CGFloat assignmentLong;

@property (nonatomic) NSInteger generatedHeight;


@end

@implementation FRSAssignmentNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}

-(IBAction)secondaryAction:(id)sender {
    
    [self.delegate navigateToAssignmentWithLatitude:self.assignmentLat longitude:self.assignmentLong];
}

-(void)configureAssignmentCellWithID:(NSString *)assignmentID {
    
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 3;
    self.actionButton.tintColor = [UIColor blackColor];
    [self.actionButton setImage:[UIImage imageNamed:@"navigate-24"] forState:UIControlStateNormal];
    
    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
                
        self.titleLabel.text = [responseObject objectForKey:@"title"];
        self.bodyLabel.text = [responseObject objectForKey:@"caption"];
        self.assignmentLat = [[[[responseObject valueForKey:@"location"] valueForKey:@"coordinates"] objectAtIndex:0] intValue];
        self.assignmentLong = [[[[responseObject valueForKey:@"location"] valueForKey:@"coordinates"] objectAtIndex:1] intValue];

    }];
}

-(void)configureCameraCellWithAssignmentID:(NSString *)assignmentID {
    
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 3;
    self.actionButton.tintColor = [UIColor blackColor];
    
    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
        
        self.titleLabel.text = [responseObject objectForKey:@"title"];
        self.bodyLabel.text = [responseObject objectForKey:@"caption"];
        
    }];
}


-(NSInteger)heightForCell {
    
    if (_generatedHeight) {
        return _generatedHeight;
    }
    
    NSInteger height = 0;
    
    int topPadding   = 10;
    int leftPadding  = 72;
    int rightPadding = 16;
    
    self.titleLabel.font = [UIFont notaMediumWithSize:17];
    self.titleLabel.numberOfLines = 2;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(leftPadding, topPadding, self.frame.size.width -leftPadding -rightPadding, 22);
    
    topPadding = 33;
    self.bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.bodyLabel.numberOfLines = 3;
    
    CGRect labelRect = [self.bodyLabel.text
                        boundingRectWithSize:self.bodyLabel.frame.size
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15]
                                     }
                        context:nil];
    
    self.bodyLabel.frame = labelRect;
    
    height += self.titleLabel.frame.size.height;
    height += self.bodyLabel.frame.size.height;
    height += (11+10+1); //spacing
    
    return height;
}


@end
