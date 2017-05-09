//
//  FRSDualUserListViewController.h
//  Fresco
//
//  Created by Omar Elfanek on 12/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"

@interface FRSDualUserListViewController : FRSBaseViewController

- (void)fetchLeftDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchRightDataSourceWithCompletion:(FRSAPIDefaultCompletionBlock)completion;

- (void)loadMoreLeftUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)loadMoreRightUsersFromLast:(NSString *)lastUserID withCompletion:(FRSAPIDefaultCompletionBlock)completion;

@property (strong, nonatomic) NSString *leftTitle;
@property (strong, nonatomic) NSString *rightTitle;

- (void)handleLeftTabTapped;
- (void)handleRightTabTapped;

@end
