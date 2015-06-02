//
//  GalleryViewController.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "MTLModel+Additions.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FRSDataManager.h"
#import <PBWebViewController.h>
#import "FRSPost.h"
#import "GalleryView.h"
#import "FRSArticle.h"
#import "GalleryViewController.h"
#import "PostCollectionViewCell.h"


@interface GalleryViewController ()

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlace;

@property (weak, nonatomic) IBOutlet UILabel *byline;

@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *storiesLabel;
@property (weak, nonatomic) IBOutlet UITableView *storiesTable;
@property (weak, nonatomic) IBOutlet UILabel *articlesTitle;
@property (weak, nonatomic) IBOutlet UITableView *articlesTable;

@end

@implementation GalleryViewController

//- (id)init
//{
//    
//    if (self = [super init]) {
//
//    }
//    
//    return self;
//    
//}


- (void)viewDidLoad
{
    
    [self setUpGallery];

}

- (void)setUpGallery{
    
    self.galleryView.gallery = self.gallery;
    
    self.caption.text = self.gallery.caption;
    
    self.timeAndPlace.text = [MTLModel relativeDateStringFromDate:self.gallery.createTime];
    
    self.byline.text = ((FRSPost *)[self.gallery.posts firstObject]).byline;
    
    if(self.gallery.articles.count == 0){
        
        [self.articlesTable setHidden:YES];
        
        [self.articlesTitle setHidden:YES];
        
    }

}

- (void)openGalleryWithId:(NSString *)galleryId{

    [[FRSDataManager sharedManager] getGallery:galleryId WithResponseBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            [self setGallery:responseObject];
            
            [self setUpGallery];
            
        }
        
    }];

}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.storiesTable){
        return 0;
    }
    else if(tableView == self.articlesTable){
        
        return self.gallery.articles.count;
        
    }
    
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.storiesTable){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"relatedStoryCell"];
        
        UILabel *storyTitle = (UILabel *)[cell viewWithTag:100];
        
        [storyTitle setText:@"Test"];
        
        return cell;
        
    }
    else if(tableView == self.articlesTable){
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell"];
        
        UILabel *articleTitle = (UILabel *)[cell viewWithTag:100];
        
        UIImageView *articleImage = (UIImageView *)[cell viewWithTag:200];
        
        articleTitle.text = article.title;
        
        [articleImage setImageWithURL:article.URL];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    }
    
    return 0;
    
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.storiesTable){
        

    }
    else if(tableView == self.articlesTable){
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:indexPath.row];
        
        //Push to web view
        PBWebViewController *webViewController = [[PBWebViewController alloc] init];
        webViewController.URL = article.URL;
        
        //        PBSafariActivity *activity = [[PBSafariActivity alloc] init];
        //        webViewController.applicationActivities = @[activity];
        //
        [[self navigationController] pushViewController:webViewController animated:YES];
        
        
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}



@end
