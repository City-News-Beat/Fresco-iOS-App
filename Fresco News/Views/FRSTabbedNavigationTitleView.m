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

@end

@implementation FRSTabbedNavigationTitleView



-(instancetype)initWithTabTitles:(NSArray *)tabTitles{
    
    NSAssert(tabTitles.count == 2, @"Our app only supports exactly 2 tab items for the navigation title view");
    
    self = [super initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
    if (self){
        
        self.tabTitles = tabTitles;
        
        [self configureContainerView];
        [self configureTabItems];
        [self configureNeededBarItems];
    }
    return self;
}

#pragma mark - UI Elements

-(void)configureContainerView{
    //this is necessary because the titleView item of navigation bars are automatically horizontally resized.
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.containerView.backgroundColor = [UIColor frescoOrangeColor];
    [self addSubview:self.containerView];
}

-(void)configureTabItems{
    self.firstTab = [[UIButton alloc] init];
    [self.firstTab setTitle:self.tabTitles[0] forState:UIControlStateNormal];
    [self.firstTab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.firstTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.firstTab addTarget:self.delegate action:@selector(handleFirstTabTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.firstTab sizeToFit];
    [self.containerView addSubview:self.firstTab];
    
    self.secondTab = [[UIButton alloc] init];
    [self.secondTab setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    [self.secondTab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.secondTab.titleLabel setFont:[UIFont notaBoldWithSize:17]];
    [self.secondTab sizeToFit];
    [self.secondTab addTarget:self action:@selector(handleSecondTabTapped) forControlEvents:UIControlEventTouchUpInside];
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
    self.leftBarItem = [UIButton alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
}

-(void)configureRightBarItem{
    
}


#pragma mark - Action handlers
-(void)handleFirstTabTapped{
    [self.delegate tabbedNavigationTitleViewDidTapButtonAtIndex:0];
}

-(void)handleSecondTabTapped{
    [self.delegate tabbedNavigationTitleViewDidTapButtonAtIndex:1];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
