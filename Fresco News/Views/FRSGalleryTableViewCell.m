//
//  FRSGalleryTableViewCell.m
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryTableViewCell.h"
#import "FRSGallery.h"
#import "UIView+Helpers.h"
#import "UIColor+Fresco.h"

@implementation FRSGalleryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configureCell {
    if (self.galleryView != nil) {
        hasPlayed = NO;

        [self.galleryView loadGallery:self.gallery];
        self.galleryView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20);
        return;
    }
    hasPlayed = NO;

    if (self.gallery == self.galleryView.gallery && self.galleryView && self.gallery) {
        return;
    }

    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20) gallery:self.gallery delegate:self];
    [self addSubview:self.galleryView];
    //TODO: SCroll - check if this is needed
//    self.players = self.galleryView.players;
    __weak typeof(self) weakSelf = self;
    
    self.galleryView.trackedScreen = self.trackedScreen;

    
    self.galleryView.shareBlock = ^void(NSArray *sharedContent) {
      weakSelf.shareBlock(sharedContent);
    };

    self.galleryView.readMoreBlock = ^void(NSArray *sharedContent) {
      if (weakSelf.readMoreBlock) {
          weakSelf.readMoreBlock(Nil);
      }
    };
}

- (void)offScreen {
    [self.galleryView offScreen];
}

#pragma mark - DataSource For Action Bar

- (BOOL)shouldHaveActionBar {
    return YES;
}

- (BOOL)shouldHaveTextLimit {
    return YES;
}

- (void)play {
    [self.galleryView play];
}

- (void)pause {
    [self.galleryView pause];
}

@end
