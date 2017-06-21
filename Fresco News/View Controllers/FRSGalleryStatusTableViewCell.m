//
//  FRSGalleryStatusTableViewCell.m
//
//
//  Created by Arthur De Araujo on 1/12/17.
//
//

#import "FRSGalleryStatusTableViewCell.h"
#import "Haneke.h"
#import "NSURL+Fresco.h"

@implementation FRSGalleryStatusTableViewCell {

    IBOutlet UIImageView *postImageView;
    IBOutlet UILabel *outletsLabel;
    IBOutlet UILabel *outletsPriceLabel;

    IBOutlet NSLayoutConstraint *postImageViewHeightConstraint;

    NSDictionary *purchaseDict;
}

- (void)configureCellWithPurchaseDict:(NSDictionary *)purchasePostDict {
    purchaseDict = [[NSDictionary alloc] initWithDictionary:purchasePostDict];
    postImageView.layer.cornerRadius = 3;

    NSURL *resizedURL = [NSURL URLResizedFromURLString:purchaseDict[@"image"] width:postImageView.frame.size.width];
    [postImageView hnk_setImageFromURL:resizedURL
        placeholder:nil
        success:^(UIImage *image) {
          if ((int)[self.tableView numberOfRowsInSection:0] - 1 == self.row) {
              [self.parentView removeLoadingSpinner];
          }
          [self configurePostImageViewWithImage:image];
          [self configureOutletsLabels];
          // Reload the table once for every cell
          if (self.reloadedTableViewCounter == 0) {
              [self.tableView reloadData];
              self.reloadedTableViewCounter = 1;
          }
        }
        failure:^(NSError *error) {
            DDLogError(@"Haneke imageview error: %@", error);
        }];
}

- (void)configurePostImageViewWithImage:(UIImage *)image {
    float aspectRatio = postImageView.frame.size.width / image.size.width;
    postImageViewHeightConstraint.constant = aspectRatio * image.size.height;

    [postImageView setImage:image];
}

/**
 Goes through the outlets that have purchased the gallery and sets the price and title of the outlet. Purchases = Outlets Purchase Dictionary
 */
- (void)configureOutletsLabels {
    outletsLabel.text = @"";
    for (int i = 0; i < ((NSArray *)purchaseDict[@"purchases"]).count; i++) {
        outletsLabel.text = [NSString stringWithFormat:@"%@", [purchaseDict[@"purchases"] objectAtIndex:i][@"outlet"][@"title"]];

        int postPrice = (int)[((NSString *)[purchaseDict[@"purchases"] objectAtIndex:i][@"amount"])integerValue];
        outletsPriceLabel.text = [NSString stringWithFormat:@"$%d", (int)(((float)postPrice) * (float)(0.01))];

        // If it is not the last outlet, skip a line in the text
        if (i != ((NSArray *)purchaseDict[@"purchases"]).count - 1) {
            outletsLabel.text = [NSString stringWithFormat:@"%@\n", outletsLabel.text];
            outletsPriceLabel.text = [NSString stringWithFormat:@"%@\n", outletsPriceLabel.text];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
