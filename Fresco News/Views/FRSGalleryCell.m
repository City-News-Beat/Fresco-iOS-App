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
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)playerWillPlay:(FRSPlayer *)player {
    if (self.delegate) {
        [self.delegate playerWillPlay:player];
    }
}

-(void)configureCell {
    
    
    if (self.galleryView != Nil) {
        
        hasPlayed = FALSE;
        
        [self.galleryView loadGallery:self.gallery];
        self.galleryView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20);
        return;
    }
    
    hasPlayed = FALSE;

    self.clipsToBounds = YES;
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.gallery == self.galleryView.gallery && self.galleryView && self.gallery) {
        return;
    }
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20) gallery:self.gallery delegate:self];
    [self addSubview:self.galleryView];
    self.players = self.galleryView.players;
    __weak typeof (self) weakSelf = self;
    
    self.galleryView.shareBlock = ^void(NSArray *sharedContent) {
        weakSelf.shareBlock(sharedContent);
    };
    
    self.galleryView.readMoreBlock = ^void(NSArray *sharedContent) {
        if (weakSelf.readMoreBlock) {
            weakSelf.readMoreBlock(Nil);
        }
    };
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}
-(void)clearCell{
    
    //[self.galleryView removeFromSuperview];
}

-(void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - DataSource For Action Bar
-(BOOL)shouldHaveActionBar{
    return YES;
}

-(BOOL)shouldHaveTextLimit{
    return YES;
}

-(void)play {
    
    if (hasPlayed) {
        return;
    }
    
    hasPlayed = TRUE;
    
    [self.galleryView play];
}
-(void)pause {
    [self.galleryView pause];
}
@end
