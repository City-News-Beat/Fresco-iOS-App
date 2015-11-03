//
//  WKImagePath.m
//  Fresco
//
//  Created by Elmir Kouliev on 9/8/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "WKImagePath.h"

@implementation WKImagePath

/*
** Retrieves small version of image
*/

+ (NSURL *)CDNImageURL:(NSString *)url withSize:(ImageSize)size{
    
    if (!([url rangeOfString:@"cloudfront"].location == NSNotFound)){
        
        NSMutableString *mu = [NSMutableString stringWithString:url];
        
        NSRange range = [mu rangeOfString:@"/images/"];
        
        if (!(range.location == NSNotFound)) {
            
            NSString *insert;
            
            if(size == LargeImageSize) insert = @"large/";
            else if(size == MediumImageSize) insert = @"medium/";
            else if(size == SmallImageSize) insert = @"small/";
            
            [mu insertString:insert atIndex:(range.location + range.length)];
            
            return [NSURL URLWithString:mu];
            
        }
        
    }
    else return [NSURL URLWithString:url];
    
    return nil;
    
}

@end
