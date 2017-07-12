//
//  FRSAssignmentDescriptionViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 7/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentDescriptionViewController.h"
#import "UIView+Helpers.h"

@interface FRSAssignmentDescriptionViewController ()

@end

@implementation FRSAssignmentDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    [self configureTextField];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
}

- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"DESCRIPTION";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitleView:label];
}

- (void)configureTextField {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.height/2))];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    [containerView addSubview:[UIView lineAtPoint:CGPointMake(0, containerView.frame.size.height)]];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 32, containerView.frame.size.height -32)];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:16];
    [textView becomeFirstResponder];
    textView.tintColor = [UIColor frescoBlueColor];
    
    
//    NSAttributedString *caption = self.assignment[@"caption"];
    
    
//    textView.attributedText = [self stringWithFormat:[self formattedAttributedStringFromString:[self formattedTextForAssignmentType:self.assignmentType]], caption, NULL];
    
    textView.attributedText = [self formattedAttributedStringFromString:[self formattedTextForAssignmentType:self.assignmentType]];
    
    // We should show old caption here too
    // Maybe add scrollview and swipe down?
    // Maybe add gesture rec?
    // Concat attributed strings would be ideal.
    // Save this for the end.
    
    
    [containerView addSubview:textView];
}


- (NSAttributedString*)stringWithFormat:(NSAttributedString*)format, ...{
    va_list args;
    va_start(args, format);
    
    NSMutableAttributedString *mutableAttributedString = (NSMutableAttributedString*)[format mutableCopy];
    NSString *mutableString = [mutableAttributedString string];
    
    while (true) {
        NSAttributedString *arg = va_arg(args, NSAttributedString*);
        if (!arg) {
            break;
        }
        NSRange rangeOfStringToBeReplaced = [mutableString rangeOfString:@"%@"];
        [mutableAttributedString replaceCharactersInRange:rangeOfStringToBeReplaced withAttributedString:arg];
    }
    
    va_end(args);
    
    return mutableAttributedString;
}


- (NSString *)formattedTextForAssignmentType:(AssignmentTypes)assignmentType {
    
    NSString *description = @"";
    
    switch (assignmentType) {
            
        case TYPE_ACCIDENT:
            description = @"{OUTLET} seeks steady videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of an accident at {ADDRESS} in {CITY, STATE}. Capture the scene from a variety of angles, getting wide, medium, and tight shots, but please do not get in the way of police or medical professionals. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
        case TYPE_BROLL:
            description = @"{OUTLET} is looking for supplemental footage (must be a minimum of 3 videos in the 30 to 60 seconds range), or b-roll, of {???} in {CITY, STATE}. Capture wide, medium, tight, and steady shots from a variety of angles. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
        case TYPE_BANK:
            description = @"There are reports of a robbery at {NAME OF BANK} at {ADDRESS} in {CITY, STATE}. Please be alert, maintain caution, and follow any evacuation instructions from authorities. If you have captured any content from the scene, we will accept it after you have reached a location of safety. You will be notified and paid if your content is used by a news partner.";
            break;
        case TYPE_BOMB:
            description = @"There are reports of a bomb threat at {ADDRESS} in {CITY, STATE}. Please be alert, maintain caution, and follow any evacuation instructions from authorities. If you have captured any content from the scene, we will accept it after you have reached a location of safety. You will be notified and paid if your content is used by a news partner.";
            break;
        case TYPE_BUILDING_COLLAPSE:
            description = @"{OUTLET} seeks steady videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of a building collapse scene at {ADDRESS} in {CITY, STATE}. It is unclear if the structure is still unstable, so maintain safe distance. Do not put yourself in danger to capture content. Capture shots of any damage to the building, including debris on the scene, from a variety of angles. Please do not get in the way of authorities. You will be notified and paid if your content is used by a news partner.";
            break;
        case TYPE_EVENT:
            description = @"{OUTLET} seeks steady videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of {EVENT} at {ADDRESS} in {CITY, STATE}. The event starts at {START TIME} {a.m./p.m.} and ends at {END TIME} {a.m./p.m.} Capture shots of the event and any related activities. Capture wide, medium, and tight shots from a variety of angles. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
        case TYPE_FIRE:
            description = @"{OUTLET} seeks steady videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of a fire at {ADDRESS} in {CITY, STATE}. Capture shots of the damage caused by the fire as well as any emergency response activity from a variety of angles, getting wide, medium, and tight shots. Please do not get in the way of any police, firefighters, or medical professionals. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
        case TYPE_HAZ_SUSPICIOUS:
            description = @"It appears that {???} in {CITY, STATE}. If you are in the area, please be alert, maintain caution, and follow any evacuation instructions from authorities. If you have captured any content from the scene, we will accept it after you have reached a location of safety. You will be notified and paid if your content is used by a news partner.";
            break;
        case TYPE_HIGH_SPEED_CHASE:
            description = @"There are reports of police chasing down a suspect {ON FOOT/IN A CAR} in the {LOCATION} of {CITY, STATE}. If you are in the area, please be alert, maintain caution, and follow an evacuation instructions from authorities. If you have captured any content from the scene, we will accept it after you have reached a location of safety. You will be notified and paid if your content is used by a news partner. ";
            break;
        case TYPE_SHOOTING_STABBING:
            description = @"There are reports of a {SHOOTING or STABBING} at {ADDRESS} in {CITY, STATE}. If you are in the area, please be alert, maintain caution, and follow any evacuation instructions from authorities. If you have captured any content from the scene, we will accept it after you have reached a location of safety. You will be notified and paid if your content is used by a news partner.";
            break;
        case TYPE_RESCUE:
            description = @"{OUTLET} seeks steady videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of a technical rescue underway at {ADDRESS} in {CITY, STATE}. Capture content from a variety of angles. Please do not get in the way of authorities or medical professionals. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
        case TYPE_TRAUMA:
            description = @"{OUTLET} seeks steady videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of police activity and emergency crews responding to a trauma alert issued at {ADDRESS} in {CITY, STATE}. Please do not get in the way of police or medical professionals. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
        case TYPE_WEATHER:
            description = @"{OUTLET} seeks steady phone camera, DSLR, drone, and 360 degree camera videos (must be a minimum of 3 videos in the 30 to 60 seconds range) of the weather in {CITY, STATE}. Capture content anywhere within the set radius. Take shots from a variety of angles, getting wide, medium, and tight shots. Contact us through the Ask Us Anything function in the app if you have any questions about this or the price per photo/video earnings.";
            break;
            
        default:
            break;
    }
    
    NSString *outletString = [description stringByReplacingOccurrencesOfString:@"{OUTLET}" withString:[self.assignment[@"outlets"] objectAtIndex:0][@"title"]];
    
    return outletString;
}

- (NSAttributedString *)formattedAttributedStringFromString:(NSString *)text {
    
    // TODO: Fix this. Should detect between { }. Way too much room for error this way.
    
    NSRange range1 = [text rangeOfString:@"{ADDRESS}"];
    NSRange range2 = [text rangeOfString:@"{CITY, STATE}"];
    NSRange range3 = [text rangeOfString:@"{???}"];
    NSRange range4 = [text rangeOfString:@"{NAME OF BANK}"];
    NSRange range5 = [text rangeOfString:@"{EVENT}"];
    NSRange range6 = [text rangeOfString:@"{START TIME} {a.m./p.m.}"];
    NSRange range7 = [text rangeOfString:@"{ON FOOT/IN A CAR}"];
    NSRange range8 = [text rangeOfString:@"{LOCATION}"];
    NSRange range9 = [text rangeOfString:@"{SHOOTING or STABBING}"];
    NSRange range10 = [text rangeOfString:@"{END TIME} {a.m./p.m.}"];
    
    
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.87],
                              NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightRegular],
                              NSParagraphStyleAttributeName : paragraphStyle
                              };
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
    UIFont *font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor redColor], NSForegroundColorAttributeName, nil];
    
    [attributedText setAttributes:dictBoldText range:range1];
    [attributedText setAttributes:dictBoldText range:range2];
    [attributedText setAttributes:dictBoldText range:range3];
    [attributedText setAttributes:dictBoldText range:range4];
    [attributedText setAttributes:dictBoldText range:range5];
    [attributedText setAttributes:dictBoldText range:range6];
    [attributedText setAttributes:dictBoldText range:range7];
    [attributedText setAttributes:dictBoldText range:range8];
    [attributedText setAttributes:dictBoldText range:range9];
    [attributedText setAttributes:dictBoldText range:range10];
    
    return attributedText;
}

@end
