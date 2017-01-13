//
//  FRSGalleryStatusTableViewCell.m
//  
//
//  Created by Arthur De Araujo on 1/12/17.
//
//

#import "FRSGalleryStatusTableViewCell.h"
#import "Heneke.h"

@implementation FRSGalleryStatusTableViewCell{
    
    IBOutlet UIImageView *postImageView;
    IBOutlet UILabel *outletsLabel;
    IBOutlet UILabel *outletsPriceLabel;
    
}

-(void)configureCellWithPurchaseDict:(NSDictionary *)purchaseDict{
    /*[postImageView hnk_setImageFromURL:[NSURL URLWithString:postImageURL] placeholder:nil success:^(UIImage *image) {

    } failure:^(NSError *error) {

    }];*/
    
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
