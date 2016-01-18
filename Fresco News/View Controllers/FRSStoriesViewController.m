//
//  FRSStoriesViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 1/18/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoriesViewController.h"

@interface FRSStoriesViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) UITextField *searchTextField;

@end

@implementation FRSStoriesViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self configureNavigationBar];
    
    self.view.backgroundColor = [UIColor redColor];
}

-(void)configureNavigationBar{

    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor frescoOrangeColor];
    [self.view addSubview:navBar];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.view.frame.size.width, 19)];
    self.titleLabel.text = @"STORIES";
    self.titleLabel.font = [UIFont notaBoldWithSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [navBar addSubview:self.titleLabel];
    
    self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 48, 19.5, 48, 44)];
    [self.searchButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchStories) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:self.searchButton];
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width, navBar.frame.size.height - 38, self.view.frame.size.width - 60, 30)];
    self.searchTextField.tintColor = [UIColor whiteColor];
    self.searchTextField.alpha = 0;
    self.searchTextField.delegate = self;
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [navBar addSubview:self.searchTextField];
    
    
}




-(void)searchStories{
    
    [self animateSearch];
    
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self hideSearch];
    return YES;
}

-(void)animateSearch{
    [UIView animateWithDuration:0.35 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchButton.transform = CGAffineTransformMakeTranslation((-self.view.frame.size.width) + 45, 0);
        self.searchTextField.transform = CGAffineTransformMakeTranslation((-self.view.frame.size.width) +40, 0);
        self.searchTextField.alpha = 1;

    } completion:nil];
    
    [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.titleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [self.searchTextField becomeFirstResponder];
    }];
}

-(void)hideSearch{
    [UIView animateWithDuration:0.35 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchButton.transform = CGAffineTransformMakeTranslation(0, 0);
        self.searchTextField.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
        self.searchTextField.alpha = 0;
    } completion:^(BOOL finished) {
        self.searchTextField.text = @"";
    }];
    
    [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.titleLabel.alpha = 1;
    } completion:nil];
}


@end
