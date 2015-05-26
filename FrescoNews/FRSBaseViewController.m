//
//  FRSBaseViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/7/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import "FRSGallery.h"
#import "GalleryHeader.h"
#import "AppDelegate.h"

@interface FRSBaseViewController ()

@end

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GalleryHeader *storyCellHeader = [tableView dequeueReusableCellWithIdentifier:[GalleryHeader identifier]];
    
    // remember, one story per section
    FRSGallery *gallery = [self.galleries objectAtIndex:section];
    [storyCellHeader setGallery:gallery];
    
    return storyCellHeader;
}

// good for wholesale resetting of the app
- (void)navigateToMainApp
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setRootViewControllerToTabBar];
}
@end
