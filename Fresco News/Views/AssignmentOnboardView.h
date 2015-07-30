//
//  AssignmentOnboardView.h
//  Fresco
//
//  Created by Nicolas Rizk on 7/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssignmentOnboardView : UIView

@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIImageView *onboard1ImageView;

@property (weak, nonatomic) IBOutlet UIImageView *onboard2ImageView;

@property (weak, nonatomic) IBOutlet UIImageView *onboard3ImageView;

@property (weak, nonatomic) IBOutlet UILabel *onboard1Label;

@property (weak, nonatomic) IBOutlet UILabel *onboard2Label;

@property (weak, nonatomic) IBOutlet UILabel *onboard3Label;

@property (weak, nonatomic) IBOutlet UIButton *letsGoButton;

- (IBAction)letsGoButtonTapped:(id)sender;






@end
