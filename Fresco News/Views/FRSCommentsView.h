//
//  FRSCommentsView.h
//  Fresco
//
//  Created by Daniel Sun on 1/15/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSGallery;


@protocol FRSCommentsViewDelegate;

@interface FRSCommentsView : UIView

@property (strong, nonatomic) NSArray *comments;

@property (nonatomic) BOOL shouldShowAllComments;

@property (weak, nonatomic) NSObject <FRSCommentsViewDelegate> *delegate;




-(instancetype)initWithComments:(NSArray *)comments;

-(NSInteger)height;

@end


@protocol FRSCommentsViewDelegate <NSObject>

-(void)commentsView:(FRSCommentsView *)commentsView didToggleViewMode:(BOOL)showAllComments;

@end