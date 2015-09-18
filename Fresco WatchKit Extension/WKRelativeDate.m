//
//  NSRelativeDate.m
//  Fresco
//
//  Created by Fresco News on 7/8/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "WKRelativeDate.h"

@implementation WKRelativeDate

+ (NSString *)relativeDateString:(NSDate*)date {
    
    int ti = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];
    
    if(ti <= 0){
        return [NSString stringWithFormat:@"just now"];
    }
    else if(ti < 60){
        
        int diff = ti;
        
        return [NSString stringWithFormat:@"%ds", diff];
    }
    else if(ti < 3600){
        
        int diff = ti / 60;
        
        return [NSString stringWithFormat:@"%dm", diff];
        
    }
    else if(ti<86400){
        
        int diff = ti / 60 / 60;
        
        return [NSString stringWithFormat:@"%dh", diff];
        
    }
    else if(ti < 604800){
        
        int diff = ti / 60 / 60 / 24;
        
        return [NSString stringWithFormat:@"%dd", diff];
        
    }
    else if(ti < 31556900){
        
        int diff = ti / 60 / 60 / 24 / 4;
        
        return [NSString stringWithFormat:@"%dw", diff];
        
        
    }
    else{
        
        int diff = ti / 60 / 60 / 24 / 30 / 52;
        
        return [NSString stringWithFormat:@"%dy", diff];
        
    }
    
    return 0;
    
}

@end
