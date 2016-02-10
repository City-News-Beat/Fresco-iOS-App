//
//  FRSTabbedNavigationTitleView.m
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTabbedNavigationTitleView.h"

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"

@interface FRSTabbedNavigationTitleView()

@property (strong, nonatomic) UIButton *firstTab;
@property (strong, nonatomic) UIButton *secondTab;

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIButton *leftBarItem;
@property (strong, nonatomic) UIButton *rightBarItem;

@property (strong, nonatomic) NSArray *tabTitles;

@property (nonatomic) BOOL hasBackButton;

@end

@implementation FRSTabbedNavigationTitleView


-(instancetype)initWithTabTitles:(NSArray *)tabTitles delegate:(id <FRSTabbedNavigationTitleViewDelegate>)delegate hasBackButton:(BOOL)hasBackButton{
    
    NSAssert(tabTitles.count == 2, @"Our app only supports exactly 2 tab items for the navigation title view");
    
    self = [super initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
    if (self){
        
        self.tabTitles = tabTitles;
        self.delegate = delegate;
        self.hasBackButton = hasBackButton;
        
        [self configureContainerView];
        [self configureTabItems];
        [self configureNeededBarItems];
        [self adjustFrames];
    }
    return self;
}

#pragma mark - UI Elements

-(void)configureContainerView{
    //this is necessary because the titleView item of navigation bars are automatically horizontally resized.
    
//    CGRect containerFrame = self.hasBackButton ? CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 44, 44) : CGRectMake(-8, 0, [UIScreen mainScreen].bounds.size.width, 44);
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.containerView.backgroundColor = [UIColor frescoOrangeColor];
    [self addSubview:self.containerView];
}

-(void)configureTabItems{
    self.firstTab = [[UIButton alloc] init];
    [self.firstTab setTitle:self.tabTitles[0] forState:UIControlStateNormal];
    [self.firstTab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.firstTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.firstTab addTarget:self action:@selector(handleFirstTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.firstTab sizeToFit];
    [self.containerView addSubview:self.firstTab];
    
    self.secondTab = [[UIButton alloc] init];
    [self.secondTab setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.secondTab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.secondTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.secondTab sizeToFit];
    [self.secondTab addTarget:self action:@selector(handleSecondTabTapped) forControlEvents:UIControlEventTouchUpInside];
    self.secondTab.alpha = 0.7;
    [self.containerView addSubview:self.secondTab];
}

-(void)configureNeededBarItems{
    if ([self.delegate respondsToSelector:@selector(imageForLeftBarItem)]){
        [self configureLeftBarItem];
    }
    if ([self.delegate respondsToSelector:@selector(imageForRightBarItem)]){
        [self configureRightBarItem];
    }
}

-(void)configureLeftBarItem{
    // we are making the origin 4, instead of the real padding of 12, because we want to give the button a larger hit box. Therefore the size of the button also increases by 2 * 8
    self.leftBarItem = [[UIButton alloc] initWithFrame:CGRectMake(4, 2, 24 + 16, 24 + 16)];
    self.leftBarItem.contentMode = UIViewContentModeCenter;
    self.leftBarItem.imageView.contentMode = UIViewContentModeCenter;
    [self.leftBarItem setImage:[self.delegate imageForLeftBarItem] forState:UIControlStateNormal];
    [self.leftBarItem addTarget:self.delegate action:@selector(tabbedNavigationTitleViewDidTapLeftBarItem) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.leftBarItem];
}

-(void)configureRightBarItem{
    //for notes on the origin and size see the comment for the left bar item
    self.rightBarItem = [[UIButton alloc] initWithFrame:CGRectMake(self.containerView.frame.size.width - 4 - 40, 2, 24 + 16, 24 + 16)];
    self.rightBarItem.contentMode = UIViewContentModeCenter;
    self.rightBarItem.imageView.contentMode = UIViewContentModeCenter;
    [self.rightBarItem setImage:[self.delegate imageForRightBarItem] forState:UIControlStateNormal];
    [self.rightBarItem addTarget:self.delegate action:@selector(tabbedNavigationTitleViewDidTapRightBarItem) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.rightBarItem];
}

-(void)adjustFrames{
    
    //These numbers seem arbitrary but they have a purpose. Once we size to fit the buttons, they most likely have too small of a hitbox, even if the titles are long like "highlights".
    //The availableWidth is how much space left over to split evenly for the padding. The (24 + 12) is the size of the bar item and the outer padding. We disregard the padding (12) closer to the center, because we want that to be part of the available width. It's multiplied by two because there are two bar items. Then we divide by three because we want three areas of equal spacing: between the left bar item and the first tab, between the first and second tab, and between the second tab and the last bar item (regardless of whether or not the bar items exist).
    
    NSInteger availableWidth = self.containerView.frame.size.width - (24 + 12) * 2 - self.firstTab.frame.size.width - self.secondTab.frame.size.width;
    CGFloat padding = availableWidth/3;
    
    //Here, we are setting the origin of the tab to start the end of the left bar item plus half of the padding. This is because we are extending the size of the first tab so that the right edge hits the center of the container, and we know that the space between the two tabs is 'padding'. So if we extend the size of the first tab by padding, we are effectively adding padding/2 to each side of the button.
    self.firstTab.frame = CGRectMake(36 + padding/2, 0, self.firstTab.frame.size.width + padding, 44);
    
    self.secondTab.frame = CGRectOffset(self.firstTab.frame, self.firstTab.frame.size.width, 0);
}

#pragma mark - Action handlers
-(void)handleFirstTabTapped{
    
    if (self.firstTab.alpha == 1) return;
    self.firstTab.alpha = 1.0;
    self.secondTab.alpha = 0.7;
    
//    [self.delegate tabbedNavigationTitleViewDidTapButtonAtIndex:0];
}

-(void)handleSecondTabTapped{
    
    if (self.secondTab.alpha == 1) return;
    self.secondTab.alpha = 1.0;
    self.firstTab.alpha = 0.7;
    
//    [self.delegate tabbedNavigationTitleViewDidTapButtonAtIndex:1];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
