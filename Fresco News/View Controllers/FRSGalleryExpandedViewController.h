//
//  FRSGalleryExpandedViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@class FRSGallery;
@class FRSComment;

@interface FRSGalleryExpandedViewController : FRSBaseViewController <UITextViewDelegate> {
    NSDate *dateEntered;
    float percentageScrolled;
}

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) NSString *openedFrom;

- (instancetype)initWithGallery:(FRSGallery *)gallery;
- (void)presentFlagCommentSheet:(FRSComment *)comment;

@end
