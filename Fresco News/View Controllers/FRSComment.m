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
    
    NSLog(@"SASS: %@", dictionary);
    
    if ([dictionary[@"user"][@"id"] isEqualToString:[[FRSAPIClient sharedClient] authenticatedUser].uid]) {
        _isDeletable = TRUE;
    }
    else {
        _isDeletable = FALSE;
    }
    
    _entities = dictionary[@"entities"];
    _imageURL = dictionary[@"user"][@"avatar"];
    _updatedAt = dictionary[@"updated_at"];
    _createdAt = dictionary[@"created_at"];
    _uid = dictionary[@"id"];
    
    [self createAttributedText];
}

-(void)createAttributedText {
    _attributedString = [[NSMutableAttributedString alloc] initWithString:_comment];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    [_attributedString beginEditing];
    
    [_attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, _comment.length)];
    [_attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _comment.length)];
    
    
    for (NSDictionary *attribute in _entities) {
        if ([attribute[@"entity_type"] isEqualToString:@"user"]) {
            // load user
            NSString *name = attribute[@"text"];
            NSInteger startIndex = [attribute[@"start_index"] integerValue];
            NSInteger endIndex = [attribute[@"end_index"] integerValue];
            
            [_attributedString addAttribute: NSLinkAttributeName value:[@"name://" stringByAppendingString:name] range:NSMakeRange(startIndex, endIndex-startIndex+2)];
        }
        else if ([attribute[@"entity_type"] isEqualToString:@"tag"]) {
            NSString *name = attribute[@"text"];
            NSInteger startIndex = [attribute[@"start_index"] integerValue];
            NSInteger endIndex = [attribute[@"end_index"] integerValue];
            
            [_attributedString addAttribute: NSLinkAttributeName value:[@"tag://" stringByAppendingString:name] range:NSMakeRange(startIndex, endIndex-startIndex+2)];
        }
    }
    
    [_attributedString endEditing];
}

-(NSInteger)calculateHeightForCell:(FRSCommentCell *)cell {
    CGRect labelRect = [self.comment
                        boundingRectWithSize:cell.commentTextField.frame.size
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15]
                                     }
                        context:nil];
    
    return labelRect.size.height;
}
@end
