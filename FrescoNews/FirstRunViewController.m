//
//  FirstRunViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunViewController.h"

@interface FirstRunViewController ()

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *fieldsWrapper;

@end

@implementation FirstRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self styleButtons];
    
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

- (void)styleButtons {
    self.twitterButton.layer.cornerRadius = 8;
    self.twitterButton.clipsToBounds = YES;
    
    self.facebookButton.layer.cornerRadius = 8;
    self.facebookButton.clipsToBounds = YES;
    
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    
    self.signUpButton.layer.cornerRadius = 8;
    self.signUpButton.clipsToBounds = YES;
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
