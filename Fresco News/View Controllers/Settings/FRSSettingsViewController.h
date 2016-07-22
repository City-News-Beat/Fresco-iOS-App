//
//  FRSSettingsViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import <MessageUI/MessageUI.h>

@interface FRSSettingsViewController : FRSBaseViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end
