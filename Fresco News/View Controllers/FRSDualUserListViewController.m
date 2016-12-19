//
//  FRSDualUserListViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 12/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDualUserListViewController.h"

@interface FRSDualUserListViewController ()

@end

@implementation FRSDualUserListViewController

-(instancetype)initWithArrayOne:(NSArray *)arrayOne arrayTwo:(NSArray *)arrayTwo {
    self = [super init];
    
    if (self) {

        
    
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureNavigationBar];

}

-(void)configureNavigationBar {
    
    // default config
    [super configureBackButtonAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];    
    
    
}




@end
