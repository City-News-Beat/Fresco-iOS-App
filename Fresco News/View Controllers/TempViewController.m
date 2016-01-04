//
//  TempViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "TempViewController.h"

#import "FRSGalleryView.h"

@interface TempViewController () <FRSGalleryViewDataSource>

@property (strong, nonatomic) FRSGalleryView * galleryView;

@end

@implementation TempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.galleryView = [[FRSGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500) gallery:nil dataSource:self];
    self.galleryView.dataSource = self;
    [self.view addSubview:self.galleryView];
    // Do any additional setup after loading the view.
}

- (NSInteger)heightForImageView{
    return 200;
}

-(NSInteger)numberOfLinesForTextView{
    return 6;
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
