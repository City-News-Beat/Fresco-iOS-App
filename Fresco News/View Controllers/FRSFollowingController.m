//
//  FRSFollowingController.m
//  Fresco
//
//  Created by Philip Bernstein on 6/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSFollowingController.h"
#import "FRSGalleryCell.h"
#import "FRSStoryCell.h"
#import "FRSAPIClient.h"
#import "Fresco.h"

@implementation FRSFollowingController
@synthesize tableView = _tableView;


-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit {
    [[FRSAPIClient sharedClient] fetchFollowing:^(NSArray *galleries, NSError *error) {
        self.feed = [[FRSAPIClient sharedClient] parsedObjectsFromAPIResponse:galleries cache:FALSE];
        [self.tableView reloadData];
    }];
}

-(void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(UITableView *)tableView {
    return _tableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Nil;
}


@end
