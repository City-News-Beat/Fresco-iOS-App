//
//  FRSTipsTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 5/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSTipsTableViewCell : UITableViewCell


- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle thumbnailURL:(NSString *)thumbnailURL videoURL:(NSString *)videoURL; 

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end
