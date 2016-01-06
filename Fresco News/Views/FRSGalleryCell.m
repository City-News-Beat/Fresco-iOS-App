//
//  FRSGalleryCell.m
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryCell.h"


@implementation FRSGalleryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
    }
    return self;
}

-(void)configureCell{
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) gallery:nil dataSource:self];
    self.galleryView.dataSource = self;
    [self addSubview:self.galleryView];
}

-(NSInteger)heightForImageView{
    return 250;
}

-(NSInteger)numberOfLinesForTextView{
    return 5;
}

@end
