//
//  FirstRunSignUpViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/27/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunSignUpViewController.h"

@interface FirstRunSignUpViewController ()
@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;

@end

@implementation FirstRunSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addFieldsBorders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFieldsBorders {
    // Set thickness
    NSInteger borderThickness = 1;
    
    UIView *topBorder = [UIView new];
    topBorder.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.08];
    topBorder.frame = CGRectMake(0, 0, self.fieldsWrapper.frame.size.width, borderThickness);
    [self.fieldsWrapper addSubview:topBorder];
    
    UIView *bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.08];
    bottomBorder.frame = CGRectMake(0, self.fieldsWrapper.frame.size.height - borderThickness, self.fieldsWrapper.frame.size.width, borderThickness);
    [self.fieldsWrapper addSubview:bottomBorder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
