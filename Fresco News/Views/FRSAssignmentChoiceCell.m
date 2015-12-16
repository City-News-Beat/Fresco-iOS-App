//
//  FRSAssignmentChoiceCell.m
//  Fresco
//
//  Created by Daniel Sun on 12/16/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAssignmentChoiceCell.h"
#import "FRSAssignment.h"

@interface FRSAssignmentChoiceCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *selectionIV;

@end

@implementation FRSAssignmentChoiceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
     // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assignment:(FRSAssignment *)assignment{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.backgroundColor = [UIColor whiteBackgroundColor];
        
        self.assignment = assignment;
        
        self.selectionIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 14, 10, 24, 24)];
        [self toggleImage];
        
        [self addSubview:self.selectionIV];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 13, self.frame.size.width - 30 - 14 - 24, 18)];
        self.titleLabel.textColor = [UIColor colorWithWhite:0 alpha:0.87];
        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)configureCell{
    self.selectionIV.frame = CGRectMake(self.frame.size.width - 14 - 24, 10, 24, 24);
    self.titleLabel.frame = CGRectMake(16, 13, self.frame.size.width - 30 - 14 - 24, 18);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [self toggleImage];
    
    self.titleLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15];
    
    if (self.assignment)
        self.titleLabel.text = self.assignment.title;
    else
        self.titleLabel.text = @"No assignment";
}

-(void)clearCell{
    self.titleLabel.text = nil;
    self.isSelectedAssignment = NO;
}

-(void)toggleImage{
    if (self.isSelectedAssignment){
        self.selectionIV.image = [UIImage imageNamed:@"checkmark-circle-filled"];
        self.titleLabel.font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:15];
    }
    else {
        self.selectionIV.image = [UIImage imageNamed:@"checkmark-circle"];
        self.titleLabel.font = [UIFont fontWithName:HELVETICA_NEUE_LIGHT size:15];
    }
}

@end
