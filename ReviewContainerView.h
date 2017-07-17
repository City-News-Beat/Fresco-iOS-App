//
//  ReviewContainerView.h
//  Fresco
//
//  Created by Omar Elfanek on 7/16/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface ReviewContainerView : UIView
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UITextField *expirationTextField;

@property (weak, nonatomic) IBOutlet UIView *confirmButtonView;
@end
