//
//  FRSSetupProfileViewController.h
//  Fresco
//
//  Created by Daniel Sun on 12/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSBaseViewController.h"
#import "FRSAPIClient.h"

@interface FRSSetupProfileViewController : FRSBaseViewController

@property (nonatomic) NSString *nameStr;
@property (nonatomic) NSString *locStr;
@property (nonatomic) NSString *bioStr;
@property (strong, nonatomic) NSURL *profileImageURL;

@property (nonatomic) BOOL isEditingProfile;

@end
