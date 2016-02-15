//
//  FRSPhotoMotionCollectionViewCell.h
//  Fresco
//
//  Created by Team Fresco on 3/4/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSPhotoMotionCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *caption;

+ (NSString *)identifier;

- (void)cancelImageRequest;
- (void)setImageWithURL:(NSURL *)imageURL;

@end
