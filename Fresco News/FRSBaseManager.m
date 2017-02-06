//
//  FRSBaseManager.m
//  Fresco
//
//  Created by User on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSBaseManager.h"

@implementation FRSBaseManager

- (NSManagedObjectContext *)managedObjectContext {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

@end
