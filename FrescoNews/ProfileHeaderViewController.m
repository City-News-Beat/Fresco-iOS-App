//
//  ProfileHeaderViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 4/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "ProfileHeaderViewController.h"
#import "FRSUser.h"

@interface ProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelDisplayName;

@end

@implementation ProfileHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.frsUser.first, self.frsUser.last];
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
