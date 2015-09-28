//
//  AssignmentNotificationCell.m
//  FrescoNews
//
//  Created by Fresco News on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NotificationCell.h"
#import "FRSNotification.h"
#import "MTLModel+Additions.h"
#import "FRSDataManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation NotificationCell


- (void)setNotification:(FRSNotification *)notif{
    
    _notification = notif;
    
    self.eventName.text = _notification.event;
    self.notificationDescription.text = _notification.body;
    self.timeElapsed.text = [MTLModel relativeDateStringFromDate:_notification.date];
    
    //Set Values from notificaiton
    if([_notification.type isEqual:@"payment"]){
        
        //Check if the user has payment info
        if([[FRSDataManager sharedManager].currentUser.payable integerValue] == 1){
            self.title.text = @"You just got paid!";
        }
        else{
            self.title.text = [NSString stringWithFormat:@"You have $%i waiting for you!", 10];
        }
            
    }
    else
        self.title.text = _notification.title;
    
    if(_notification.seen == false){
        self.contentView.backgroundColor = [UIColor lightGoldCellColor];
    }
    
    //Check if assignment, then check if the assignment has expired
    if([_notification.type isEqualToString:@"assignment"]) {
        
        [self.image setImage:[UIImage imageNamed:@"assignmentWarningIcon"]];
  
        if (IS_IPHONE_5 || IS_ZOOMED_IPHONE_6)
            [self.firstButton setTitle:VIEW forState:UIControlStateNormal];
        else
            [self.firstButton setTitle:VIEW_ASSIGNMENT forState:UIControlStateNormal];
        
        [self.secondButton setTitle:OPEN_IN_MAPS forState:UIControlStateNormal];
        
    }
    else if ([_notification.type isEqualToString:@"use"]) {
        
        [self.image setImage:[UIImage imageNamed:@"assignmentWarningIcon"]];
        
        //Hide the second button
        self.secondButton.hidden = YES;
        
        [self.firstButton setTitle:@"View Content" forState:UIControlStateNormal];
    
        if (!_notification.meta[@"icon"]) {
            [self.image setImage:[UIImage imageNamed:@"assignmentWarningIcon"]];
        }
        else if([_notification.meta[@"icon"] isKindOfClass:[NSString class]]) {
            
            [self.image setImageWithURL:[NSURL URLWithString:_notification.meta[@"icon"]]
                       placeholderImage:[UIImage imageNamed:@"assignmentWarningIcon"]];
        }
        
    }
    else if([_notification.type isEqual:@"payment"]){
        
        [self.image setImage:[UIImage imageNamed:@"currency"]];
        
        //Check if the user hsa payment info
        if([[FRSDataManager sharedManager].currentUser.payable integerValue] == 1){
            
            self.secondButton.hidden = YES;
            self.firstButton.hidden = YES;
            
        }
        else{//Set button to "Add Card" to take them to the payment info view
            
            self.notificationDescription.text = @"";
            self.secondButton.hidden = YES;
            [self.firstButton setTitle:ADD_CARD forState:UIControlStateNormal];
        }
  
    }
    
    //UI Styling
    self.firstButton.layer.cornerRadius = 4;
    self.secondButton.layer.cornerRadius = 4;
    
    self.firstButton.clipsToBounds = YES;
    self.secondButton.clipsToBounds = YES;
    
    self.firstButton.layer.borderWidth = 1.0;
    self.firstButton.layer.borderColor = [UIColor fieldBorderColor].CGColor;
    self.secondButton.layer.borderWidth = 1.0;
    self.secondButton.layer.borderColor = [UIColor fieldBorderColor].CGColor;
    

}

@end
