//
//  FRSGalleryExpandedViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSScrollingViewController.h"
@class FRSGallery;

@interface FRSGalleryExpandedViewController : FRSScrollingViewController <UITextViewDelegate>
@property BOOL isLoadingUser;
-(instancetype)initWithGallery:(FRSGallery *)gallery;
-(instancetype)initWithGalleryID:(NSString *)galleryID;

@end
