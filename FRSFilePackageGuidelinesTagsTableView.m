//
//  FRSFilePackageGuidelinesTagsTableView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFilePackageGuidelinesTagsTableView.h"
#import "FRSFilePackageGuidelinesTagTableCell.h"
#import "FRSFileTagOptionsViewModel.h"

@interface FRSFilePackageGuidelinesTagsTableView() <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FRSFilePackageGuidelinesTagsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        [self registerNib:[UINib nibWithNibName:@"FRSFilePackageGuidelinesTagTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FRSFilePackageGuidelinesTagTableCellIdentifier"];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceViewModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRSFilePackageGuidelinesTagTableCell *cell = [self dequeueReusableCellWithIdentifier:@"FRSFilePackageGuidelinesTagTableCellIdentifier" forIndexPath:indexPath];
    
    FRSFileTagOptionsViewModel *sourceViewModel = self.sourceViewModelsArray[indexPath.row];
    [cell updateWithViewModel:sourceViewModel];
    return cell;
}

@end
