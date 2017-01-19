//
//  FRSGalleryStatusTableViewCell.h
//  
//
//  Created by Arthur De Araujo on 1/12/17.
//
//

#import <UIKit/UIKit.h>
#import "FRSGalleryStatusView.h"

@interface FRSGalleryStatusTableViewCell : UITableViewCell

-(void)configureCellWithPurchaseDict:(NSDictionary *)purchasePostDict;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) FRSGalleryStatusView *parentView;

@property (nonatomic) int reloadedTableViewCounter;
@property (nonatomic) int row;

@end
