//
//  FRSFileSourcePickerTableView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileSourcePickerTableView.h"
#import "FRSFileSourcePickerTableViewCell.h"

@interface FRSFileSourcePickerTableView() <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FRSFileSourcePickerTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        [self registerNib:[UINib nibWithNibName:@"FRSFileSourcePickerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FRSFileSourcePickerTableViewCellIdentifier"];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceViewModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRSFileSourcePickerTableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"FRSFileSourcePickerTableViewCellIdentifier" forIndexPath:indexPath];
    
    FRSFileSourcePickerViewModel *sourceViewModel = self.sourceViewModelsArray[indexPath.row];
    if(sourceViewModel == self.selectedSourceViewModel) {
        sourceViewModel.isSelected = YES;
    }
    else {
        sourceViewModel.isSelected = NO;
    }
    [cell updateWithViewModel:sourceViewModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSourceViewModel = self.sourceViewModelsArray[indexPath.row];
    self.selectedIndex = indexPath.row;
}

@end
