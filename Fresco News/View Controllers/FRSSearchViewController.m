//
//  FRSSearchViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSearchViewController.h"

@interface FRSSearchViewController() <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITextField *searchTextField;
@end

@implementation FRSSearchViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureTableView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.searchTextField resignFirstResponder];
    [self animateDisappear];
}

-(void)configureNavigationBar{
    
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:navBar];
    
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(12, navBar.frame.size.height -34, 24, 24)];
    [dismissButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
    dismissButton.tintColor = [UIColor whiteColor];
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:dismissButton];
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(64, navBar.frame.size.height - 38, self.view.frame.size.width - 80, 30)];
    self.searchTextField.tintColor = [UIColor whiteColor];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [navBar addSubview:self.searchTextField];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchTextField becomeFirstResponder];
    });
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 36, navBar.frame.size.height -34, 24, 24)];
    [clearButton setImage:[UIImage imageNamed:@"delete-small-white"] forState:UIControlStateNormal];
    clearButton.tintColor = [UIColor whiteColor];
    [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:clearButton];
}

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)animateDisappear{
    [UIView animateWithDuration:0.2 delay:0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.view.alpha = 0;
        
    } completion:nil];
}

-(void)clear{
    NSLog(@"clear textfield");
    self.searchTextField.text = @"";
}

-(void)configureTableView{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}















@end