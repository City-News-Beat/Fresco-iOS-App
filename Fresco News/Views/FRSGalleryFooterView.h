//
//  FRSGalleryFooterView.h
//  Fresco
//
//  Created by Omar Elfanek on 1/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSUserView.h"

@protocol FRSGalleryFooterViewDelegate <NSObject>
- (void)userAvatarTapped;
@end

@interface FRSGalleryFooterView : UIView

@property (weak, nonatomic) NSObject<FRSGalleryFooterViewDelegate> *delegate;
@property (strong, nonatomic) FRSUserView *userView;


/**
 Initializes an FRSGalleryFooterView with a created at date, posted at date, and an FRSUserView with the galleries curator.
 
 @param frame The frame of the footer view.
 @param gallery The gallery where metadata will be pulled from.
 @param delegate FRSGalleryFooterViewDelegate
 @return FRSGalleryFooterView
 */
- (instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryFooterViewDelegate>)delegate;


/**
 The cumulative heights of the posted at label, the edited at label, and the user view.
 */
@property (nonatomic) NSInteger calculatedHeight;

@end
