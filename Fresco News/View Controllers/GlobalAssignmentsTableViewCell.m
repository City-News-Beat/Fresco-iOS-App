//
//  GlobalAssignmentsTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 6/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "GlobalAssignmentsTableViewCell.h"
#import "FRSAPIClient.h"
#import <Haneke/Haneke.h>
#import "FRSGlobalAssignmentsTableViewController.h"

@implementation GlobalAssignmentsTableViewCell {
    __strong IBOutlet NSLayoutConstraint *outletWidthConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *activeOutletsLabel;
    
    __weak IBOutlet UILabel *assignmentDescriptionLabel;
    __weak IBOutlet UIView *outletIconsView;
    __weak IBOutlet UIImageView *outletIcon1ImageView;
    __weak IBOutlet UIImageView *outletIcon2ImageView;
    __weak IBOutlet UILabel *expirationLabel;
    __weak IBOutlet UILabel *photoPriceLabel;
    __weak IBOutlet UILabel *videoPriceLabel;
    __weak IBOutlet UIButton *openCameraButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [assignmentDescriptionLabel setNeedsLayout];
    [assignmentDescriptionLabel layoutIfNeeded];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)pressedOpenCamera:(id)sender {
    if (self.openCameraBlock) {
        self.openCameraBlock();
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assignment:(NSDictionary *)assignment {
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}


-(void)configureGlobalAssignmentCellWithAssignment:(NSDictionary *)assignment{
    self.assignment = assignment;
    NSString *dateInString = (NSString *)[self.assignment objectForKey:@"ends_at"];
    NSLog(@"Date %@", dateInString);
        
    //TODO
    //[photoPriceLabel setText:(NSString *)[self.assignment objectForKey:@"photo price key?"]];
    //[videoPriceLabel setText:(NSString *)[self.assignment objectForKey:@"video price key?"]];
    
    [titleLabel setText:(NSString *)[self.assignment objectForKey:@"title"]];
    [assignmentDescriptionLabel setText:(NSString *)[self.assignment objectForKey:@"caption"]];
    [self configureExpirationDateWithString:dateInString];
    NSArray *outletArray = (NSArray *)[self.assignment objectForKey:@"outlets"];
    NSMutableArray *outletImageUrls = [[NSMutableArray alloc] init];
    for (NSDictionary *outlet in outletArray){
        if([outlet objectForKey:@"avatar"] != [NSNull null]){
            [outletImageUrls addObject:[NSURL URLWithString:(NSString *)[outlet objectForKey:@"avatar"]]];
        }
    }
    [outletImageUrls addObject:[NSURL URLWithString:@"http://a2.mzstatic.com/au/r30/Purple69/v4/6c/11/b3/6c11b323-e8a7-b722-133a-0f26e108824a/icon175x175.png"]];
    outletWidthConstraint.constant = 0;
    if (outletImageUrls.count >= 1) {
        NSURL *url = outletImageUrls[0];
        [outletIcon1ImageView hnk_setImageFromURL:url];
        outletWidthConstraint.constant += 24 + 16;
    }
    else {
        [outletIcon1ImageView setHidden:YES];
    }
    if (outletImageUrls.count >= 2) {
        NSURL *url = outletImageUrls[1];
        [outletIcon2ImageView hnk_setImageFromURL:url];
        outletWidthConstraint.constant += 24 + 8;
    }
    else {
        [outletIcon2ImageView setHidden:YES];
    }
    
    if (outletArray.count > 1) {
        [activeOutletsLabel setText:[NSString stringWithFormat:@"%lu active news outlets", (unsigned long)outletArray.count]];
    } else if (outletArray.count == 1) {
        [activeOutletsLabel setText:[NSString stringWithFormat:@"%lu active news outlet", (unsigned long)outletArray.count]];
    }
}


-(UIImageView *)copyImageView:(UIImageView *)imageView{
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:imageView.image];
    [newImageView setCenter:imageView.center];
    [newImageView setContentMode:imageView.contentMode];
    [newImageView setFrame:imageView.frame];
    [newImageView setClipsToBounds:imageView.clipsToBounds];
    [newImageView.layer setCornerRadius:imageView.layer.cornerRadius];
    return newImageView;
}

-(void)configureExpirationDateWithString:(NSString *)dateInString{
    NSDate *expirationDate = [[FRSAPIClient sharedClient] dateFromString:dateInString];
    NSInteger timeUntilExpiration = [expirationDate timeIntervalSinceDate:[NSDate date]];
    
    NSInteger days = timeUntilExpiration/60/60/24;
    NSInteger hours = timeUntilExpiration/60/60;
    NSInteger minutes = timeUntilExpiration/60;
    NSInteger seconds = timeUntilExpiration;
    
    NSString *toDisplay = @"Just now";
    
    if (days > 1) {
        toDisplay = [NSString stringWithFormat:@"Expires in %lu days", days];
    }
    else if (hours > 1) {
        toDisplay = [NSString stringWithFormat:@"Expires in %lu hours", hours];
    }
    else if (minutes > 1) {
        toDisplay = [NSString stringWithFormat:@"Expires in %lu minutes", minutes];
    }
    else if (seconds > 1) {
        toDisplay = [NSString stringWithFormat:@"Expires in %lu seconds", seconds];
    }
    else{
        toDisplay = [NSString stringWithFormat:@"Expiring now"];
    }
    
    if (days > 6) {
        // put actual date EX: Jan 2, 2001
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];

        toDisplay = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:expirationDate]];
    }
    [expirationLabel setText:toDisplay];
}


@end
