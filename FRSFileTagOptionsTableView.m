//
//  FRSFileTagOptionsTableView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagOptionsTableView.h"
#import "FRSFileTagOptionsTableViewCell.h"
#import "FRSFileTagOptionsViewModel.h"

@interface FRSFileTagOptionsTableView() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) FRSFileTagOptionsViewModel *selectedSourceViewModel;
@end

@implementation FRSFileTagOptionsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
        [self registerNib:[UINib nibWithNibName:@"FRSFileTagOptionsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FRSFileTagOptionsTableViewCellIdentifier"];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceViewModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRSFileTagOptionsTableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"FRSFileTagOptionsTableViewCellIdentifier" forIndexPath:indexPath];
    
    FRSFileTagOptionsViewModel *sourceViewModel = self.sourceViewModelsArray[indexPath.row];
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
//    self.selectedIndex = indexPath.row;
}

@end
