//
//  FRSTableViewController.h
//  Fresco
//
//  Created by Elmir Kouliev on 11/3/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSTableViewController : UITableViewController

/**
 *  Code block for endless scroll
 */

@property (nonatomic, copy) void (^endlessScrollBlock)(FRSAPISuccessBlock);

@end
