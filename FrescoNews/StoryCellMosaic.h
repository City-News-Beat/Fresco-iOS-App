//
//  StoryCellMosaic.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSStory;
@interface StoryCellMosaic : UITableViewCell
@property (weak, nonatomic) FRSStory *story;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;

+ (NSString *)identifier;
@end

