//
//  FRSAssignmentPickerTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 5/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAssignmentPickerTableViewCell.h"
#import "FRSAssignment.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

@interface FRSAssignmentPickerTableViewCell ()

@property (strong, nonatomic) UIImageView *selectionImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation FRSAssignmentPickerTableViewCell
@synthesize isSelectedAssignment = _isSelectedAssignment;
-(void)awakeFromNib {
//    [super awakeFromNib];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assignment:(NSArray *)assignment {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        self.assignment = assignment;
        
        self.selectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 16 - 24, 10, 24, 24)];
        
//        [self toggleImage];
        self.isSelectedAssignment = FALSE;
        
        [self addSubview:self.selectionImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
        self.titleLabel.textColor = [UIColor frescoDarkTextColor];
        [self addSubview:self.titleLabel];
        
        
        NSArray *outlets = [self.assignment objectForKey:@"outlets"];
        if (outlets.count > 1) {
            NSLog(@"more than one outlet for assignment %@", [self.assignment objectForKey:@"title"]);
        }

    }
    
    return self;
}

-(void)configureAssignmentCellForIndexPath:(NSIndexPath *)indexPath {
    
    self.selectionImageView.frame = CGRectMake(self.frame.size.width - 16 - 24, 10, 24, 24);
    self.titleLabel.frame = CGRectMake(16, 12, self.frame.size.width - 32 - 24 - 16, 20);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.isSelectedAssignment = FALSE;
    
    self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    
    if (self.assignment) {
        self.titleLabel.text = [self.assignment objectForKey:@"title"];
        
    } else {
        self.titleLabel.text = @"No assignment";
    }
    
    //    if (indexPath.row == 0) {
    //        self.isSelectedAssignment = YES;
    //    }
}

-(BOOL)isSelectedAssignment {
    return _isSelectedAssignment;
}

-(void)setIsSelectedAssignment:(BOOL)isSelectedAssignment {
    _isSelectedAssignment = isSelectedAssignment;
    
    if (self.isSelectedAssignment) {
        self.selectionImageView.image = [UIImage imageNamed:@"check-box-circle-filled"];
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else {
        self.selectionImageView.image = [UIImage imageNamed:@"check-box-circle-outline"];
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    }
}

-(void)clearCell {
    self.titleLabel.text = nil;
    self.isSelectedAssignment = NO;
}




//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier outlet:(NSArray *)outlet {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self) {
//        
//        NSArray *outlets = [self.assignment objectForKey:@"outlets"];
//        
//        if (outlets.count > 1) {
//            NSLog(@"more than one outlet");
//        }
//        
//        //self.outlet = outlet;
//        self.backgroundColor = [UIColor frescoBackgroundColorLight];
//        self.selectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 16 - 24, 10, 24, 24)];
//        
//        self.isSelectedAssignment = NO;
//        
//        [self addSubview:self.selectionImageView];
//        
//        [self addSubview:self.selectionImageView];
//        
//        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 12, 100, 20)];
//        self.titleLabel.textColor = [UIColor frescoDarkTextColor];
//        [self addSubview:self.titleLabel];
//    }
//    
//    return self;
//}


-(void)configureOutletCellForIndexPath:(NSIndexPath *)indexPath {
    self.selectionImageView.frame = CGRectMake(self.frame.size.width - 16 - 24, 10, 24, 24);
    self.titleLabel.frame = CGRectMake(32, 12, self.frame.size.width - 32 - 24 - 16, 20);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.isSelectedAssignment = FALSE;
    
    self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    
    if (self.assignment) {
        self.titleLabel.text = [self.assignment objectForKey:@"title"];
        
    }
}



@end
