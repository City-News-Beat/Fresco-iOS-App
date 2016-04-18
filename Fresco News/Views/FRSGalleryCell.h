//
//  FRSGalleryCell.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGalleryView.h"

@class FRSGallery;

@interface FRSGalleryCell : UITableViewCell <FRSGalleryViewDelegate>

@property (strong, nonatomic) FRSGalleryView *galleryView;

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) ShareSheetBlock shareBlock;
@property (strong, nonatomic) AVPlayer *player;
@property (weak, nonatomic) UINavigationController *navigationController;
@property BOOL hasVideoAsFirstPost;
-(void)clearCell;
-(void)configureCell;

-(void)play;
-(void)pause;

@end
