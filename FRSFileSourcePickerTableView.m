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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    
    [cell updateWithViewModel:self.sourceViewModelsArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSourceViewModel = self.sourceViewModelsArray[indexPath.row];
}

@end
