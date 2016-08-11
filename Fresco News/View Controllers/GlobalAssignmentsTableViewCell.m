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
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *activeOutletsLabel;
    
    __weak IBOutlet UILabel *assignmentDescriptionLabel;
    __weak IBOutlet UIView *outletIconsView;
    __weak IBOutlet UILabel *expirationLabel;
    __weak IBOutlet UILabel *photoPriceLabel;
    __weak IBOutlet UILabel *videoPriceLabel;
    __weak IBOutlet UIButton *openCameraButton;
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
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        self.assignment = assignment;
//        NSString *dateInString = (NSString *)[self.assignment objectForKey:@"ends_at"];
//        NSLog(@"Date %@", dateInString);
//        
//        [assignmentDescriptionLabel setText:(NSString *)[self.assignment objectForKey:@"caption"]];
        //        [self configureExpirationDateWithString:dateInString];
        //        [self configureOutletImagesWithOutletArray: (NSArray *)[self.assignment objectForKey:@"outlets"]];
    }
    return self;
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
    [assignmentDescriptionLabel sizeToFit];
    [self configureExpirationDateWithString:dateInString];
    NSArray *outletArray = (NSArray *)[self.assignment objectForKey:@"outlets"];
    [self configureOutletImagesWithOutletArray:outletArray];
    if(outletArray.count > 1){
        [activeOutletsLabel setText:[NSString stringWithFormat:@"%lu active news outlets", (unsigned long)outletArray.count]];
    }else if(outletArray.count == 1){
        [activeOutletsLabel setText:[NSString stringWithFormat:@"%lu active news outlet", (unsigned long)outletArray.count]];
    }
    //Set the frame to resize the entire cell in the tableview
    CGRect newFrame = self.frame;
    int botPaddingInZeplin = 12 - 8;//-8 because interface padding
    newFrame.size.height = openCameraButton.frame.origin.x+botPaddingInZeplin;
    [self setFrame:newFrame];
    
    //Add lines
    [self addSubview:[UIView lineAtPoint:CGPointMake(0, 0.5)]];
    [self addSubview:[UIView lineAtPoint:CGPointMake(0, self.frame.size.height-0.5)]];
}

-(void)configureOutletImagesWithOutletArray:(NSArray *)outletArray{
    NSMutableArray *outletImageUrls = [[NSMutableArray alloc] init];
    for(NSDictionary *outlet in outletArray){
        [outletImageUrls addObject:[NSURL URLWithString:(NSString *)[outlet objectForKey:@"avatar"]]];
    }
    
    UIImageView *defaultImageView = (UIImageView *)[outletIconsView.subviews objectAtIndex:0];
    
    for(int i = 0; i < outletImageUrls.count; i++){
        NSURL *imageUrl = [outletImageUrls objectAtIndex:i];
        if(i == 0){
            [defaultImageView hnk_setImageFromURL:imageUrl];
        }else{
            UIImageView *imageView = [defaultImageView copy];
            CGRect newFrame = imageView.frame;
            newFrame.origin.x+=8*i;
            [imageView setFrame:newFrame];
            
            [imageView hnk_setImageFromURL:imageUrl];
        }
    }
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
