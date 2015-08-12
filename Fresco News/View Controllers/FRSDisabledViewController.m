//
//  FRSDisabledViewController.m
//  Fresco
//
//  Created by Nicolas Rizk on 8/12/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSDisabledViewController.h"

@interface FRSDisabledViewController ()

@end

@implementation FRSDisabledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            if ([name containsString:@"Nota"]) {
                NSLog(@"  %@", name);
                
            }
        }
    }
    [self.view removeConstraints:self.view.constraints];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
 
    UILabel *awkwardLabel = [[UILabel alloc] init];
    [awkwardLabel setFont:[UIFont systemFontOfSize:24]];
    
    UILabel *noiPhone4Label = [[UILabel alloc] init];
    [noiPhone4Label setFont:[UIFont systemFontOfSize:14]];
    noiPhone4Label.alpha = 0.54;

    self.view.backgroundColor = [UIColor disabledBackgroundColor];
    
    [self setUpDisabledFrog];
    [self setUpLabel:awkwardLabel WithText:AWKWARD YMultiplier:1.15];
    [self setUpLabel:noiPhone4Label WithText:NO_IPHONE_4S_LABEL YMultiplier:1.3];
}

- (void)setUpDisabledFrog {
    
    UIImageView *disabledFrog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disabled_frog"]];
    disabledFrog.contentMode = UIViewContentModeScaleAspectFit;

    [self.view addSubview:disabledFrog];
    
    [disabledFrog removeConstraints:disabledFrog.constraints];
    disabledFrog.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *x = [NSLayoutConstraint constraintWithItem:disabledFrog attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [self.view addConstraint:x];
    
    NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:disabledFrog attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:0.8 constant:0];
    
    [self.view addConstraint:y];
    
    NSLayoutConstraint *h = [NSLayoutConstraint constraintWithItem:disabledFrog attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0];
    
    [self.view addConstraint:h];
    
    NSLayoutConstraint *w = [NSLayoutConstraint constraintWithItem:disabledFrog attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    
    [self.view addConstraint:w];
    
}

- (void)setUpLabel: (UILabel *)label WithText: (NSString *)text YMultiplier: (CGFloat)yMultiplier {
    

    
    [self.view addSubview:label];
    
    [label setText:text];
    [label removeConstraints:label.constraints];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *x = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [self.view addConstraint:x];
    
    NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:yMultiplier constant:0];
    
    [self.view addConstraint:y];
    
}




@end
