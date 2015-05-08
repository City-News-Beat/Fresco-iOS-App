//
//  FirstRunSkipViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/24/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FirstRunProgressViewController.h"

@interface FirstRunProgressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *skipFeatureButton;
@property (weak, nonatomic) IBOutlet UIImageView *progressBarImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation FirstRunProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isSkipState = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tempToggle:(id)sender {
    if (self.isSkipState == NO) {
        [self loadAsSkipScreen];
        self.isSkipState = YES;
    } else {
        [self loadAsPermissionsScreen];
        self.isSkipState = NO;
    }
}

- (void)loadAsSkipScreen {
    [[self actionButton] setTitle:@"Done" forState:UIControlStateNormal];
    self.progressBarImage.hidden = YES;
    self.skipFeatureButton.hidden = NO;
}

- (void)loadAsPermissionsScreen {
    [[self actionButton] setTitle:@"Next" forState:UIControlStateNormal];
    self.progressBarImage.hidden = NO;
    self.skipFeatureButton.hidden = YES;
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
