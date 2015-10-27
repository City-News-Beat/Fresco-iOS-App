//
//  FRSSaveButton.m
//  Fresco
//
//  Created by Elmir Kouliev on 9/24/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSSaveButton.h"

@interface FRSSaveButton ()

@property (nonatomic, strong) UIActivityIndicatorView *saveProgressView;

@property (nonatomic, strong) NSString *title;

@end

@implementation FRSSaveButton

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)passedTitle{

    self = [FRSSaveButton buttonWithType:UIButtonTypeSystem];
            
    if(self){
    
        self.title = passedTitle;
        self.frame = frame;
        self.titleLabel.font = [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17];
        self.backgroundColor = [UIColor disabledSaveColor];
        [self setTitle:passedTitle forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self configureSpinner];
    }
    
    return self;

}

/**
 *  Sets up the spinner indicator inside the button
 */

- (void)configureSpinner{

    self.saveProgressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0, 20, 20)];
    
    self.saveProgressView.center = CGPointMake(self.frame.size.width  / 2, self.frame.size.height / 2);
    
    self.saveProgressView.hidden = YES;
    
    [self addSubview:self.saveProgressView];

}

- (void)toggleSpinner{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!self.saveProgressView) [self configureSpinner];
        
        if (!self.saveProgressView.isAnimating) {
            
            [self setTitle:@"" forState:UIControlStateNormal];
            
            [self.saveProgressView startAnimating];
            self.saveProgressView.alpha = 1;

        }
        else {
            
            [UIView animateWithDuration:.2 animations:^{
                self.saveProgressView.alpha = 0;
            }completion:^(BOOL finished) {
                [self.saveProgressView stopAnimating];
                [self setTitle:self.title forState:UIControlStateNormal];
            }];
        }
    
    });
}

- (void)updateSaveState:(SaveState)state{

    dispatch_async(dispatch_get_main_queue(), ^{
    
        if(state == SaveStateDisabled){
            
            self.enabled = NO;
            
            if(self.backgroundColor != [UIColor disabledSaveColor]){
                
                self.backgroundColor = [UIColor disabledSaveColor];
                
            }
            
        }
        else if(state == SaveStateEnabled){
            
            self.enabled = YES;
            
            if(self.backgroundColor != [UIColor greenToolbarColor]){
                
                self.backgroundColor = [UIColor greenToolbarColor];
                
            }
            
        }
        
    });

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
