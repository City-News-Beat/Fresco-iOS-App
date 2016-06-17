//
//  FRSStoryView.h
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fresco.h"

@class FRSStory;

@protocol FRSStoryViewDelegate <NSObject>

-(BOOL)shouldHaveActionBar;
-(BOOL)shouldHaveTextLimit;

-(void)clickedImageAtIndex:(NSInteger)imageIndex;
@end

@interface FRSStoryView : UIView

@property (weak, nonatomic) NSObject <FRSStoryViewDelegate> *delegate;
@property (strong, nonatomic) ActionButtonBlock actionBlock;
@property (strong, nonatomic) ShareSheetBlock shareBlock;
@property (strong, nonatomic) ShareSheetBlock readMoreBlock;
@property (strong, nonatomic) FRSStory *story;


-(instancetype)initWithFrame:(CGRect)frame story:(FRSStory *)story delegate:(id <FRSStoryViewDelegate>)delegate;

@end
