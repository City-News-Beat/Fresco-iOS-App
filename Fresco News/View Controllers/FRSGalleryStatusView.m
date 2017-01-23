//
//  FRSGalleryStatusView.m
//  Fresco
//
//  Created by Arthur De Araujo on 1/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryStatusView.h"
#import "FRSGalleryStatusTableViewCell.h"
#import "FRSGalleryDetailView.h"
#import "Haneke.h"

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
    DGElasticPullToRefreshLoadingViewCircle *spinner;
}

// Zeplin Heights
static CGFloat const popupViewHeightPendingVerified = 230;
static CGFloat const popupViewHeightVerified = 216;
static CGFloat const popupViewHeightOneSold = 410;
static CGFloat const popupViewHeightMultiSold = 528;

static CGFloat const barHeight = 27; // Bar height for bot bar, top bar and the rest

const double verifiedLineHeightNotSold = 36;

enum {
    PendingVerfication = 0,
    NotVerified = 1,
    Verified = 2,
    Highlighted = 3,
    Deleted = 4
};
typedef int GalleryStatusRating;

- (void)configureWithArray:(NSArray *)postPurchases rating:(int)rating {
    [self addLayerShadowAndRadius];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self animateIn];
    [self configureSoldTableView];

    purchases = [[NSArray alloc] initWithArray:postPurchases];

    if (purchases.count > 0) {
        [self setToSold];
    } else {
        if (rating == PendingVerfication) { // Not Rated | PENDING VERIFICATION
            [self setToPendingVerification];
        } else if (rating == NotVerified) { // Skipped | NOT VERIFIED
            [self setToNotVerified];
        } else if (rating == Verified || rating == Highlighted) { // Verified or Highlighted | VERIFIED
            [self setToVerified];
        } else if (rating == Deleted) { // DELETED
            // Todo
        }
    }
}

- (void)configureSoldTableView {
    soldContentTableView.delegate = self;
    soldContentTableView.dataSource = self;
    soldContentTableView.clipsToBounds = true;
    soldContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    soldContentTableView.estimatedRowHeight = 20;
    soldContentTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)setToPendingVerification {
    popupViewHeightConstraint.constant = popupViewHeightPendingVerified;
    scrollView.scrollEnabled = false;

    [self hideSoldViews];

    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    verifiedTitleLabel.text = @"Pending verification";
    verifiedDescriptionLabel.text = @"Once we’ve verified your gallery, news outlets will be able to purchase content.";

    verifiedLineView.backgroundColor = [UIColor frescoOrangeColor];
    verifiedLineHeightConstraint.constant = verifiedLineHeightNotSold;

    [verifiedCheckImageView setImage:[UIImage imageNamed:@"checkboxBlankCircleOutline24Y"]];
}

- (void)setToNotVerified {
    popupViewHeightConstraint.constant = popupViewHeightPendingVerified;
    scrollView.scrollEnabled = false;

    [self hideSoldViews];

    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    verifiedTitleLabel.text = @"Couldn't verify";
    verifiedDescriptionLabel.text = @"This gallery is visible to Fresco users but hidden to news outlets.";

    verifiedLineView.backgroundColor = [UIColor frescoLightTextColor];
    verifiedLineHeightConstraint.constant = verifiedLineHeightNotSold;

    [verifiedCheckImageView setImage:[UIImage imageNamed:@"checkboxBlankCircleOutline24K3"]];
}

- (void)setToVerified {
    popupViewHeightConstraint.constant = popupViewHeightVerified;
    scrollView.scrollEnabled = false;

    [self hideSoldViews];

    verifiedTitleLabel.font = [UIFont systemFontOfSize:verifiedTitleLabel.font.pointSize weight:UIFontWeightMedium];
    verifiedTitleLabel.text = @"Verified";
    verifiedDescriptionLabel.text = @"News outlets can purchase content from this gallery.";

    verifiedLineHeightConstraint.constant = verifiedLineHeightNotSold;
}

- (void)setToSold {
    if (purchases.count == 1) {
        popupViewHeightConstraint.constant = popupViewHeightOneSold;
    } else {
        popupViewHeightConstraint.constant = popupViewHeightMultiSold;
    }
    verifiedDescriptionLabel.hidden = true;
    
    scrollView.hidden = true;
    spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    spinner.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2, 20, 20);
    spinner.tintColor = [UIColor frescoOrangeColor];
    [self addSubview:spinner];
    [spinner setPullProgress:90];
    [spinner startAnimating];
}

- (void)hideSoldViews {
    soldLabel.hidden = true;
    soldLineView.hidden = true;
    soldContentTableView.hidden = true;
    soldCashIconImageView.hidden = true;
}

- (void)animateIn {
    /* Set default state before animating in */
    popupView.transform = CGAffineTransformMakeScale(1.175, 1.175);
    self.alpha = 0;

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.alpha = 1;
                       self.backgroundColor = [UIColor frescoLightTextColor];
                       popupView.transform = CGAffineTransformMakeScale(1, 1);

                     }
                     completion:nil];
}

- (void)animateOut {
    [UIView animateWithDuration:0.25
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{

          self.alpha = 0;
          self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
          popupView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }
        completion:^(BOOL finished) {
          [self removeFromSuperview];
        }];
}

- (void)addLayerShadowAndRadius {
    popupView.layer.shadowColor = [UIColor blackColor].CGColor;
    popupView.layer.shadowOffset = CGSizeMake(0, 4);
    popupView.layer.shadowRadius = 2;
    popupView.layer.shadowOpacity = 0.1;
    popupView.layer.cornerRadius = 4;
}

/**
 Changes the scroll view content size to make it able to scroll down to the size of the tableview (if this wasn't here, there would be 2 scroll views needed. 1 for the tableview scrollview, 1 for the scrollview)
 */
- (void)adjustScrollViewContentSize {
    // Disables the need to scroll
    CGRect newFrame = soldContentTableView.frame;
    newFrame.size.height = soldContentTableView.contentSize.height;
    soldContentTableView.frame = newFrame;

    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, (barHeight * 5) + soldContentTableView.frame.size.height);
}

- (void)removeLoadingSpinner {
    scrollView.hidden = false;
    [spinner stopLoading];
    [spinner removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)pressedOk:(id)sender {
    [self animateOut];
}

- (IBAction)pressedGetHelp:(id)sender {
    [self animateOut];
    [self.parentVC presentSmooch];
    [self.parentView dismissKeyboard:nil];
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
    cell.parentView = self;
    cell.row = (int)indexPath.row;
    if (!cell.reloadedTableViewCounter) {
        cell.reloadedTableViewCounter = 0;
    }

    [(FRSGalleryStatusTableViewCell *)cell configureCellWithPurchaseDict:[purchases objectAtIndex:indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(FRSGalleryStatusTableViewCell *)cell configureCellWithPurchaseDict:[purchases objectAtIndex:indexPath.row]];
    [self adjustScrollViewContentSize];
}
@end
