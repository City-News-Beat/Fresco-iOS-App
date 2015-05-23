//
//  FRSPostsInterfaceController.h
//  Fresco
//
//  Created by Elmir Kouliev on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface FRSGalleriesInterfaceController : WKInterfaceController

@property (nonatomic, strong) NSArray *posts;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *postTable;

@end