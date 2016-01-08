//
//  FRSGalleryCell.m
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryCell.h"

#import "FRSGallery.h"

#import "UIView+Helpers.h"
#import "UIColor+Fresco.h"

@implementation FRSGalleryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier gallery:(FRSGallery *)gallery{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.gallery = gallery;
    }
    return self;
}

-(void)configureCell{
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20) gallery:self.gallery dataSource:self];
    self.galleryView.dataSource = self;
    [self addSubview:self.galleryView];
    
//    [self addSubview:[UIView lineAtPoint:CGPointMake(0, self.frame.size.height - 0.5)]];

}

-(NSInteger)heightForImageView{
    return 350;
}

-(NSInteger)numberOfLinesForTextView{
    return 5;
}

@end
