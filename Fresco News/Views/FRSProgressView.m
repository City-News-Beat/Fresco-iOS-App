//
//  FRSProgressView.m
//  Fresco
//
//  Created by Omar Elfanek on 10/2/15.
//  Copyright © 2015 Fresco. All rights reserved.
//


#import "FRSProgressView.h"

@interface FRSProgressView ()

/*
 ** UI Elements
 */

- (IBAction)nextButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) IBOutlet UIView *circleView1;

@property (strong, nonatomic) IBOutlet UIView *circleView2;

@property (strong, nonatomic) IBOutlet UIView *circleView3;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView1;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView2;

@property (strong, nonatomic) IBOutlet UIView *emptyCircleView3;

@property (strong, nonatomic) IBOutlet UIView *progressView;

@property (strong, nonatomic) IBOutlet UIView *emptyProgressView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *emptyProgressViewLeadingConstraint;

@end


@implementation FRSProgressView


- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){
        
        self.backgroundColor = [UIColor redCircleStrokeColor];
        
        [self initNextButton];
        [self initProgressBar];
        
        /*
         
         for(NSInterger i = 0; i < pageCount ; i++){
         
         }
         
        */
        
    }
    
    return self;
}

- (void) initProgressBar {
    
    self.emptyProgressView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      0,
                                                                      self.nextButton.frame.origin.y - 3,
                                                                      self.frame.size.width,
                                                                      3
                                                                      )];
    self.emptyProgressView.backgroundColor = [UIColor frescoGreyBackgroundColor];
    
    [self addSubview:self.emptyProgressView];
    
    //Filled circle view 1
    self.circleView1 = [[UIView alloc] initWithFrame:CGRectMake(
                                                                10,
                                                                self.emptyProgressView.frame.origin.y  - 24 / 2,
                                                                24,
                                                                24
                                                                )];
    self.circleView1.layer.cornerRadius = 12;
    self.circleView1.layer.borderWidth = 3;
    self.circleView1.backgroundColor = [UIColor radiusGoldColor];
    self.circleView1.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubview:self.circleView1];
    
}

- (void)initNextButton {
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    self.nextButton.frame = CGRectMake(0,
                                       self.frame.size.height - 45,
                                       self.frame.size.width,
                                       45
                                       );
    
    [self.nextButton.titleLabel setFont: [UIFont fontWithName:HELVETICA_NEUE_REGULAR size:17]];
    [self.nextButton setTitleColor:[UIColor radiusGoldColor] forState:UIControlStateNormal];
//    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];

    
    [self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton.backgroundColor = [UIColor frescoBlueColor];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self addSubview:self.nextButton];

}

- (void)nextButtonTapped:(id)sender {
    
    NSLog(@"Next button tapped");
}

@end



























