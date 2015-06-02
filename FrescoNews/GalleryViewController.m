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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;

@property (weak, nonatomic) IBOutlet UILabel *timeAndPlace;

@property (weak, nonatomic) IBOutlet UILabel *byline;

@property (weak, nonatomic) IBOutlet UILabel *caption;

@property (weak, nonatomic) IBOutlet UIView *storiesView;

@property (weak, nonatomic) IBOutlet UIView *articlesView;

@property (weak, nonatomic) IBOutlet UILabel *storiesLabel;

@property (weak, nonatomic) IBOutlet UITableView *storiesTable;

@property (weak, nonatomic) IBOutlet UILabel *articlesTitle;

@property (weak, nonatomic) IBOutlet UITableView *articlesTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStoriesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStoriesDiff;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintArticleTableHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintArticlesHeight;
@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    
    [self setUpGallery];

}

- (void)viewWillAppear:(BOOL)animated
{
    // just add this line to the end of this method or create it if it does not exist
    [self.articlesTable reloadData];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.scrollView layoutIfNeeded];
//    
//    CGFloat height = 0;
//    
//    for (UIView *view in self.scrollView.subviews) {
//        height +=view.frame.size.height;
//    }
//    
//    [self.scrollView setContentSize:CGSizeMake(320, height)];
//
//    

}


- (void)setUpGallery{
    
    self.galleryView.gallery = self.gallery;
    
    self.caption.text = self.gallery.caption;
    
    self.timeAndPlace.text = [MTLModel relativeDateStringFromDate:self.gallery.createTime];
    
    self.byline.text = ((FRSPost *)[self.gallery.posts firstObject]).byline;
//    
//    self.constraintArticleTableHeight.constant = 10 * 44.0f;
//    
    [self.scrollView layoutIfNeeded];

    if(self.gallery.articles.count == 0){
        
        [self.articlesView setHidden:YES];
    
        self.constraintArticlesHeight.constant = 0.0f;

    
    }
    if(self.gallery.relatedStories == nil){
        
        [self.storiesView setHidden:YES];
        
        self.constraintStoriesHeight.constant = 0.0f;
        
        self.constraintStoriesDiff.constant = 0.0f;

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
        
        FRSArticle *article = [[[self gallery] articles] objectAtIndex:0];
        
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}






@end
