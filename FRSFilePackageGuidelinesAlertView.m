//
//  FRSFilePackageGuidelinesAlertView.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFilePackageGuidelinesAlertView.h"
#import "FRSFilePackageGuidelinesTagsTableView.h"
#import "FRSFileTag.h"
#import "FRSFileTagOptionsViewModel.h"

@interface FRSFilePackageGuidelinesAlertView ()

@property (strong, nonatomic) FRSFilePackageGuidelinesTagsTableView *fileTagOptionsTableView;
@property (strong, nonatomic) UILabel *footerMessageLabel;

@end

@implementation FRSFilePackageGuidelinesAlertView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        /* Title Label */
        [self configureWithTitle:@"PACKAGE GUIDELINES"];
        
        /* Message Label */
        [self configureWithMessage:@"Outlets want packages! Use the checklist to make sure you've got at least one of each shot."];
        
        /* Tag Options Tableview */
        [self configureTagOptionsTableView];
        
        /* Footer Message */
        [self configureWithFooterMessage];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.footerMessageLabel.frame.origin.y + self.footerMessageLabel.frame.size.height + 14.5];

        /* Action Buttons */
        [self configureWithLeftActionTitle:@"SEE TIPS" withColor:nil andRightCancelTitle:@"OK" withColor:nil];
        
        [self adjustFrame];
    }
    
    return self;
}

- (void)adjustFrame {
    self.height = self.leftActionButton.frame.origin.y + self.leftActionButton.frame.size.height;
    
    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
    NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;
    
    self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
}

- (void)configureTagOptionsTableView {
    //models
    FRSFileTag *tag1 = [[FRSFileTag alloc] initWithName:@"Interview"];
    FRSFileTag *tag2 = [[FRSFileTag alloc] initWithName:@"Wide Shot"];
    FRSFileTag *tag3 = [[FRSFileTag alloc] initWithName:@"Steady Pan"];
    
    //view models
    FRSFileTagOptionsViewModel *tagViewModel1 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag1];
    tagViewModel1.isSelected = YES;
    
    FRSFileTagOptionsViewModel *tagViewModel2 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag2];
    FRSFileTagOptionsViewModel *tagViewModel3 = [[FRSFileTagOptionsViewModel alloc] initWithFileTag:tag3];
    
    NSMutableArray *tagViewModels = [[NSMutableArray alloc] initWithObjects:tagViewModel1, tagViewModel2, tagViewModel3, nil];

    self.fileTagOptionsTableView = [[FRSFilePackageGuidelinesTagsTableView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height, self.bounds.size.width, 3*44) style:UITableViewStylePlain];
    self.fileTagOptionsTableView.sourceViewModelsArray = tagViewModels;
    
    [self addSubview:self.fileTagOptionsTableView];
    
}

- (void)configureWithFooterMessage {
    self.footerMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, self.fileTagOptionsTableView.frame.origin.y + self.fileTagOptionsTableView.frame.size.height + 10, MESSAGE_WIDTH, 0)];
    self.footerMessageLabel.textColor = [UIColor colorWithWhite:0 alpha:0.54];
    self.footerMessageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    self.footerMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.footerMessageLabel.numberOfLines = 0;
    self.footerMessageLabel.text = @"Don't worry if you can't fill the entire package, outlets still want to see your photos and videos!";
    self.footerMessageLabel.textAlignment = NSTextAlignmentCenter;
    [self.footerMessageLabel sizeToFit];
    self.footerMessageLabel.frame = CGRectMake(self.footerMessageLabel.frame.origin.x, self.footerMessageLabel.frame.origin.y, MESSAGE_WIDTH, self.footerMessageLabel.frame.size.height);
    [self addSubview:self.footerMessageLabel];
}

- (void)leftActionTapped {
    if (self.seeTipsAction) {
        self.seeTipsAction();
    }
    [super leftActionTapped];
}
@end
