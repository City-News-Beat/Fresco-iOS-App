//
//  StoryCellHeader.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSPost, FRSGallery;

@interface StoryCellHeader : UITableViewCell
+ (NSString *)identifier;
- (void)setPost:(FRSPost *)post;
- (void)setGallery:(FRSGallery *)post;
@end
