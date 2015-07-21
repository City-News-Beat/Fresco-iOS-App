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

@end

@implementation FRSOnboardViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{

    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        
        // Create the data model
        self.mainHeaders = @[
                             @"Find breaking news around you",
                             @"Submit your photos and videos",
                             @"See your work in the news"
                             ];
        
        self.subHeaders = @[
                            @"Keep an eye out, or use Fresco to view a map of nearby events being covered by news outlets",
                            @"Your media is visible not only to Fresco users, but to our news organization partners in need of visual coverage",
                            @"We notify you when your photos and videos are used, and you'll get paid if you took them for an assignment"
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
