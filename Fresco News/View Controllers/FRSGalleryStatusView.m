//
//  FRSGalleryStatusView.m
//  Fresco
//
//  Created by Arthur De Araujo on 1/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryStatusView.h"
#import "FRSGalleryStatusTableViewCell.h"

@interface FRSGalleryStatusView () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation FRSGalleryStatusView {
    
    IBOutlet UIView *popupView;
    IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
    
    IBOutlet UIScrollView *scrollView;
    
    // Submitted
    IBOutlet UIImageView *submittedCheckImageView;
    IBOutlet UILabel *submittedLabel;
    
    // Verified
    IBOutlet UIView *verifiedLineView;
    IBOutlet NSLayoutConstraint *verifiedLineHeightConstraint;
    
    IBOutlet UIImageView *verifiedCheckImageView;
    IBOutlet UILabel *verifiedTitleLabel;
    IBOutlet UILabel *verifiedDescriptionLabel;
    
    // Sold
    IBOutlet UIView *soldLineView;
    IBOutlet UILabel *soldLabel;
    IBOutlet UITableView *soldContentTableView;
    IBOutlet UIImageView *soldCashIconImageView;
    
    NSArray *purchases;
}

-(void)configureWithArray:(NSArray *)postPurchases rating:(int)rating{
    [self addLayerShadowAndRadius];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self animateIn];
    [self configureSoldTableView];
    
    purchases = [[NSArray alloc] initWithArray:postPurchases];
    
    if (purchases.count > 0){
        [self setToSold];
    }else{
        if (rating == 0){// Not Rated | PENDING VERIFICATION
            [self setToPendingVerification];
        }else if(rating == 1){// Skipped | NOT VERIFIED
            [self setToNotVerified];
        }else if(rating == 2 || rating == 3){// Verified or Highlighted | VERIFIED
            [self setToVerified];
        }else if(rating == 4){// DELETED
            // Todo
        }
    }
}

-(void)configureSoldTableView{
    soldContentTableView.delegate = self;
    soldContentTableView.dataSource = self;
    soldContentTableView.clipsToBounds = true;
    soldContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    soldContentTableView.estimatedRowHeight = 40;
    soldContentTableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)setToPendingVerification{
    popupViewHeightConstraint.constant = 230; // Zeplin Height
    scrollView.scrollEnabled = false;
    
    [self hideSoldViews];

    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    verifiedTitleLabel.text = @"Pending verification";
    verifiedDescriptionLabel.text = @"Once we’ve verified your gallery, news outlets will be able to purchase content.";
    
    verifiedLineView.backgroundColor = [UIColor frescoOrangeColor];
    verifiedLineHeightConstraint.constant = 36;
    
    [verifiedCheckImageView setImage:[UIImage imageNamed:@"checkboxBlankCircleOutline24Y"]];
}

-(void)setToNotVerified{
    popupViewHeightConstraint.constant = 230; // Zeplin Height
    scrollView.scrollEnabled = false;
    
    [self hideSoldViews];
    
    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    verifiedTitleLabel.text = @"Couldn't verify";
    verifiedDescriptionLabel.text = @"This gallery is visible to Fresco users but hidden to news outlets.";
    
    verifiedLineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.26];
    verifiedLineHeightConstraint.constant = 36;
    
    [verifiedCheckImageView setImage:[UIImage imageNamed:@"checkboxBlankCircleOutline24K3"]];
}

-(void)setToVerified{
    popupViewHeightConstraint.constant = 216; // Zeplin Height
    scrollView.scrollEnabled = false;
    
    [self hideSoldViews];
    
    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    verifiedTitleLabel.text = @"Verified";
    verifiedDescriptionLabel.text = @"News outlets can purchase content from this gallery.";
    
    verifiedLineHeightConstraint.constant = 36;
}

-(void)setToSold{
    if (purchases.count == 1) {
        popupViewHeightConstraint.constant = 410; // Zeplin Height
        scrollView.scrollEnabled = false;
    }else{
        popupViewHeightConstraint.constant = 528; // Zeplin Height
    }
    verifiedDescriptionLabel.hidden = true;
}

- (void)hideSoldViews{
    soldLabel.hidden = true;
    soldLineView.hidden = true;
    soldContentTableView.hidden = true;
    soldCashIconImageView.hidden = true;
}

-(void)animateIn {
    /* Set default state before animating in */
    popupView.transform = CGAffineTransformMakeScale(1.175, 1.175);
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 1;
//                         self.titleLabel.alpha = 1;
//                         self.cancelButton.alpha = 1;
//                         self.actionButton.alpha = 1;
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.26];
                         popupView.transform = CGAffineTransformMakeScale(1, 1);
                         
                     } completion:nil];
}

-(void)animateOut {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 0;
//                         self.titleLabel.alpha = 0;
//                         self.cancelButton.alpha = 0;
//                         self.actionButton.alpha = 0;
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                         popupView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

-(void)addLayerShadowAndRadius{
    popupView.layer.shadowColor = [UIColor blackColor].CGColor;
    popupView.layer.shadowOffset = CGSizeMake(0, 4);
    popupView.layer.shadowRadius = 2;
    popupView.layer.shadowOpacity = 0.1;
    popupView.layer.cornerRadius = 4;
}

#pragma mark - IBActions

- (IBAction)pressedOk:(id)sender {
    [self animateOut];
}

- (IBAction)pressedGetHelp:(id)sender {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return purchases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerNib:[UINib nibWithNibName:@"FRSGalleryStatusTableViewCell" bundle:nil] forCellReuseIdentifier:@"purchase-cell"];
    FRSGalleryStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"purchase-cell"];
    cell.tableView = tableView;
    [(FRSGalleryStatusTableViewCell *)cell configureCellWithPurchaseDict:[purchases objectAtIndex:indexPath.row]];

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
