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
{
    UITextField *commentField;
    NSString *last;
    UIButton *topButton;
    BOOL showsMoreButton;
}
@property BOOL isLoadingUser;

-(void)focusOnPost:(NSString *)postID;
-(instancetype)initWithGallery:(FRSGallery *)gallery;
-(instancetype)initWithGallery:(FRSGallery *)gallery comment:(NSString *)commentID;

@end
