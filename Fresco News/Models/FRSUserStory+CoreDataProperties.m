//
//  FRSUserStory+CoreDataProperties.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/20/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStory+CoreDataProperties.h"

@implementation FRSUserStory (CoreDataProperties)

+ (NSFetchRequest<FRSUserStory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"FRSUserStory"];
}

@dynamic caption;
@dynamic createdDate;
@dynamic editedDate;
@dynamic imageURLs;
@dynamic index;
@dynamic liked;
@dynamic likes;
@dynamic reposted;
@dynamic reposted_by;
@dynamic reposts;
@dynamic title;
@dynamic uid;
@dynamic creator;
@dynamic posts;

@end
