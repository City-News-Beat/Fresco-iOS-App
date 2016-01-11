//
//  FRSPromoCodeViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSPromoCodeViewController.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"


@interface FRSPromoCodeViewController()
@end


@implementation FRSPromoCodeViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureView];
}

-(void)configureView{

    self.title = @"PROMO CODES";
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share-icon-light"] style:UIBarButtonItemStylePlain target:self action:@selector(shareTapped)];
    
    [self configureLabels];
}

-(void)shareTapped{
    NSLog(@"share");
}

-(void)configureLabels{
    CGFloat promoWidth = 187;
    UILabel *promoCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - promoWidth/2, 48, promoWidth, 55)];
    promoCodeLabel.text = @"4YYLM40";
    promoCodeLabel.font = [UIFont notaBoldWithSize:50];
    promoCodeLabel.textColor = [UIColor frescoDarkTextColor];
    
    [self.view addSubview:promoCodeLabel];
    
    CGFloat textBlockWidth = 288;
    UILabel *textBlockLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - textBlockWidth/2, 127, textBlockWidth, 60)];
    textBlockLabel.text = @"Have your friends sign up with this code to make $20 when they respond to their first assignment, guaranteed!";
    textBlockLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    textBlockLabel.numberOfLines = 3;
    textBlockLabel.textAlignment = NSTextAlignmentCenter;
    textBlockLabel.textColor = [UIColor frescoDarkTextColor];
    [self.view addSubview:textBlockLabel];
    
    [self configureContainer];
    
    CGFloat baseLabelWidth = 190;
    UILabel *baseLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - baseLabelWidth/2, [UIScreen mainScreen].bounds.size.height - 81 - 12, baseLabelWidth, 17)];
    baseLabel.font = [UIFont notaBoldWithSize:15];
    baseLabel.textColor = [UIColor frescoDarkTextColor];
    baseLabel.text = @"PROMO EARNINGS SO FAR: $0";
    [self.view addSubview:baseLabel];
  
    /* DEBUG */
//    textBlockLabel.backgroundColor = [UIColor redColor];
//    promoCodeLabel.backgroundColor = [UIColor redColor];
//    baseLabel.backgroundColor = [UIColor redColor];
}

-(void)configureContainer{
    
    CGFloat containerWidth = 234;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - containerWidth/2, 211, containerWidth, 57)];
    [self.view addSubview:container];
    
    UILabel *leftHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 106, 17)];
    leftHeader.text = @"FIRST 10 PEOPLE";
    leftHeader.font = [UIFont notaBoldWithSize:15];
    leftHeader.textColor = [UIColor frescoMediumTextColor];
    [container addSubview:leftHeader];
    
    UILabel *leftBulletts = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 100, 40)];
    leftBulletts.text = @"• They get $20 \n• You get $10";
    leftBulletts.numberOfLines = 2;
//    leftBulletts.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    leftBulletts.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:15];
    leftBulletts.textAlignment = NSTextAlignmentLeft;
    leftBulletts.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:leftBulletts];
    
    
    UILabel *rightHeader = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 106, 17)];
    rightHeader.text = @"EVERYONE ELSE";
    rightHeader.font = [UIFont notaBoldWithSize:15];
    rightHeader.textColor = [UIColor frescoMediumTextColor];
    [container addSubview:rightHeader];
    
    
    
    
    UILabel *rightBullets = [[UILabel alloc] initWithFrame:CGRectMake(130, 17, 100, 40)];
    rightBullets.text = @"• They get $20 \n• You get $5";
    rightBullets.numberOfLines = 2;
//        rightBullets.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    rightBullets.font = [UIFont fontWithName:@"SanFranciscoText-Light" size:15];
    rightBullets.textAlignment = NSTextAlignmentLeft;
    rightBullets.textColor = [UIColor frescoDarkTextColor];
    [container addSubview:rightBullets];
    
    
    /* DEBUG */
//    container.backgroundColor = [UIColor redColor];
//    leftHeader.backgroundColor = [UIColor greenColor];
//    rightHeader.backgroundColor = [UIColor greenColor];
//    leftBulletts.backgroundColor = [UIColor greenColor];
//    rightBullets.backgroundColor = [UIColor greenColor];

}


@end
