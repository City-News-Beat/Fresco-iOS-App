//
//  FRSTableViewController.m
//  Fresco
//
//  Created by Elmir Kouliev on 11/3/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSTableViewController.h"

@interface FRSTableViewController ()

@property (nonatomic, assign) BOOL endlessBlockInProgress;

@end

@implementation FRSTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.delegate = self;

}


#pragma mark - Table View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollOffset = scrollView.contentOffset.y;

    //Check if we're at the end of the table view
    if (scrollOffset + scrollViewHeight >= scrollView.contentSize.height){
        
        if(!self.endlessBlockInProgress && self.endlessScrollBlock){
        
            self.endlessBlockInProgress = YES;

            self.endlessScrollBlock(^(BOOL success, NSError *error){
            
                self.endlessBlockInProgress = NO;
            
            });
        }
    }
}

#pragma mark - Table view data source




@end
