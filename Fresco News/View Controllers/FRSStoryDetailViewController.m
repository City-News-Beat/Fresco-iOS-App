//
//  FRSStoryDetailViewController.m
//  Fresco
//
//  Created by Philip Bernstein on 3/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryDetailViewController.h"
#import "FRSGalleryCell.h"

@interface FRSStoryDetailViewController ()

@end

@implementation FRSStoryDetailViewController
static NSString *galleryCell = @"GalleryCellReuse";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableView];
}

-(void)setupTableView {
    [self.galleriesTable registerClass:[FRSGalleryCell class] forCellReuseIdentifier:galleryCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stories.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return Nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // add dans stuff here
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
