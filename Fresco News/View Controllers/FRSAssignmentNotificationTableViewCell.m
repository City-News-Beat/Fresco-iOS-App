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

@interface FRSAssignmentNotificationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView   *line;
@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation FRSAssignmentNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    self.actionButton.userInteractionEnabled = NO;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.actionButton setSelected:selected];

    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self.actionButton setHighlighted:highlighted];
    
    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}

-(IBAction)didTapAssignmentButton:(id)sender {
    //Does this button have an action? cc:imogen
}

-(void)configureAssignmentCellWithID:(NSString *)assignmentID {
    
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 3;
    self.actionButton.tintColor = [UIColor blackColor];
    [self.actionButton setImage:[UIImage imageNamed:@"navigate-24"] forState:UIControlStateNormal];
    
    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
                
        self.titleLabel.text = [responseObject objectForKey:@"title"];
        self.bodyLabel.text = [responseObject objectForKey:@"caption"];
        
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
