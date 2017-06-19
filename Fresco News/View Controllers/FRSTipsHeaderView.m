//
//  FRSTipsHeaderView.m
//  Fresco
//
//  Created by Omar Elfanek on 5/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsHeaderView.h"
#import "UIFont+Fresco.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define ICON_SIZE 54
#define LEFT_PADDING 24

@implementation FRSTipsHeaderView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self configureUI];
    }
    return self;
}



#pragma mark - UI Configuration
- (void)configureUI {
    
    NSInteger topPadding = 88;
    
    self.frame = CGRectMake(0, topPadding, SCREEN_WIDTH, HEADER_HEIGHT);
    
    [self configureIcons];
    [self configureTitleLabel];
    [self configureBodyLabel];
}

- (void)configureIcons {
    
    NSInteger center = SCREEN_WIDTH/2 - ICON_SIZE/2;
    
        [self addImageNamed:@"wide-54"      xPosition: center];
        [self addImageNamed:@"interview-54" xPosition: center - ICON_SIZE];
        [self addImageNamed:@"pan-54"       xPosition: center + ICON_SIZE];
}

- (void)configureTitleLabel {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ICON_SIZE, SCREEN_WIDTH, LEFT_PADDING+12)];
    titleLabel.text = @"Creating a Story";
    titleLabel.textColor = [UIColor frescoDarkTextColor];
    titleLabel.font = [UIFont karminaBoldWithSize:28];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
}

- (void)configureBodyLabel {
    
    NSInteger topPadding = 48;
    NSInteger height = 80;

    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, ICON_SIZE + topPadding, SCREEN_WIDTH - LEFT_PADDING * 2, height)];
    bodyLabel.text = [self bodyStringForDevice];
    bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    bodyLabel.textColor = [UIColor frescoMediumTextColor];
    bodyLabel.numberOfLines = 0;
    bodyLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:bodyLabel];
}



#pragma mark - Helpers

/**
 Creates and adds a UIImageView with a given name at a given x position, configured with static alpha and frame values.

 @param name NSString The name of the image to be displayed.
 @param x NSInteger The x position of the image to be displayed.
 */
- (void)addImageNamed:(NSString *)name xPosition:(NSInteger)x {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    imageView.frame = CGRectMake(x, 0, ICON_SIZE, ICON_SIZE);
    imageView.alpha = 0.87;
    [self addSubview:imageView];
}

/**
 Returns an NSString formatted for the current device. The only changes made to the strings are where linebreaks are placed.
 */
- (NSString *)bodyStringForDevice {
    NSString *bodyString;
    
    if (IS_IPHONE_6_PLUS || IS_IPHONE_6) {
        bodyString = @"Need some help with shooting great footage?\nWe've got your back! Here are some tips\nto help you capture the best shots\nand create a perfect story.";
    } else {
        bodyString = @"Need some help with shooting great footage? We've got your back! Here are some tips to help you capture the best shots and create a perfect story.";
    }
    
    return bodyString;
}


@end
