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



@end
