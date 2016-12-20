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

-(instancetype)initWithGallery:(NSString *)galleryID;

@property BOOL didTapRepostLabel; // used to determine which navigation bar tab should be selected

@end
