//
//  FRSGalleryExpandedViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSGalleryExpandedViewController.h"

@interface FRSGalleryExpandedViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation FRSGalleryExpandedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    // Do any additional setup after loading the view.
}

-(void)configureUI{
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureNavigationBar];
    [self configureScrollView];
}

-(void)configureNavigationBar{
    [super configureNavigationBar];
    self.navigationItem.title = @"GALLERY";
}

-(void)configureScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.scrollView.backgroundColor = [UIColor frescoBackgroundColorLight];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
