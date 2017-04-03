//
//  FRSGalleryUploadedToast.h
//  Fresco
//
//  Created by Omar Elfanek on 3/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSGalleryUploadedToast : UIView

- (instancetype)init;
- (void)show;

@property (strong, nonatomic) NSString *galleryID;

@end
