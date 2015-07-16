//
//  NSRelativeDate.m
//  Fresco
//
//  Created by Fresco News on 7/8/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NSRelativeDate.h"

@implementation NSRelativeDate

+ (NSString *)relativeDateString:(NSDate*)date {
    

    double ti = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];
    
    if(ti < 60){
        return @"just now";
    }
    else if(ti < 3600){
        
        int diff = round(ti / 60);
        
        return [NSString stringWithFormat:@"%d m", diff];
        
    }
    else if(ti<86400){
        
        int diff = round(ti / 60 / 60);
        
        return [NSString stringWithFormat:@"%d h", diff];
        
    }
    else if(ti < 604800){
        
        int diff = round(ti / 60 / 60 / 24);
        
        return [NSString stringWithFormat:@"%d d", diff];
        
    }
    else if(ti < 2629740){
        
        int diff = round(ti / 60 / 60 / 24 / 4);
        
        return [NSString stringWithFormat:@"%d w", diff];
        
        
    }
    else if(ti < 31556900){
        
        int diff = round(ti / 60 / 60 / 24 / 4 / 12);
        
        return  [NSString stringWithFormat:@"%d mo", diff];
        
        
    }
    else if(ti < 3155690000){
        
        int diff = round(ti / 60 / 60 / 24 / 30 / 52);
        
        return [NSString stringWithFormat:@"%d y", diff];
        
    }
    else
        return @"Never";
    
    return 0;
    
}

@end
