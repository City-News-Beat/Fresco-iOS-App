//
//  FRSStory.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSStory.h"
#import "FRSGallery.h"
#import "FRSUser.h"
#import "FRSCoreData.h"

#import "FRSDateFormatter.h"

@import UIKit;


//@property (nullable, nonatomic, retain) NSString *caption;
//@property (nullable, nonatomic, retain) NSDate *createdDate;
//@property (nullable, nonatomic, retain) NSDate *editedDate;
//@property (nullable, nonatomic, retain) NSString *title;
//@property (nullable, nonatomic, retain) NSString *uid;
//@property (nullable, nonatomic, retain) FRSUser *creator;
//@property (nullable, nonatomic, retain) NSSet<FRSGallery *> *galleries;

@implementation FRSStory

// Insert code here to add functionality to your managed object subclass
-(void)configureWithDictionary:(NSDictionary *)dict{
    self.caption = dict[@"caption"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.title = dict[@"title"];
    self.uid = dict[@"_id"];
    self.imageURLs = [self imagesURLsFromThumbnails:dict[@"thumbnails"]];
}

-(NSInteger)heightForStory{
    
    NSInteger imageViewHeight = IS_IPHONE_5 ? 192 : 240;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32 , 0)];
    label.text = self.caption;
    label.numberOfLines = 6;
    label.font = [UIFont systemFontOfSize:15 weight:-1];
    [label sizeToFit];
    
    // 44 is tab bar, 11 is top padding, 13 is bottom padding
    imageViewHeight += label.frame.size.height + 44 + 11 + 13;
    return imageViewHeight;
}

-(NSArray *)imagesURLsFromThumbnails:(NSArray *)thumbnails{
    NSMutableArray *mArr = [NSMutableArray new];
    for (NSDictionary *thumb in thumbnails){
        NSString *stringURL = thumb[@"image"];
        if (!stringURL) continue;
        NSString *escapedString = [stringURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *url = [NSURL URLWithString:escapedString];
        [mArr addObject:url];
        
        if (mArr.count >= 6) {
            break;   
        }
    }
    return [mArr copy];
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSStory *story = [FRSStory MR_createEntityInContext:context];
    [story configureWithDictionary:properties];
    return story;
}

@end
