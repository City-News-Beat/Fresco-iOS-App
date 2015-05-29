//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryViewController.h"

@interface GalleryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlace;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *byline;

@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UITableView *storiesTable;
@property (weak, nonatomic) IBOutlet UITableView *articlesTable;
@end

@implementation GalleryViewController


- (id)init
{
    
    if (self = [super init]) {

    }
    
    return self;
    
}


- (void)viewDidLoad
{
    [self.navigationController setTitle:@"Read More"];
    

}


- (void)setGallery:(FRSGallery *)gallery{
    
    _gallery = gallery;
  

}


@end
