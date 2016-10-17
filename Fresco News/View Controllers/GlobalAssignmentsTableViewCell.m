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

@implementation GlobalAssignmentsTableViewCell{
    __weak IBOutlet NSLayoutConstraint *heigtConstraint;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *activeOutletsLabel;
    
    __weak IBOutlet UILabel *assignmentDescriptionLabel;
    __weak IBOutlet UIView *outletIconsView;
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
    [self configureOutletImagesWithOutletArray:outletArray];
    if(outletArray.count > 1){
        [activeOutletsLabel setText:[NSString stringWithFormat:@"%lu active news outlets", (unsigned long)outletArray.count]];
    }else if(outletArray.count == 1){
        [activeOutletsLabel setText:[NSString stringWithFormat:@"%lu active news outlet", (unsigned long)outletArray.count]];
    }
}

-(void)configureOutletImagesWithOutletArray:(NSArray *)outletArray{
    NSMutableArray *outletImageUrls = [[NSMutableArray alloc] init];
    
    
    for(NSDictionary *outlet in outletArray){
        if([outlet objectForKey:@"avatar"] != [NSNull null]){
            [outletImageUrls addObject:[NSURL URLWithString:(NSString *)[outlet objectForKey:@"avatar"]]];
        }
    }
    
    if(outletImageUrls.count != 0){
        UIImageView *defaultImageView = (UIImageView *)[outletIconsView.subviews objectAtIndex:0];
        UIImageView *defaultIVCopy = [self copyImageView:defaultImageView];
        int i = 0;
        for(i = 0; i < outletImageUrls.count; i++){
            NSURL *imageUrl = [outletImageUrls objectAtIndex:i];
            if(i == 0){
                defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
                [defaultImageView hnk_setImageFromURL:imageUrl];
            }else{
                UIImageView *imageView = [self copyImageView:defaultIVCopy];
                CGRect newFrame = imageView.frame;
                newFrame.origin.x+=8*i;
                [imageView setFrame:newFrame];
                defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
                
                [imageView hnk_setImageFromURL:imageUrl];
            }
        }
        //If any outlets don't have an avatar, add in the default avatar
        if(outletArray.count - outletImageUrls.count > 0){
            for(i = i; i < outletImageUrls.count; i++){
                UIImageView *imageView = [self copyImageView:defaultIVCopy];
                CGRect newFrame = imageView.frame;
                newFrame.origin.x+=8*i;
                [imageView setFrame:newFrame];
            }
        }
    }else{
        //TODO
        //This happens when they don't have an avatar for the outlet
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
