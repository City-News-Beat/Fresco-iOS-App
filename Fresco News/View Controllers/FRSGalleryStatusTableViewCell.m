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

@implementation FRSGalleryStatusTableViewCell{
    
    IBOutlet UIImageView *postImageView;
    IBOutlet UILabel *outletsLabel;
    IBOutlet UILabel *outletsPriceLabel;
    
    IBOutlet NSLayoutConstraint *postImageViewHeightConstraint;
    
    NSDictionary *purchaseDict;
}

-(void)configureCellWithPurchaseDict:(NSDictionary *)purchasePostDict{
    purchaseDict = [[NSDictionary alloc] initWithDictionary:purchasePostDict];
    postImageView.layer.cornerRadius = 3;
    
    NSLog(@"URL %@", [NSURL URLWithString:purchaseDict[@"image"]]);
    
    NSURL *resizedURL = [[NSURL alloc] initWithString:purchaseDict[@"image"] width:postImageView.frame.size.width];
    [postImageView hnk_setImageFromURL:resizedURL placeholder:nil success:^(UIImage *image) {
        [self configurePostImageViewWithImage:image];
        [self configureOutletsLabels];
        // Reload the table once for every cell
        if(self.reloadedTableViewCounter == 0){
            [self.tableView reloadData];
            self.reloadedTableViewCounter = 1;
        }
    } failure:^(NSError *error) {
        NSLog(@"ERROR %@", error);
    }];
}

-(void)configurePostImageViewWithImage:(UIImage *)image{
    float aspectRatio = postImageView.frame.size.width / image.size.width;
    postImageViewHeightConstraint.constant = aspectRatio * image.size.height;

    [postImageView setImage:image];
    
    //postImageViewHeightConstraint.constant = image.size.height;
    /*
    CGRect newFrame = postImageView.frame;
    newFrame.size.height = image.size.height;
    postImageView.frame = newFrame;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + image.size.height);
        
        [self.tableView layoutIfNeeded];
    });*/
}


-(void)configureOutletsLabels{
    outletsLabel.text = @"";
    for(int i = 0; i < ((NSArray *)purchaseDict[@"purchases"]).count; i++){
        outletsLabel.text = [NSString stringWithFormat:@"%@", [purchaseDict[@"purchases"] objectAtIndex:i][@"outlet"][@"title"]];
        
        int postPrice = (int)[((NSString *)[purchaseDict[@"purchases"] objectAtIndex:i][@"amount"]) integerValue];
        outletsPriceLabel.text = [NSString stringWithFormat:@"$%d", (int)(((float)postPrice) * (float)(0.01))];
        
        if (i != ((NSArray *)purchaseDict[@"purchases"]).count-1){
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
