//
//  FRSOnboardViewController.m
//  Fresco
//
//  Created by Fresco News on 7/16/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSOnboardViewController.h"

@interface FRSOnboardViewController ()

/*
** Dictionary Values
*/

@property (nonatomic, strong) NSArray *mainHeaders;

@property (nonatomic, strong) NSArray *subHeaders;

@property (nonatomic, strong) NSArray *images;

/*
** UI Elements
*/

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *mainHeader;
@property (weak, nonatomic) IBOutlet UILabel *subHeader;
@property (weak, nonatomic) IBOutlet UIImageView *onboardImage;
@property (weak, nonatomic) IBOutlet UIImageView *progressImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomTextContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomLogo;

@end

@implementation FRSOnboardViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{

    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        
        // Create the data model
        self.mainHeaders = @[
                             MAIN_HEADER_1,
                             MAIN_HEADER_2,
                             MAIN_HEADER_3
                             ];
        
        self.subHeaders = @[
                            SUB_HEADER_1,
                            SUB_HEADER_2,
                            SUB_HEADER_3
                            ];
        
        self.images = @[
                            @"onboard1.png",
                            @"onboard2.png",
                            @"onboard3.png"
                            ];
        
        
    
    }
    
    return self;

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpViews];
    
    self.mainHeader.text = [self.mainHeaders objectAtIndex:self.index];
    
    self.subHeader.text = [self.subHeaders objectAtIndex:self.index];
    
    self.onboardImage.image = [UIImage imageNamed:[self.images objectAtIndex:self.index]];
    
    self.progressImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"progress-3-%li", (long)(self.index +1)]];
    
    //Show "Done" on the last view
    if(self.index == 2){
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
}

- (IBAction)nextButtonTapped:(id)sender {
    
    [self.frsTableViewCellDelegate nextPageClicked:self.index];
}

- (void) setUpViews {
        
    if (IS_STANDARD_IPHONE_6) {
        self.constraintBottomLogo.constant = 65;
        self.constraintBottomTextContainer.constant = 65;
        self.constraintBottomImage.constant = 85;
    }
    
    if (IS_ZOOMED_IPHONE_6 || IS_IPHONE_5) {
        self.constraintBottomLogo.constant = 30;
        self.constraintBottomTextContainer.constant = 40;
        self.constraintBottomImage.constant = 65;
    }
    
    if (IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6) {
        self.constraintBottomLogo.constant = 85;
        self.constraintBottomTextContainer.constant = 85;
        self.constraintBottomImage.constant = 105;
    }
    
}

@end
