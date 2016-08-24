//
//  FRSComment.m
//  Fresco
//
//  Created by Philip Bernstein on 8/24/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSComment.h"
#import "FRSAppDelegate.h"

@implementation FRSComment

-(instancetype)initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];
    
    if (self) {
        [self configureWithGallery:commentDictionary];
    }
    
    return self;
}

-(void)configureWithGallery:(NSDictionary *)dictionary {
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    _comment = dictionary[@"comment"];
    _user = [FRSUser nonSavedUserWithProperties:dictionary[@"user"] context:[delegate managedObjectContext]];
    _entities = dictionary[@"entities"];
    
    _updatedAt = dictionary[@"updated_at"];
    _createdAt = dictionary[@"created_at"];
    [self createAttributedText];
}

-(void)createAttributedText {
    _attributedString = [[NSAttributedString alloc] initWithString:_comment];
}
@end
