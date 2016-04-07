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

-(void)configureCell {
    self.clipsToBounds = YES;
    
    if (self.gallery == self.galleryView.gallery) {
        return;
    }
    
    if (self.galleryView != Nil) {
        [self.galleryView loadGallery:self.gallery];
        
        return;
    }
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20) gallery:self.gallery delegate:self];
    [self addSubview:self.galleryView];
    
    __weak typeof (self) weakSelf = self;
    
    self.galleryView.shareBlock = ^void(NSArray *sharedContent) {
        weakSelf.shareBlock(sharedContent);
    };
}

-(void)clearCell{
    
    //[self.galleryView removeFromSuperview];
}

#pragma mark - DataSource For Action Bar
-(BOOL)shouldHaveActionBar{
    return YES;
}

-(BOOL)shouldHaveTextLimit{
    return YES;
}

@end
